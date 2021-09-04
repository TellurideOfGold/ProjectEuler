import System.Environment
import Data.Function (fix)

-- Persistant infinite list of fibonacci numbers:
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

main = do
    a <- getArgs
    let n = ((2^) . read . head) a :: Integer
    print . sum . takeWhile (< n) . fix (\ r (a:b:c:as) -> a : r as) $ fibs

