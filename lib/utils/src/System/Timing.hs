-- |
-- Copyright   : (c) 2011 Simon Meier
-- License     : GPL v3 (see LICENSE)
--
-- Maintainer  : Simon Meier <iridcode@gmail.com>
-- Portability : GHC only
--
-- A simple module for timing IO action.
module System.Timing (
    timed
  , timed_
  , timeDiff
  , currentTimeforContext
  , timeOutforContext
  , checkTimeOver
) where

import           Control.Monad
import           Data.Time.Clock

import           System.IO.Unsafe

-- | Execute an IO action and return its result plus the time it took to execute it.
timed :: IO a -> IO (a, NominalDiffTime)
timed io = do
  t0 <- getCurrentTime
  x <- io
  t1 <- getCurrentTime
  return (x, diffUTCTime t1 t0)

-- | Execute an IO action and return the time it took to execute it.
timed_ :: IO a -> IO NominalDiffTime
timed_ = (snd `liftM`) . timed

currentTimeforContext :: UTCTime
currentTimeforContext = unsafePerformIO $ do
  t <- getCurrentTime
  return t

timeDiff :: UTCTime -> NominalDiffTime
timeDiff start = unsafePerformIO $ do
  t <- getCurrentTime
  return (diffUTCTime t start)
  
-- value of the Time Out in seconds
timeOutforContext :: NominalDiffTime
timeOutforContext = 30

checkTimeOver :: NominalDiffTime -> NominalDiffTime -> Bool
checkTimeOver now to = if now > to then True else False
