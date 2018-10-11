{-# LANGUAGE FlexibleContexts, FlexibleInstances, MultiParamTypeClasses, OverlappingInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Generic.Data.List where

import Prelude ()
import Generic.Data.Bool
import Generic.Data.Eq
import Generic.Data.Num
import Generic.Data.Ord
import Generic.Control.Function
import Generic.Control.Functor

import qualified Prelude

-- data List a
-- instead of `List a`, use `[a]`

class ListC j where
  nil  :: j [a]
  cons :: j a -> j [a] -> j [a]
  list :: j r -> (j a -> j [a] -> j r) -> j [a] -> j r

instance (BoolC j, ListC j, Eq j a) => Eq j [a] where
  xs == ys = list (list true (\_ _ -> false) ys)
                  (\x xs' -> list false (\y ys' -> x == y && xs' == ys') ys)
                  xs

instance (BoolC j, ListC j, Ord j a) => Ord j [a] where
  xs <= ys = list true -- (list true (\_ _ -> true) ys)
                  (\x xs' -> list false (\y ys' -> x <= y || xs' <= ys') ys)
                  xs

instance (RecFunC j, ListC j) => Functor j [] where
  fmap f = foldr (\a r -> f a `cons` r) nil


-- one :: Num j a => AG (j a)
-- one = AG (1 :: Prelude.Integer)

-- zero :: Num j a => AG (j a)
-- zero = AG 0


singleton :: ListC j => j a -> j [a]
singleton a = a `cons` nil

map :: (ListC j, RecFunC j) => (j a -> j b) -> j [a] -> j [b]
map f = foldr (\y ys -> f y `cons` ys) nil

foldr :: (RecFunC j, ListC j) => (j a -> j b -> j b) -> j b -> j [a] -> j b
foldr f b xs = fix (\r -> lam (list b (\y ys -> f y (r `app` ys)))) `app` xs

foldr' :: (RecFunC j, ListC j) => j (a -> b -> b) -> j b -> j [a] -> j b
foldr' f b xs = fix (\r -> lam (list b (\y ys -> f `app` y `app` (r `app` ys)))) `app` xs

-- replicate :: (Eq j a, BoolC j, RecFunC j, ListC j, Num j a) => j a -> j b -> j [b]
-- replicate n a = fix (\r -> lam (\y -> bool nil (a `cons` (r `app` (y - (fromAG one)))) (y == (fromAG 0)))) `app` n

(++) :: (RecFunC j, ListC j) => j [a] -> j [a] -> j [a]
xs ++ ys = foldr cons ys xs

-- genericLength :: (RecFunC j, ListC j, Num j a) => j [b] -> j a
-- genericLength = foldr (\_ -> (+1)) 0

-- sum :: (RecFunC j, ListC j, Num j a) => j [a] -> j a
-- sum = foldr (+) 0

filter :: (BoolC j, RecFunC j, ListC j) => (j a -> j Bool) -> j [a] -> j [a]
filter p = foldr (\x xs -> bool xs (x `cons` xs) (p x)) nil

reverse :: (RecFunC j, ListC j) => j [a] -> j [a]
reverse l = rev `app` l `app` nil
  where
    rev = fix (\r -> lam (\xs -> lam (\a -> list a (\y ys -> r `app` ys `app` (y `cons` a)) xs)))

and :: (BoolC j, RecFunC j, ListC j) => j [Bool] -> j Bool
and = foldr (&&) true

or :: (BoolC j, RecFunC j, ListC j) => j [Bool] -> j Bool
or = foldr (||) true

