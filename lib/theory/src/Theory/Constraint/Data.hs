{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell    #-}
{-# LANGUAGE TypeOperators      #-}
{-# LANGUAGE ViewPatterns       #-}
{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE DeriveAnyClass     #-}
{-# LANGUAGE TypeSynonymInstances       #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE MultiParamTypeClasses      #-}


module Theory.Constraint.Data (

    DataSample(..),
    prettyPrintDataSample,
    dsGoal,
    dsAge,
    dsUsefulness,
    dsUseInduction,
    dsTraceQuantifier
  ) where

import           Prelude                              hiding (id, (.))

--import           Data.Label                           hiding (get, mkLabels)
import qualified Data.Label                           as L

import           Theory.Constraint.System.Constraints
import           Theory.Constraint.Solver.AnnotatedGoals
import           Theory.Constraint.System

import           Theory.Model.Fact

import           Term.LTerm

import           Logic.Connectives

-- Structure for csv

data DataSample = DataSample
    { _dsGoal             :: Maybe Goal
    , _dsAge              :: Integer
    , _dsUsefulness       :: Maybe Usefulness
    , _dsUseInduction     :: InductionHint
    , _dsTraceQuantifier  :: SystemTraceQuantifier

    }
    deriving( Eq, Ord, Show )

$(L.mkLabels [''DataSample])

fromMaybe :: a -> Maybe a -> a
fromMaybe x Nothing  = x
fromMaybe _ (Just y) = y

isUsingInduction :: InductionHint -> Bool
isUsingInduction UseInduction   = True
isUsingInduction AvoidInduction = False

vectorizeTraceQuantifier :: SystemTraceQuantifier -> Int
vectorizeTraceQuantifier ExistsNoTrace    = 0
vectorizeTraceQuantifier ExistsSomeTrace  = 1

-- Csv format : Age;Usefulness;UseInduction;TraceQuantifier;TypeGoal;TypeFact;TypeTerm;NbSplitDisj;Label
prettyPrintDataSample :: System -> DataSample -> String
prettyPrintDataSample sys (DataSample goal age use induction trace) = show age ++ ";" ++ show use ++ ";" ++ show (isUsingInduction induction) ++ ";" ++ show (vectorizeTraceQuantifier trace) ++ ";" ++ case goal of
    Just (ActionG _ (Fact tag _ term))   -> "Action" ++ ";-1;" ++ show tag ++ ";" ++ show (map sortOfLNTerm term) ++ "\n"
    Just (ChainG ccl _)                  -> "Chain" ++ ";-1;" ++ show (getFactTag $ nodeConcFact ccl sys) ++ ";" ++ show (map sortOfLNTerm $ getFactTerms $ nodeConcFact ccl sys) ++ "\n"
    Just (PremiseG _ (Fact tag _ term))  -> "Premise" ++ ";-1;" ++ show tag ++ ";" ++ show (map sortOfLNTerm term) ++ "\n"
    Just (SplitG i)                      -> "Split" ++ ";" ++ show (fromMaybe (-1) $ splitSize (L.get sEqStore sys) i) ++ ";NaN;NaN\n"
    Just (DisjG d)                       -> "Disj" ++ ";" ++ show (length $ getDisj d) ++ ";NaN;NaN\n"
    Nothing                              -> "Nothing;Nothing;Nothing;Nothing\n"