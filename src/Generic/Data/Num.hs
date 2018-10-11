{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses, UndecidableInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Generic.Data.Num where

import Prelude ()
import qualified Prelude

infixl 6 +
infixl 7 *
infixl 6 -
  
class Num j a where
  (+)         :: j a -> j a -> j a
  (-)         :: j a -> j a -> j a
  (*)         :: j a -> j a -> j a
  fromInteger :: Prelude.Integer -> j a

-- Terrible hack to get number literals working.

-- newtype AG g = AG { fromAG :: g }

-- instance Num AG a where
--   (+)    = Prelude.undefined
--   (-)    = Prelude.undefined
--   (*)    = Prelude.undefined
--   fromInteger = fromInteger
  

-- instance {-# OVERLAPPED #-} Prelude.Show (j a) where show _ = "num"
-- instance Prelude.Eq   (j a) where
-- instance {-# OVERLAPPED #-} Num j a => Prelude.Num  (j a) where
--   (+)    = Prelude.undefined
--   (*)    = Prelude.undefined
--   abs    = Prelude.undefined
--   signum = Prelude.undefined
--   fromInteger = fromInteger
