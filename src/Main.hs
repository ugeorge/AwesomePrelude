module Main where

import Compiler.Pipeline
import Generic.Prelude
import Lang.JavaScript
import Lang.Haskell
import qualified Prelude as P

three :: JavaScript Number
three = 3

jsMap :: JavaScript [Number]
jsMap = map (\x -> x+5) ((singleton 3) ++ (singleton 3)) --(replicate three (2 * 8) ++ replicate three 8) * maybe 4 (*8) (just (3 - 2))

hsMap :: Haskell [P.Integer]
hsMap = map (\x -> x+5) ((singleton 3) ++ (singleton 3)) --(replicate three (2 * 8) ++ replicate three 8) * maybe 4 (*8) (just (3 - 2))


main :: P.IO ()
main = do
  js <- compiler jsMap
  -- P.putStrLn $ P.show $ runHaskell hsMap
  P.writeFile "test.js" js

