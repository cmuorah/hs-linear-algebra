{-# OPTIONS_HADDOCK hide #-}
-----------------------------------------------------------------------------
-- |
-- Module     : Test.Matrix.Herm.Banded
-- Copyright  : Copyright (c) , Patrick Perry <patperry@stanford.edu>
-- License    : BSD3
-- Maintainer : Patrick Perry <patperry@stanford.edu>
-- Stability  : experimental
--

module Test.Matrix.Herm.Banded (
    HermBanded(..),
    HermBandedMV(..),
    HermBandedMM(..),
    ) where

import Control.Monad ( liftM, replicateM )

import Test.QuickCheck hiding ( Test.vector )
import Test.QuickCheck.BLAS ( TestElem )
import qualified Test.QuickCheck.BLAS as Test

import Data.Elem.BLAS ( Elem, BLAS1, BLAS3, fromReal, conjugate )

import Data.Vector.Dense ( Vector )
import Data.Matrix.Banded
import Data.Matrix.Dense ( Matrix )
import Data.Matrix.Herm

listsFromBanded :: (Elem e) => Banded np e -> ((Int,Int), (Int,Int),[[e]])
listsFromBanded a = ( (m,n)
            , (kl,ku)
            , map paddedDiag [(-kl)..ku]
            )
  where
    (m,n)   = shape a
    (kl,ku) = bandwidths (coerceBanded a)
    
    padBegin i   = replicate (max (-i) 0)    0
    padEnd   i   = replicate (max (m-n+i) 0) 0
    paddedDiag i = (  padBegin i
                   ++ elems (diagBanded (coerceBanded a) i) 
                   ++ padEnd i 
                   )
                   



hermBanded :: (TestElem e) => Int -> Int -> Gen (Banded (n,n) e)
hermBanded n k 
    | n < 0 = 
        error $ "hermBanded: n must be non-negative"
    | n == 0 =
        return $ listsBanded (0,0) (0,0) []
    | k >= n =
        error $ "hermBanded: k must be less than n"
    | k < 0 = 
        error $ "hermBanded: k must be non-negative"
    | k == 0 = do
        d <- Test.realElems n
        return $ listsBanded (n,n) (0,0) [d]
    | otherwise = do
        a <- hermBanded n (k-1)
        let (_,_,ds) = listsFromBanded a
        
        d <- Test.elems (n-k)
        let d'  = map conjugate d
            pad = replicate k 0
            ds' = [pad ++ d] ++ ds ++ [d' ++ pad]

        return $ listsBanded (n,n) (k,k) ds'

data HermBanded n e =
    HermBanded (Herm Banded (n,n) e)
               (Banded (n,n) e)
    deriving Show
    
instance (TestElem e) => Arbitrary (HermBanded n e) where
    arbitrary = do
        n <- liftM fst Test.shape
        k <- if n == 0 then return 0 else choose (0,n-1)
        l <- if n == 0 then return 0 else choose (0,n-1)
            
        a <- hermBanded n k
            
        junk <- replicateM l $ Test.elems n
        let (_,_,ds) = listsFromBanded a
            (u ,b ) = (Upper, listsBanded (n,n) (l,k) $ junk ++ (drop k ds))
            (u',b') = (Lower, listsBanded (n,n) (k,l) $ (take (k+1) ds) ++ junk)
        
        h <- elements [ hermFromBase u             b
                      , hermFromBase (flipUpLo u)  (herm b)
                      , hermFromBase u'            b'
                      , hermFromBase (flipUpLo u') (herm b')
                      ]
            
        return $ HermBanded h a

    coarbitrary = undefined

data HermBandedMV n e = 
    HermBandedMV (Herm Banded (n,n) e) 
                 (Banded (n,n) e) 
                 (Vector n e) 
    deriving Show

instance (TestElem e) => Arbitrary (HermBandedMV n e) where
    arbitrary = do
        (HermBanded h a) <- arbitrary
        x <- Test.vector (numCols a)
        return $ HermBandedMV h a x

    coarbitrary = undefined
    
    
data HermBandedMM m n e = 
    HermBandedMM (Herm Banded (m,m) e) 
                 (Banded (m,m) e) 
                 (Matrix (m,n) e) 
    deriving Show
    
instance (TestElem e) => Arbitrary (HermBandedMM m n e) where
    arbitrary = do
        (HermBanded a h) <- arbitrary
        (_,n) <- Test.shape
        b <- Test.matrix (numCols h,n)

        return $ HermBandedMM a h b
            
    coarbitrary = undefined
