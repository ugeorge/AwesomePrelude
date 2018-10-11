{-# LANGUAGE MultiParamTypeClasses, TypeOperators #-}

module Generic.Control.Category where

import Prelude ()

infixr 9 .

class Category j k where
  id  :: (j a `k` j a)
  (.) :: (j b `k` j c) -> (j a `k` j b) -> (j a `k` j c)

