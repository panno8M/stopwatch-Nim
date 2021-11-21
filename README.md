Stopwatch
=========
This is a fork of https://gitlab.com/define-private-public/stopwatch


Examples
--------

Simple usage:

```nim
import stopwatch

var stopwatch: Stopwatch = newStopwatch()
start stopwatch

while true:
  # ... Long computation time
  if peek(stopwatch).inMilliseconds >= 1000: # You can peek current dial.
    echo "it costs 1000[ms] over!"
    break

stop stopwatch

let costs: Duration = stopwatch.lastLap
```


Using laps, record only the code you want to time:

```nim
import stopwatch
from sequtils import map

var stopwatch: StopwatchAccum = newStopwatchAccum()

# We're operating on a large image...
for y in 0..<imgHeight:
  for x in 0..<imgWidth:
    start stopwatch
    # ... lengthy pixel operation
    stop stopwatch

# Query an individual lap's time
let firstPixelTime: int64 = stopwatch.laps[0].inMilliseconds

# Total time (all laps) in microseconds
let micros: int64 = stopwatch.total.inMicroseconds

# Get each lap's time into seconds from nanoseconds (as a seq[float])
let lapsSecs: seq[int64] = stopwatch.laps.mapIt(it.inSeconds)
```