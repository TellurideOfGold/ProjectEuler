import System.Environment

-- Problem 1 asks us to find the sum of all the multiples of 3 and 5 below 1000. This program will find that sum for any positive bound.
-- This version is "cheating" using a trick from  the great mathematician Gauss. Much faster than adding all the multiples individually.
-- As a point of reference, the simple version takes about 8 seconds on my machiene for an input of 1000000000. This version is instant.

-- Sum from 1 to n (thanks, Gauss):
sum1To n = quot (n * (n + 1)) 2

-- Sum of multiples of m from m to n:
sumMultiplesOfTo m n = m * sum1To (quot n m)

-- Add it all up, making sure to subtract out the duplicates:
threesAndFivesToN n = let n' = n - 1 in (sumMultiplesOfTo 3 n') + (sumMultiplesOfTo 5 n') - (sumMultiplesOfTo 15 n')

main = do
    a <- getArgs
    let n = read (head a) :: Int
    print $ threesAndFivesToN n

