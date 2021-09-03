import System.Environment

-- Sum from 1 to n (thanks, Gauss):
sum1To n = quot (n * (n + 1)) 2

-- Sum of multiples of m from m to n:
sumMultiplesOfTo m n = m * sum1To (quot n m)

-- Add it all up, making sure to subtract out the duplicates:
threesAndFivesToN n =
    let n' = n - 1
    in  (sumMultiplesOfTo 3 n') + (sumMultiplesOfTo 5 n') - (sumMultiplesOfTo 15 n')

main = do
    a <- getArgs
    let n = read (head a) :: Integer
    print $ threesAndFivesToN n

