import System.Environment

-- The previous implimentation will recompute the same value several times, wasting a huge amount of computation.
-- The solution is to cache previous values in an optimization called memoization.
-- In some languages this might be a bit of a challange, but in this one we have lazy infinite datastructures.

-- The "lazy" here means that a value will not be computed untill it is actually needed.
-- If were to make an infinite list of items but only ask for the first the rest will never be computed.
-- Likewise, if we map a function over an infinite list nothing will be applyed untill the item in question is needed.

-- All of this means that we can memoize recursively defined functions by like so:
fib =
    (map fib' [0..] !!)
    where
        fib' 0 = 0
        fib' 1 = 1
        fib' n = fib (n - 1) + fib (n - 2)

-- Now when fib is called each recursive call will only need to be evaluated the first time it is asked for.
-- The gain in speed is appreciable.
-- The previous solution required 0.800 seconds to find the solution for an input of 4000000 (the bound in the origional puzzle).
-- This solution takes 

main = do
    a <- getArgs
    let n = read (head a) :: Int
    print . sum . takeWhile (< n) . map fib $ [0,3..] -- infinite list of multiples of 3

