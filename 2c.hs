import System.Environment

-- Now with memoization!
fib =
    (map fib' [0..] !!)
    where
        fib' 0 = 0
        fib' 1 = 1
        fib' n = fib (n - 1) + fib (n - 2)

main = do
    a <- getArgs
    let n = read (head a) :: Integer
    print . sum . takeWhile (< n) . map fib $ [0,3..] -- infinite list of multiples of 3

