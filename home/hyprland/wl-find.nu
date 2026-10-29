# Ctrl+F for the whole screen: type what to find, then click it. The find bar
# (wl-find.qml, $WL_FIND_QML, kept loaded by wl-find-bar.service) comes up at
# once, dims the focused output once it is captured, and outlines each match as
# it is typed; tesseract reads the screen meanwhile. On Enter a lone match is
# clicked at once; several get wl-kbptr's hints (../wl-kbptr has their look).

# tesseract takes over two seconds on the whole 3840x2400 panel, so the capture
# is read in horizontal strips, in parallel. Strips overlap by OVERLAP logical
# pixels, so a line of text up to twice that tall is whole in one of them; each
# word belongs to the strip its middle falls in. Past 12 strips the overlaps
# cost more than they save.
const STRIPS = 12
const OVERLAP = 32
# tesseract takes the rarer shade of a whole strip for ink, so where light and
# dark grounds share a strip (a terminal beside a page, a dark header, white
# text on a button) one of them loses its text. So each strip goes in grey,
# inverted wherever it is dark on average over BLOCK logical pixels: dark text
# on a light ground throughout.
const BLOCK = 24

def main [] {
    let output = hyprctl monitors -j | from json | where focused | first
    let dir = mktemp -d -p $env.XDG_RUNTIME_DIR wl-find.XXXXXX
    let lines = $"($dir)/lines"
    let result = $"($dir)/result"
    # The find bar reads the lines from this pipe, a strip's worth at a time.
    # The first line, empty, is sent once the screen is captured, and only
    # then does the bar dim the screen, so the dim stays out of the picture. A
    # failed capture closes the pipe unwritten, and the bar closes.
    ^mkfifo $lines
    # The bar first: the OCR's three dozen processes would only slow it.
    if not (open-bar $output.name $lines $result) {
        rm -r $dir
        return
    }
    job spawn {
        try {
            read-lines $output.name $output.scale $dir | each { to json --raw } | to text | save -f $lines
        } catch {
            "" | save -f $lines
        }
    }
    # The bar leaves its answer in $result when it closes; a bar that crashed
    # leaves none.
    let bar = try { ^qs list --path $env.WL_FIND_QML --json | from json | first | get pid } catch { 0 }
    while (not ($result | path exists)) and ($"/proc/($bar)" | path exists) {
        sleep 10ms
    }
    # Stop whatever still reads: the bar may have left before it was done.
    job list | each {|j| job kill $j.id } | ignore
    # Logical pixels, relative to the output.
    let boxes = if ($result | path exists) { open --raw $result | from json } else { [] }
    rm -r $dir

    match ($boxes | length) {
        0 => { }
        1 => {
            let b = $boxes.0
            let x = $output.x + $b.x + $b.w / 2
            let y = $output.y + $b.y + $b.h / 2
            hyprctl eval $"hl.dispatch\(hl.dsp.cursor.move\({ x = ($x), y = ($y) }\)\)" | ignore
            wlrctl pointer click left
        }
        _ => {
            # Top to bottom: the strips come in whatever order tesseract
            # finishes them, and the hints should not change with it.
            $boxes | sort-by y x | each {|b|
                let x = $b.x | math floor
                let y = $b.y | math floor
                $"(($b.x + $b.w | math ceil) - $x)x(($b.y + $b.h | math ceil) - $y)+($x)+($y)"
            } | str join "\n"
            | wl-kbptr --output $output.name -o modes=floating,click -o mode_floating.source=stdin
        }
    }
}

# Opens the find bar on an output; false if no bar answers. The bar is
# wl-find-bar.service's, kept loaded; one not running yet is started, and
# waited for while it loads.
def open-bar [screen: string, lines: string, result: string] {
    for attempt in 0..<30 {
        let call = ^qs ipc --path $env.WL_FIND_QML call find open $screen $lines $result | complete
        if $call.exit_code == 0 { return true }
        if $attempt == 0 { ^systemctl --user start wl-find-bar.service | complete | ignore }
        sleep 100ms
    }
    false
}

