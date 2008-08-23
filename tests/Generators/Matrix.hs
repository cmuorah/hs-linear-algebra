-----------------------------------------------------------------------------
-- |
-- Module     : Generators.Matrix
-- Copyright  : Copyright (c) , Patrick Perry <patperry@stanford.edu>
-- License    : BSD3
-- Maintainer : Patrick Perry <patperry@stanford.edu>
-- Stability  : experimental
--

module Generators.Matrix
    where

import Test.QuickCheck
                
matrixSized :: (Int -> Gen a) -> Gen a
matrixSized f = 
    sized $ \s ->
        let s' = ceiling (sqrt $ fromInteger $ toInteger s :: Double)
        in f s'
        