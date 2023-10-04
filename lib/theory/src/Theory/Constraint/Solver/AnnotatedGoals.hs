-- |
-- Copyright   : (c) 2010-2012 Simon Meier, Benedikt Schmidt
--               contributing in 2019: Robert Künnemann, Johannes Wocker
-- License     : GPL v3 (see LICENSE)
--
-- Maintainer  : Simon Meier <iridcode@gmail.com>
-- Portability : portable
--
-- Exporting the object AnnotatedGoal to make it accessible by Heuristic.hs, System.hs and Signature.hs

module Theory.Constraint.Solver.AnnotatedGoals
  ( Usefulness(..)
  , AnnotatedGoal
  )
where


-- import           Control.DeepSeq

-- import           Data.Binary

import           Theory.Constraint.System.Constraints

-- import           Term.LTerm


data Usefulness =
    Useful
  -- ^ A goal that is likely to result in progress.
  | LoopBreaker
  -- ^ A goal that is delayed to avoid immediate termination.
  | ProbablyConstructible
  -- ^ A goal that is likely to be constructible by the adversary.
  | CurrentlyDeducible
  -- ^ A message that is deducible for the current solution.
  deriving (Show, Eq, Ord)

-- instance NFData Usefulness where
--     rnf _ = ()

-- instance Binary Usefulness where
--     put     = putWord8 . fromIntegral . fromEnum
--     get     = getWord8 >>= toUsefulness
--       where
--         toUsefulness 0 = return Useful
--         toUsefulness 1 = return LoopBreaker
--         toUsefulness 2 = return ProbablyConstructible
--         toUsefulness 3 = return CurrentlyDeducible
--         toUsefulness c = fail ("Could not map value " ++ show c ++ " to Usefulness")

-- instance HasFrees Usefulness where
--     foldFrees = const mempty
--     foldFreesOcc  _ _ = const mempty
--     mapFrees  = const pure

-- | Goals annotated with their number and usefulness.
type AnnotatedGoal = (Goal, (Integer, Usefulness))