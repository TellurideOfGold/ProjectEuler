import System.Environment

-- Problem 2 asks us to find the sum of the even fibonacci numbers below some given size bound.
-- The fibonacci sequence is defined as the following recurrence relation:
-- F(0) = 0
-- F(1) = 1
-- F(n) = F(n-1) + F(n-2)

-- From this definition it should be clear that every 3rd number will be even: 
-- even + odd  = odd;
-- odd  + odd  = even;
-- odd  + even = odd;
-- even + odd  = odd
-- So we don't actually need to check every number. We can simply use every 3rd fibonacci number.

-- The direct translation will work, but is rediculously slow:
fib 0 = 0
fib 1 = 1
fib n = fib (n - 1) + fib (n - 2)

main = do
    a <- getArgs
    let n = read (head a) :: Int
    print . sum . takeWhile (< n) . map fib $ [0,3..] -- infinite list of multiples of 3

