{-# LANGUAGE MultiParamTypeClasses, FlexibleContexts #-}
-----------------------------------------------------------------------------
-- |
-- Module     : Data.Tensor.Class.ITensor
-- Copyright  : Copyright (c) , Patrick Perry <patperry@stanford.edu>
-- License    : BSD3
-- Maintainer : Patrick Perry <patperry@stanford.edu>
-- Stability  : experimental
--
-- Overloaded interface for immutable tensors.

module Data.Tensor.Class.ITensor (
    ITensor(..),
    (!),
    ) where

import Data.Tensor.Class
import Data.Ix


infixl 9 !
infixl 7 *>
infixl 5 `shift`


-- | A class for immutable tensors.
class (Shaped x i e) => ITensor x i e where
    -- | Get the numer of elements stored in the tensor.
    size :: x n e -> Int
    
    -- | Get a new tensor by replacing the elements at the given indices.
    (//) :: x n e -> [(i,e)] -> x n e

    -- | Get the value at the given index, without doing any bounds-checking.
    unsafeAt :: x n e -> i -> e
    
    -- | Same as '(//)' but doesn't do any bounds-checking.
    unsafeReplace :: x n e -> [(i,e)] -> x n e
    
    -- | Get the indices of the elements stored in the tensor.
    indices :: x n e -> [i]
    
    -- | Get the elements stored in the tensor.
    elems :: x n e -> [e]
    elems = snd . unzip . assocs

    -- | Get the list of @(@index@,@ element@)@ pairs stored in the tensor.
    assocs :: x n e -> [(i,e)]

    -- accum :: (e -> e' -> e) -> x e -> [(i,e')] -> x e
    
    -- | Apply a function elementwise to a tensor.
    tmap :: (e -> e) -> x n e -> x n e
    
    -- ixmap :: i -> (i -> i) -> x e -> x e
    -- unsafeIxMap
    
    -- | Scale every element by the given value.
    (*>) :: (Num e) => e -> x n e -> x n e
    (*>) k = tmap (k*)
    
    -- | Add a constant to every element.
    shift :: (Num e) => e -> x n e -> x n e
    shift k = tmap (k+)    
    
-- | Get the value at the given index.  Range-checks the argument.
(!) :: (ITensor x i e) => x n e -> i -> e
(!) x i =
    case (inRange b i) of
        False -> 
            error $ "tried to get element at a index `" ++ show i ++ "'"
                    ++ " in an object with shape `" ++ show s ++ "'"
        True -> 
            unsafeAt x i
  where
    b = bounds x
    s = shape x