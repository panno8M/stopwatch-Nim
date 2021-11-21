{.experimental: "strictFuncs".}

import std/times
import std/options

export times

# The Stopwatch object
type
  Stopwatch* = object
    startTime: Option[Time]
    lastLap: Duration
  StopwatchAccum* = object
    sw: Stopwatch
    laps: seq[Duration]
    total: Duration


converter sw*(this: StopwatchAccum): lent Stopwatch = this.sw
converter sw*(this: var StopwatchAccum): var Stopwatch = this.sw

func newStopwatch*(): Stopwatch {.inline.} = Stopwatch()
func newStopwatchAccum*(): StopwatchAccum {.inline.} = StopwatchAccum()

#=====================#
#== Stopwatch procs ==#
#=====================#

func isRunning*(sw: var Stopwatch): bool =
  ## Checks to see if the Stopwatch is measuring time.
  sw.startTime.isSome

func lastLap*(this: Stopwatch): lent Duration = this.lastLap
func laps*(this: StopwatchAccum): lent seq[Duration] = this.laps

proc start*(this: var Stopwatch) =
  ## Makes the Stopwatch measure time.  Will do nothing if the Stopwatch is
  ## already doing that.
  # If we are already running, ignore
  if this.startTime.isNone: this.startTime = some getTime()
  
proc peek*(this: var Stopwatch): Duration =
  ## This will return the length of the current lap (if `stop()` has not been called)
  if not this.isRunning: this.lastLap
  else: getTime() - this.startTime.get()


proc stop*(this: var Stopwatch) =
  ## Makes the Stopwatch stop measuring time.  It will record the lap it has
  ## taken.  If the Stopwatch wasn't running before, nothing will happen
  try:
    this.lastLap = this.peek
    this.startTime = none Time
  except UnpackDefect: return

proc reset*(this: var Stopwatch) =
  ## Clears out the state of the Stopwatch.
  this.addr.zeroMem(this.sizeof)


func total*(this:  StopwatchAccum): lent Duration =
  this.total

proc totalWithCurrent*(this: var StopwatchAccum): Duration =
  if this.isRunning: this.total + this.peek
  else: this.total

proc stop*(this: var StopwatchAccum) =
  this.sw.stop()

  this.laps.add this.lastLap
  this.total += this.lastLap

proc restart*(this: var Stopwatch) =
  ## This function will clear out the state of the Stopwatch and tell it to start
  ## recording time.  It is the same as calling reset() then start().
  reset this
  this.start()

proc init*(this: var StopwatchAccum) =
  ## Clears out the state of the Stopwatch.  This deletes all of the lap data.
  this.addr.zeroMem(this.sizeof)

func numRanLaps*(this: var StopwatchAccum): int =
  ## Returns the number of laps the Stopwatch has recorded so far.
  this.laps.len

func numRunningLaps*(this: var StopwatchAccum): int =
  ## Returns the number of laps the Stopwatch has recorded so far.
  ## It will include the current lap in the count.
  this.numRanLaps + this.sw.startTime.isSome.int

proc eraseLapAt*(this: var StopwatchAccum; idx: int) =
  ## Removes a lap from the Stopwatch's record with the given index of `num`.
  ## This function has the possibility of raising an `IndexError`.
  this.total -= this.laps[idx]
  this.laps.delete(idx)

proc clearLaps*(this: var StopwatchAccum) =
  ## This clears out all of the lap records from a Stopwatch.  This will not
  ## effect the current lap (if one is being measured).
  this.laps.setLen(0)
  reset this.total


# Templates ====================================================================

template bench*(this: var Stopwatch; body: untyped): untyped =
  ## A simple template that will wrap the `start()` and `stop()` calls around
  ## a block of code.  Make sure that the passed in Stopwatch has been
  ## initialized.  Even if the Stopwatch is already running, it won't stop
  ## the Stopwatch.
  this.start()
  body
  this.stop()

template bench*(this: var StopwatchAccum; body: untyped): untyped =
  ## A simple template that will wrap the `start()` and `stop()` calls around
  ## a block of code.  Make sure that the passed in Stopwatch has been
  ## initialized.  Even if the Stopwatch is already running, it won't stop
  ## the Stopwatch.
  this.start()
  body
  this.stop()