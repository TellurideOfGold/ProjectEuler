import System.Environment

-- Quick 'n dirty 2x2 matrix type:
data SqMat2 a = SqMat2 a a a a
{-
Element order is as follows:
    SqMat2 a b c d = a b
                     c d

In fact, haskell will allow this layout:
    SqMat2
        a b
        c d

Which I will occasionally use for clarity.
-}

-- And a quick 'n dirty Num instance to go with it (just ignore the "warning: [-Wmissing-methods]"):
instance (Num a) => Num (SqMat2 a) where

    -- Shockingly we only need to implement these two functions for "^" to work!
    -- You could try to implement the rest, but abs and signum may you cause some trouble.

    fromInteger n =
        let m = fromInteger n
        in  SqMat2 m m m m

    (*) (SqMat2 a0 b0 c0 d0) (SqMat2 a1 b1 c1 d1) =
        SqMat2
            (a0 * a1 + b0 * c1) (a0 * b1 + b0 * d1)
            (c0 * a1 + d0 * c1) (c0 * b1 + d0 * d1)

-- Black magic:
efib 0 = 0
efib n = (\ (SqMat2 a _ _ _) -> 2 * a) . ((SqMat2 4 1 1 0)^) $ n - 1

-- For clarity let's move the sum calculation out of the main function:
efibSum n = flip quot 4 $ efib n + efib (n + 1)

-- Binary search over monotonic ascending functions:
bSearch f t l u =
    case 1 == u - l of
        True  -> l
        False -> let m = quot (l + u) 2 in
            case compare (f m) t of
                LT -> bSearch f t m u
                EQ -> m
                GT -> bSearch f t l m

-- Exponential search over the same:
expSearch f t =
    let (l, u) = until
            (\ (_, u) -> f u > t)
            (\ (l, u) -> (u, 2 * u))
            (0, 1)
    in  bSearch f t l u

main = do
    a <- getArgs
    let n = (expSearch efib . (2^) . read . head) a :: Integer -- Find the largest efib less than the input.
    print . efibSum $ n -- Print the answer!