# The lines of text on an output, in batches: an empty one as soon as grim has
# captured it, then a strip's worth as tesseract finishes each. A line is a
# list of words { text, x, y, w, h } in logical pixels. The strips go to
# tesseract through pipes in $dir.
def read-lines [name: string, scale: number, dir: string] {
    # A tesseract for each strip, started before the capture so its models
    # load meanwhile; each mails its TSV back here (none if it failed). One
    # thread each: their OpenMP threads would only fight the other strips'
    # for the cores, and spin while they wait.
    let me = job id
    let pipes = 0..<$STRIPS | each {|i| $"($dir)/strip($i)" }
    ^mkfifo ...$pipes
    $env.OMP_THREAD_LIMIT = "1"
    # The dark-on-light pass (BLOCK) ahead of each tesseract. magick also
    # starts before the strip's size is known, so it works the sizes out
    # itself: %[wh] is the strip's, the other the BLOCK grid over it.
    let blocks = $BLOCK * $scale
    let grid = $"%[fx:round\(w/($blocks)\)]x%[fx:round\(h/($blocks)\)]!"
    for i in 0..<$STRIPS {
        let pipe = $pipes | get $i
        job spawn {
            let tsv = (
                ^cat $pipe
                | ^magick ppm:- -colorspace Gray -set option:wh "%wx%h"
                "(" +clone -scale $grid -resize "%[wh]!" -threshold 50% -negate ")"
                -compose Difference -composite pgm:-
                | ^tesseract - - tsv | complete | get stdout
            )
            { i: $i, tsv: $tsv } | job send $me
        }
    }

    let image = ^grim -o $name -t ppm - | into binary
    # grim writes "P6\n<width> <height>\n255\n", then the rows, three bytes a pixel.
    let head = $image | bytes at 0..31
    let breaks = $head | bytes index-of --all 0x[0a]
    let size = $head | bytes at ($breaks.0 + 1)..<($breaks.1) | decode utf-8 | split row " " | into int
    let width = $size.0
    let height = $size.1
    let pixels = $breaks.2 + 1
    let row = $width * 3
    let step = $height / $STRIPS | math ceil
    let overlap = $OVERLAP * $scale | math round
    let strips = 0..<$STRIPS | each {|i|
        let core = $i * $step
        {
            core: $core
            top: ([($core - $overlap) 0] | math max)
            bottom: ([($core + $step + $overlap) $height] | math min)
        }
    }
    # The strips into their pipes, all at once and off this thread: a write
    # waits for its tesseract.
    job spawn {
        0..<$STRIPS | par-each {|i|
            let s = $strips | get $i
            ($"P6\n($width) ($s.bottom - $s.top)\n255\n" | into binary) ++ (
                $image | bytes at ($pixels + $s.top * $row)..<($pixels + $s.bottom * $row)
            ) | save -f ($pipes | get $i)
        }
    }

    # The strips' lines in the order tesseract finishes them.
    0..<$STRIPS | each {
        let read = job recv
        let s = $strips | get $read.i
        $read.tsv
        | lines | skip 1
        | split column "\t" level page block par line word x y w h conf text
        | where {|w| $w.level == "5" and ($w.text | str trim) != "" }
        | each {|w|
            {
                line: $"($w.block).($w.par).($w.line)"
                text: $w.text
                x: ($w.x | into int)
                y: (($w.y | into int) + $s.top)
                w: ($w.w | into int)
                h: ($w.h | into int)
            }
        }
        # By the word, not the line: a line's middle moves with whatever
        # tesseract groups into it (an icon, words of a pane beside it), so two
        # strips could each place it in the other and both drop it.
        | where {|w| $w.y + $w.h / 2 >= $s.core and $w.y + $w.h / 2 < $s.core + $step }
        | group-by line | values
        | each {|words|
            $words | each {|w|
                { text: $w.text, x: ($w.x / $scale), y: ($w.y / $scale), w: ($w.w / $scale), h: ($w.h / $scale) }
            }
        }
    } | prepend [[]]
}
