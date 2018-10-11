{-# LANGUAGE StandaloneDeriving, TypeOperators, FlexibleInstances #-}

module Compiler.LiftDefinitions 
( DefinitionA (..)
, Definition
, DefinitionsA (..)
, Definitions
, lift
, eliminiateDoubles
, dump
)
where

import Compiler.Generics
import Compiler.Expression 
import Control.Arrow hiding (app)
import Data.List (intercalate, nubBy)

data DefinitionA a = Def 
  { defName :: String
  , defExpr :: FixA a ExpressionF
  }

newtype DefinitionsA a = Defs { unDefs :: [DefinitionA a] }

type Definition  = DefinitionA  Id
type Definitions = DefinitionsA Id

deriving instance Eq (DefinitionA  Id)
deriving instance Eq (DefinitionsA Id)

-- All named sub-expressions will be replaces by a variables that references
-- the definition that will be created. All named sub-expression MUST NOT
-- contain any free variables.

inline :: Expression -> Expression
inline = foldId (In . Id . fmap defs)
  where
  defs (In (Id (Name n _))) = var n
  defs e                    = e

-- Collect all definitions from an expression tree and return a map with
-- name/definition pairs. Because of the Map datatype all duplicate definitions
-- will be joined to a single one.

collect :: Expression -> [Definition]
collect = reduce defs
  where
  defs (Name n d) = [Def n d]
  defs _          = []

-- Lift all definitions to the top-level and inline all references to these
-- definitions in the main expression.

lift :: Arrow k => Expression `k` Definitions
lift = arr (\e -> Defs (collect e ++ [Def "__main" (inline e)]))

eliminiateDoubles :: Arrow k => Definitions `k` Definitions
eliminiateDoubles = arr (Defs . nubBy (\a b -> defName a == defName b) . unDefs)

dump :: Arrow k => Definitions `k` String
dump = arr (intercalate "\n" . map one . unDefs)
  where
    one (Def d e)  = "var " ++ d ++ " = " ++ rec e

    tr (App  f e ) = rec f ++ "(" ++ rec e ++ ")"
    tr (Con  c   ) = c
    tr (Prim s vf) = s vf
    tr (Lam  as e) = "function (" ++ intercalate ", " as ++ ") { return " ++ rec e ++ ";" ++ " }"
    tr (Var  v   ) = v
    tr (Name n e ) = "/* " ++ n ++ " */ " ++ rec e

    rec = tr . unId . out

