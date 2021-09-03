import Data.List (transpose)
import System.Environment

-- This is an infinite list of multiples of 3 and 5:
threesAndFives = concat . transpose $ [[3,18..], [5,20..], [6,21..], [9,24..], [10,25..], [12,27..], [15,30..]]

main = do
    a <- getArgs
    let n = read (head a) :: Int
    print . sum . takeWhile (< n) $ threesAndFives

