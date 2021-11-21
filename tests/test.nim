import unittest

from sequtils import map
import times
from os import sleep
import parseopt

import ../src/stopwatch


var
  sw: StopwatchAccum


test "stopwatch":
  sw = newStopwatchAccum()

  check sw.numRanLaps == 0
  check sw.numRunningLaps == 0
  check sw.total.inMilliseconds == 0

  sw.start()

  check sw.numRanLaps == 0
  check sw.numRunningLaps == 1

  sleep(1000)

  check sw.peek.inMilliseconds == 1000
  check sw.totalWithCurrent.inMilliseconds == 1000

  sw.stop()

  check sw.numRanLaps == 1
  check sw.numRunningLaps == 1
  check sw.peek.inMilliseconds == 1000
  check sw.totalWithCurrent.inMilliseconds == 1000

  sw.start()

  sleep(500)

  check sw.peek.inMilliseconds == 500
  check sw.totalWithCurrent.inMilliseconds == 1500

  sleep(500)

  check sw.peek.inMilliseconds == 1000
  check sw.totalWithCurrent.inMilliseconds == 2000

  sw.stop()

  check sw.peek.inMilliseconds == 1000
  check sw.totalWithCurrent.inMilliseconds == 2000


  sw.bench:
    sleep(1000)
  check sw.peek.inMilliseconds == 1000
