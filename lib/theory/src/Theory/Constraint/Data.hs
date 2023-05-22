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

import           Data.Label                           (mkLabels)

import           Theory.Constraint.System.Constraints
import           Theory.Constraint.Solver.Goals
import           Theory.Constraint.System

import           Theory.Model.Fact

import           Term.LTerm

-- Structure for csv

data DataSample = DataSample
    { _dsGoal             :: Maybe Goal
    , _dsAge              :: Integer
    , _dsUsefulness       :: Maybe Usefulness
    , _dsUseInduction     :: InductionHint
    , _dsTraceQuantifier  :: SystemTraceQuantifier
    }
    deriving( Eq, Ord, Show )

$(mkLabels [''DataSample])

-- Csv format : Age;Usefulness;UseInduction;TraceQuantifier;TypeGoal;TypeFact||NbSplit;TypeTerm ++NbOccurrenceLigne;Label add by the python script
prettyPrintDataSample :: DataSample -> String
prettyPrintDataSample (DataSample goal age use induction trace) = show age ++ ";" ++ show use ++ ";" ++ show induction ++ ";" ++ show trace ++ ";" ++ case goal of
    Just (ActionG _ (Fact tag _ term))   -> "Action" ++ ";" ++ show tag ++ ";" ++ show (map sortOfLNTerm term) ++ "\n"
    Just (ChainG _ _)                 -> "Chain" ++ ";Nothing;Nothing" ++ "\n"
    Just (PremiseG _ (Fact tag _ term))  -> "Premise" ++ ";" ++ show tag ++ ";" ++ show (map sortOfLNTerm term) ++ "\n"
    Just (SplitG i)                   -> "Split" ++ ";" ++ show i ++ ";Nothing\n"
    Just (DisjG _)                    -> "Disjonction" ++ ";Nothing;Nothing" ++ "\n"
    Nothing                           -> "Nothing;Nothing;Nothing" ++ "\n"