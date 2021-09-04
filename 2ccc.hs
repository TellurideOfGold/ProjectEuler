import System.Environment

-- Persistant infinite list of *even* fibonacci numbers:
efibs = 0 : 2 : zipWith (+) efibs ((map (4 *) . tail) efibs)

main = do
    a <- getArgs
    let n = ((2^) . read . head) a :: Integer
    print . sum . takeWhile (< n) $ efibs

