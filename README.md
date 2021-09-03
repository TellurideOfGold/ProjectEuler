



[TOC]



# Project Euler

------

## About

These are solutions to ProjectEuler.net puzzles, but slightly generalized. For those who may be unfamiliar, the puzzles are typically set up with some variable or bound that is low for an initial example and then raised for the actual puzzle. In these solutions the program takes that bound as its input, and will typically work even for much larger bounds than those given in the puzzle.

There is often more than one way to solve these puzzles, and the different methods can vary wildly in time and space performance. For puzzles where this is the case, there will be more than one solution posted: an initial solution that works and is easy to understand, followed by versions that improve the performance of the program. In the interest of not having more comment than code in each file, I will be explaining the algorithms used in each file in a dedicated section below.

------

## Problem 1

### Initial Solution (1.hs)

Problem 1 asks us to find the sum of all the multiples of 3 or 5 below some bound (1,000 in the problem statement). Haskell has infinite datastructures, so a very straightforward solution would be to make an infinite list of all the multiples of 3 or 5 and add them up until one of them reaches the bound.

First let's make our infinite list. The multiples of two coprime integers will form a pattern in which some basis repeats over and over, increasing each time by the product of said integers. In the case of 3 and 5, that pattern looks a bit like this:

```pseudocode
3,    5,    6, 	  9,    10,    12,    15,
3+15, 5+15, 6+15, 9+15, 10+15, 12+15, 15+15,
…
```

We can make each column of this solution with a simple infinite list like so ```[n,n+15..]``` and if we put these lists in another list we end up with something like this:

```haskell
[ [3 ,18..]
, [5 ,20..]
, [6 ,21..]
, [9 ,24..]
, [10,25..]
, [12,27..]
, [15,30..]
]
```

You'll notice that our goal from above looks like an infinite list of finite sublists, while what we just built is a finite list of infinite sublists. Element 0 0 is 3 as it should be, but element 0 1 is 18 instead of 5. This can be fixed by calling ```transpose :: [[a]] -> [[a]]``` on the above list. Finally, we can 'flatten' the list of lists to a plain list using ```concat :: [[a]] -> [a]```. All that remains is to add up all the elements smaller than the bound.

```haskell
import Data.List (transpose)
import System.Environment

-- This is an infinite list of multiples of 3 and 5:
threesAndFives = concat . transpose $ [[3,18..], [5,20..], [6,21..], [9,24..], [10,25..], [12,27..], [15,30..]]

main = do
    a <- getArgs
    let n = read (head a) :: Int
    print . sum . takeWhile (< n) $ threesAndFives
```



### Cheat 1 (1c.hs)

The above solution works, but there's a much faster way. Wouldn't it be neat if we 

One day in the 1700's, the someday to be legendary mathematician Carl Friedrich Gauss was an 8 year old student of elementary school. His teacher, probably hoping to keep his young charges occupied for a while, instructed the class to add up all the numbers from 1 to 100. But in just a moment, Gauss found the answer! And this s what he saw:

If you list out all the numbers from 1 to 100, you can arrange them into 50 pairs that all sum to 101:

```pseudocode
1   + 100   = 101
2   + 99    = 101
3   + 98    = 101
…
48  + 53    = 101
49  + 52    = 101
50  + 51    = 101
```

In fact this can be done with any upper limit, giving rise to the following formula:

$$
\sum_{x=1}^nx=\frac{n(n+1)}{2}
$$

We can easily translate this into a short Haskell function: ```sum1To n = quot (n * (n + 1)) 2```. Multiplying each term of a summation by a constant is the same as multiplying the total by that constant, so a function to find the sum of multiples of a number below some limit is trivial: ```sumMultiplesOfTo m n = m * sum1To (quot n m)```. Note that we divide the bound by the multiplier before passing it to the ```sum1To``` function!

Finally, we can write the solution. Add the sum of multiples of 3 to the sum of multiples of 5, but since the multiples of 15 show up in *both* lists we need to subtract out the "duplicates":

```haskell
threesAndFivesToN n =
    let n' = n - 1
    in  (sumMultiplesOfTo 3 n') + (sumMultiplesOfTo 5 n') - (sumMultiplesOfTo 15 n')
```

Also note that we subtract 1 from the input; this is because our function has an inclusive upper bound while the problem is posed with an exclusive upper bound.

And that's that! This version is much faster than the previous one. 1.hs (compiled woth -O2) takes 8.532s on my machine for an input of 1,000,000. 1c.hs is almost instant (0.020s) and will happily churn out answers thousands of digits long.

```haskell
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
```



------

## Problem 2

### Initial Solution (2.hs)

Problem 2 asks us to find the sum of the even fibonacci numbers whose value stays below some bound (4,000,000 in the problem statement). The fibonacci sequence is defined with the following recurrence relation:

$$
F_0 = 0 \\

