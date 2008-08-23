{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}
-----------------------------------------------------------------------------
-- |
-- Module     : BLAS.Tensor.Dense.Read
-- Copyright  : Copyright (c) , Patrick Perry <patperry@stanford.edu>
-- License    : BSD3
-- Maintainer : Patrick Perry <patperry@stanford.edu>
-- Stability  : experimental
--

module BLAS.Numeric.Read (
    ReadNumeric,
    ) where

import BLAS.Elem
import BLAS.Tensor.Read

class (Elem e, ReadTensor x i e m) => ReadNumeric x i e m
