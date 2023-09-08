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
) where

import           Control.Monad
import           Data.Time.Clock

import 		 System.IO.Unsafe

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

timeDiff :: NominalDiffTime
timeDiff = unsafePerformIO $ do
  t1 <- getCurrentTime
  t2 <- getCurrentTime
  return (diffUTCTime t1 t2)
 