F_1 = 1 \\

F_n = F_{n-1} + F_{n-2}
$$

(the problem starts the sequence with 1 and 2 but this will not affect the value of the answer)

From this definition it should be clear that every 3rd number will be even:

```pseudocode
even + odd  = odd
       odd  + odd  = even
              odd  + even = odd
                     even + odd  = odd
–––––––––––––––––––––––––––––––––––––––
even,  odd,   odd,   even,  odd,   odd…
```

So we don't actually need to check every number. We can simply use every 3rd fibonacci number.

A direct translation of the recurrence relation from earlier into Haskell will work, but is ridiculously slow:

```haskell
import System.Environment

-- The direct translation:
fib 0 = 0
fib 1 = 1
fib n = fib (n - 1) + fib (n - 2)

main = do
    a <- getArgs
    let n = read (head a) :: Int
    print . sum . takeWhile (< n) . map fib $ [0,3..] -- infinite list of multiples of 3
```



### Cheat 1 (2c.hs)

The previous solution is tragically slow. Why? Lets try at evaluating ```fib 5``` manually:

```haskell
fib 5 -- evaluate fib 5
fib 4 + fib 3 -- now fib 3
fib 4 + (fib 2 + fib 1) -- fib 1 is a known value!
fib 4 + (fib 2 + 1) -- now fib 2
fib 4 + ((fib 1 + fib 0) + 1) -- more stuff to simplify!
fib 4 + ((1 + 0) + 1) -- add to reduce clutter
fib 4 + 2 -- now fib 4
(fib 3 + fib 2) + 2 -- now fib 2 again 
(fib 3 + (fib 1 + fib 0)) + 2 -- you know the drill
(fib 3 + (1 + 0)) + 2
(fib 3 + 1) + 2 -- now fib 3 again
((fib 2 + fib 1) + 1) + 2
((fib 2 + 1) + 1) + 2 -- now fib 2 *again* again
(((fib 1 + fib 0) + 1) + 1) + 2
(((1 + 0) + 1) + 1) + 2 -- no more fib! just do some addition, and…
5 -- DONE!
```

In this evaluation ```fib 3``` was evaluated 2 times and ```fib 2``` was evaluated 3 times. I'm not going to go through it here (at least in part because there isn't enough space) but this gets worse and worse as the input grows larger, and after a while almost all the work being done is redundant! ```fib``` would be way faster if it wasn't recomputing the same values over and over again. Fortunately, there's a pretty simple solution: memoization.

Memoization produces a cache when the function is called to store values once they are computed. This way, when you call ```fib {big number}``` it will only evaluate ```fib {smaller number}``` once. The rest of the potentially thousands of times it might be needed the computed value is just pulled from the cache. This is extremely helpful for large inputs, but even our tiny example from earlier gets a bit faster from this:

```haskell
fib 5 -- evaluate fib 5
fib 4 + fib 3 -- now fib 3
fib 4 + (fib 2 + fib 1) -- fib 1 is a known value!
fib 4 + (fib 2 + 1) -- now fib 2
fib 4 + ((fib 1 + fib 0) + 1) -- more stuff to simplify!
fib 4 + ((1 + 0) + 1) -- add to reduce clutter
fib 4 + 2 -- now fib 4
(fib 3 + fib 2) + 2 -- hey, we've seen fib 2 before! it was 1
(fib 3 + 1) + 2 -- we've seen fib 3 before too! it was 2
(2 + 1) + 2
5 -- DONE!
```

Notice that even though the value of ```fib 4``` was not in the cache, its computation was still sped up by the caching of values.

There is a simple way to memoize recursive functions calls over natural numbers in Haskell. It goes like this:

```haskell
fib = (map fib' [0..] !!)
    where
        fib' 0 = 0
        fib' 1 = 1
        fib' n = fib (n - 1) + fib (n - 2)
```

Now when ```fib``` is called it maps the worker function ```fib'``` over an infinite list with all valid input values. The clever part is that ```fib'```points right back at our infinite list by way of ```fib```! Laziness means that none of those infinite evaluations are carried out unless they are actually needed, and the fact that they are in a datastructure means that they will persist after being evaluated once for the duration of the original function call. Since the list doesn't have a name it can be garbage collected at the end of the evaluation process.

```haskell
import System.Environment

-- Now with memoization!
fib = (map fib' [0..] !!)
    where
        fib' 0 = 0
        fib' 1 = 1
        fib' n = fib (n - 1) + fib (n - 2)

main = do
    a <- getArgs
    let n = read (head a) :: Integer
    print . sum . takeWhile (< n) . map fib $ [0,3..] -- infinite list of multiples of 3
```

This is much faster than the original. 2.hs takes an embarrassing 0.800s for the problem statement's given bound of 4,000,000 while 2c.hs gets it done almost instantly (0.020s). However, this still isn't the most efficient…

