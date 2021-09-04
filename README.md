

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

### Cheat 2 (2cc.hs)

The numbers we need to work with to see any performance difference between versions are now enormous. Since these numbers are bothersome to type, the first change I've made is to make the program expect as its input the exponent for a power of 2. This way an unwieldy bound like 2<sup>320</sup> can be entered as "320" instead of "2135987035920910082395021706169552114602704522356652769947041607822219725780640550022962086936576".

```haskell
-- Before:
    a <- getArgs
    let n = read (head a) :: Integer

-- After:
    a <- getArgs
    let n = ((2^) . read . head) a :: Integer
```

Now that that's out of the way with, we can get to actual algorithm changes.

There are 2 problems with the memoization in the previous solution, relating to what exactly is and isn't cached.

The first is sortof obvious; nothing is saved between calls. In other contexts this behavior can be good for memory performance, but here it's a waste. The solution, however, is simple: give the list a name. Datastructures with names are persistent, so if we want our infinite list to remain in memory between calls we can just do something like this:

```haskell
fibs = (map fib' [0..])
    where
        fib' 0 = 0
        fib' 1 = 1
        fib' n = fib (n - 1) + fib (n - 2)

fib n = fibs !! n
```

That solves our first problem, but it gives us an idea about something to eliminate. If we're just going through the list in order anyway, why not ignore ```fib``` and use ```fibs``` directly? Lets think through this. The list has to start ```[0, 1, …]```, but how do we get ```…```? The answer is deceptively simple. Each term is the previous term added to the term before that, iterating off into infinity. A list made by zippering together two slightly shifted versions of itself. What if we try writing that idea down in code? We have a function ```zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]``` that seems to do what we want, and if we call the list from where we were at ```…``` the fibs we get will be 2 elements behind where we are. All we need now is a version of fibs starting one element ahead of the one we just called, and we can get it by dropping the first element with ```tail```. Putting it all together we get something that at first might look like it shouldn't work:

```haskell
-- Zipping a list with itself from the past:
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)
```

This is another place where walking through an evaluation might help you understand what's going on.

```haskell
fibs | tail fibs | zipWith (+) fibs (tail fibs)
0    | 1         | 0  + 1   -- Hey, we have (fibs !! 2) now! I'll put it in the next rows and mark it *.
1    | 1*        | 1  + 1*  -- Hey, we have (fibs !! 3) now! I'll put it in the next rows and mark it ™.
1*   | 2™        | 1* + 2™  -- Hey, we have (fibs !! 4) now! I'll put it in the next rows and mark it †.
2™   | 3†        | 2™ + 3†  -- Hey, we have… I think you can see where this is going.
```

Now we don't need ```map fib [0,3..]``` to generate our infinite list, we already have the numbers in an infinite list! We only need every 3rd number remember, so we'll write up a quick anonymous function that gets every 3rd item from a list:

```haskell
import Data.Function (fix) -- Ah, the fixed point combinator. Where would we be without you?

-- For those unfamiliar, it's defined like this:
fix' f = let x = f x in x
-- That beautiful little ouroboros lets you write recursive anonymous functions.

-- This will grab every 3rd item from an infinite list very efficiently:
fix (\ r (a:_:_:as) -> a : r as)
```

From here the implementation is pretty straightforward:

```haskell
import System.Environment
import Data.Function (fix)

-- Persistant infinite list of fibonacci numbers:
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

main = do
    a <- getArgs
    let n = ((2^) . read . head) a :: Integer
    print . sum . takeWhile (< n) . fix (\ r (a:_:_:as) -> a : r as) $ fibs
```

Once again this is significantly faster than the last version. 2c.hs takes 1.203s for an input of 2<sup>8192</sup>; 2cc.hs is nearly instant (0.019s).

### Cheat 3 (2ccc.hs)

You didn't think we were done yet, did you?

In the last version we efficiently made an infinite list of fibonacci numbers and then added up every third number below our limit. An obvious place to look for efficiency gains is by avoiding calculating all those inbetween terms. After all, they do account for two thirds of the list. Lets see if there's some way to get F<sub>n</sub> solely in terms of F<sub>n - {some multiple of 3}</sub>:

```pseudocode
F(n) = F(n-1) + F(n-2) // Expand!
F(n) = F(n-2) + F(n-3) + F(n-3) + F(n-4) // Here's some F(n-3)s, lets group them together.
F(n) = 2F(n-3) + F(n-2) + F(n-4) // Keep expanding terms!
F(n) = 2F(n-3) + F(n-3) + F(n-4) + F(n-5) + F(n-6) // Here's some F(n-3)s and an F(n-6)s!
F(n) = 3F(n-3) + F(n-6) + F(n-4) + F(n-5) // Wait, F(n-4) + F(n-5) is F(n-3)!
F(n) = 4F(n-3) + F(n-6) // Ladies and gentelmen, we got 'em.

Ef(0) = 0
Ef(1) = 2
Ef(n) = 4Ef(n-1) + Ef(n-2)
```

From here its trivial to rework our list from before to be a list of *only* the even fibonacci numbers:

```haskell
efibs = 0 : 2 : zipWith (+) efibs ((map (4 *) . tail) efibs)
```

Now we can drop that anonymous item skipping function and throw ```efibs``` right where ```fibs``` was:

```haskell
import System.Environment

-- Persistant infinite list of *even* fibonacci numbers:
efibs = 0 : 2 : zipWith (+) efibs ((map (4 *) . tail) efibs)

main = do
    a <- getArgs
    let n = ((2^) . read . head) a :: Integer
    print . sum . takeWhile (< n) $ efibs
```

On to performance! These ones are closer to eachother than the last few, so I've added the ```-prof```, ```-fprof-auto```, and ```-RTS``` flags to ghc's arguments and run the programs with the ```+RTS -p``` arguments. This generates a helpful profiling output that - while slightly inaccurate to real life elapsed time - is very precise. Here's the profiling output after giving both programs an input of 2<sup>1,000,000</sup> (I've cut out the cost center breakdown to reduce clutter):

```
	Sat Sep  4 01:27 2021 Time and Allocation Profiling Report  (Final)

	   2cc +RTS -p -RTS 1000000

	total time  =        6.42 secs   (6415 ticks @ 1000 us, 1 processor)
	total alloc = 121,474,472,920 bytes  (excludes profiling overheads)

COST CENTRE MODULE SRC                   %time %alloc

fibs        Main   2cc.hs:5:1-43          73.5   75.1
main        Main   2cc.hs:(7,1)-(10,75)   26.2   24.9
```

```
	Sat Sep  4 01:27 2021 Time and Allocation Profiling Report  (Final)

	   2ccc +RTS -p -RTS 1000000

	total time  =        5.25 secs   (5255 ticks @ 1000 us, 1 processor)
	total alloc = 91,363,938,120 bytes  (excludes profiling overheads)

COST CENTRE MODULE SRC                   %time %alloc

efibs       Main   2ccc.hs:4:1-60         69.3   66.9
main        Main   2ccc.hs:(6,1)-(9,41)   30.7   33.1
```

"Wait," I hear you say. "this version is only 22% faster? Why even bother! The other "cheats" were all wildly faster than their predecessor! What gives?"

Well there *is* a significant speed increase to be had in the next version, but it's already going to involve introducing more than one big new idea. In light of that, this solution was partially meant to break off the idea of a direct even fibonacci number sequence on its own and reduce the burden on the next cheat explanation.

But aside from that, it's important to note that there aren't always huge asymptotic speedups to be had. A lot of real world optimization involves many small improvements and few (if any) big ones.
