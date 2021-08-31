import Data.List (transpose)
import System.Environment

-- Problem 1 asks us to find the sum of all the multiples of 3 and 5 below 1000. This program will find that sum for any positive bound.

-- This is adding all the multiples below some limit from an infinite list:
threesAndFives = concat . transpose $ [[3,18..], [5,20..], [6,21..], [9,24..], [10,25..], [12,27..], [15,30..]]

main = do
    a <- getArgs
    let n = read (head a) :: Int
    print . sum . takeWhile (< n) $ threesAndFives

