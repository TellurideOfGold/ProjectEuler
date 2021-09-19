

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

The above solution works, but there's a much faster way. Wouldn't it be neat if we could compute the sum directly? Without adding up all the intermediate values?

One day in the 1700's, the someday to be legendary mathematician Carl Friedrich Gauss was an 8 year old student of elementary school. His teacher, probably hoping to keep his young charges occupied for a while, instructed the class to add up all the numbers from 1 to 100. But in just a moment, Gauss found the answer! And this is what he saw:

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
\sum_{x=1}^n x = \frac{n(n+1)}{2}
$$

We can easily translate this into a short Haskell function: ```sum1To n = quot (n * (n + 1)) 2```. Multiplying each term of a summation by a constant is the same as multiplying the total by that constant, so a function to find the sum of multiples of a number below some limit is trivial: ```sumMultiplesOfTo m n = m * sum1To (quot n m)```. Note that we divide the bound by the multiplier before passing it to the ```sum1To``` function!

Finally, we can write the solution. Add the sum of multiples of 3 to the sum of multiples of 5, but since the multiples of 15 show up in *both* lists we need to subtract out the "duplicates":

```haskell
threesAndFivesToN n =
    let n' = n - 1
    in  (sumMultiplesOfTo 3 n') + (sumMultiplesOfTo 5 n') - (sumMultiplesOfTo 15 n')
```

Also note that we subtract 1 from the input; this is because our function has an inclusive upper bound while the problem is posed with an exclusive upper bound.

And that's that! This version is much faster than the previous one. 1.hs (compiled with -O2) takes 8.532s on my machine for an input of 1,000,000. 1c.hs is almost instant (0.020s) and will happily churn out answers thousands of digits long.

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

The first is sorta obvious; nothing is saved between calls. In other contexts this behavior can be good for memory performance, but here it's a waste. The solution, however, is simple: give the list a name. Datastructures with names are persistent, so if we want our infinite list to remain in memory between calls we can just do something like this:

```haskell
fibs = (map fib' [0..])
    where
        fib' 0 = 0
        fib' 1 = 1
        fib' n = fib (n - 1) + fib (n - 2)

fib n = fibs !! n
```

That solves our first problem, but it gives us an idea about something to eliminate. If we're just going through the list in order anyway, why not ignore ```fib``` and use ```fibs``` directly? Lets think through this.

The list has to start ```[0, 1, …]```, but how do we get ```…```? The answer is deceptively simple. Each term is the previous term added to the term before that, iterating off into infinity. A list made by zippering together two slightly shifted versions of itself. What if we try writing that idea down in code? We have a function ```zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]``` that seems to do what we want, and if we call the list from where we were at (```…```) the ```fibs``` we get will be 2 elements behind where we are. All we need now is a version of ```fibs``` starting one element ahead of the one we just called, and we can get it by dropping the first element with ```tail```.

Putting it all together we get something that at first might look like it shouldn't work:

```haskell
-- Zipping a list with itself from the past:
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)
```

This is another place where walking through an evaluation might help you understand what's going on. I'll denote the ```fibs``` we get inside ```zipWith``` as ```fibs'```:

```haskell
fibs | fibs' | tail fibs' | zipWith (+) fibs' (tail fibs' )
0    |   not called yet   |
1    |   not called yet   |
1*   | 0     | 1          | 0  + 1   -- Hey, we have (fibs !! 2) now! I'll mark it *.
2™   | 1     | 1*         | 1  + 1*  -- Hey, we have (fibs !! 3) now! I'll mark it ™.
3†   | 1*    | 2™         | 1* + 2™  -- Hey, we have (fibs !! 4) now! I'll mark it †.
5    | 2™    | 3†         | 2™ + 3†  -- Hey, we have… I think you can see where this is going.
```

Now we don't need ```map fib [0,3..]``` to generate our infinite list, we already have the numbers in an infinite list! We only need every 3rd number remember, so we'll write up a quick anonymous function that gets every 3rd item from an infinite list:

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

// A recurrence relation for *just* the even fibonacci numbers:
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

On to performance! These ones are closer to eachother than the last few, so I've added the ```-prof```, ```-fprof-auto```, and ```-RTS``` flags to ghc's arguments and run the programs with the ```+RTS -p``` arguments. This generates a helpful profiling output that – while slightly inaccurate to real life elapsed time – is very precise. Here's the profiling output after giving both programs an input of 2<sup>1,000,000</sup> (I've cut out the cost center breakdown to reduce clutter):

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

### Cheat 4 (2cccc.hs)

Ok. So this iterative addition thing is neat and all, but in the first problem we needed to sum the elements of some sequence below a limit and we found a way to do it without adding up all the terms individually. Might there be a way to directly compute *this* sum as well?

A relatively well known result in the study of the fibonacci sequence is that the sum of the fibonacci numbers to F<sub>n</sub> (inclusive) is F<sub>n+2</sub> - 1. The explanation goes as follows:

```pseudocode
F(n) = F(n-1) + F(n-2) // Here's our definition. We want some term to be negative…
F(n) - F(n-1) = F(n-2) // Rearrange to get a negative term.
F(n+2) - F(n+1) = F(n) // Adding a constant to the index doesn't change anything.
F(n) = F(n+2) - F(n+1) // Ok, we've got F(n) in terms of a positive and a negative term.
```

Now lets sum everything on each side of this divider. The sum on the left is the fibonacci sum through F<sub>n</sub> (which I'll call S<sub>n</sub>) and so too must be the sum on the right. On the right though, more than a few terms cancel out:

```pseudocode
  F(n)   |   F(n+2) - F(n+1) // Hey, this -F(n+1)…
+ F(n-1) | + F(n+1) - F(n)   // cancels with this +F(n+1)! And this -F(n)…
+ F(n-2) | + F(n)   - F(n-1) // cancels with this +F(n)! And this -F(n-1)…
+ …      | + …               // …
+ F(2)   | + F(4)   - F(3)   // cancels with this +F(4)! And this -F(3)…
+ F(1)   | + F(3)   - F(2)   // cancels with this +F(3)! And this -F(2)…
+ F(0)   | + F(2)   - F(1)   // cancels with this +F(2)! Phew.
= S(n)   | = F(n+2) - F(1)   // Tada!
```

Look at that! We can find the sum of the first n fibonacci numbers for the cost of calculating F<sub>n+2</sub> - 1! That's *way* faster than adding them up the long way! Lets see if we can do something similar to our Ef<sub>n</sub> from earlier:

```pseudocode
Ef(n) = 4Ef(n-1) + Ef(n-2) // Here's our definition. We want some term to be negative…
Ef(n) - 4Ef(n-1) = Ef(n-2) // Huh.
```

Well we can't rearrange it that way; the negative term has a unique coefficient so it can't really cancel out with any other terms. Lets try getting that term on its own:

```pseudocode
Ef(n) = 4Ef(n-1) + Ef(n-2)
Ef(n) - Ef(n-2) = 4Ef(n-1)

4Ef(n) = Ef(n+1) - Ef(n-1) // Ok. This looks more promising.
```

Alright, same deal as last time. Sum everything on each side of this divider; the sum on the left is 4 times the *even* fibonacci sum through Ef<sub>n</sub> (which I'll call Es<sub>n</sub>) and so too must be the sum on the right. More than a few terms cancel out but they do it jumping over a line:

```pseudocode
                                 // What cancels?
  4Ef(n)   |   Ef(n+1) - Ef(n-1) // This -Ef(n-1)…
+ 4Ef(n-1) | + Ef(n)   - Ef(n-2) // –––––––––––––––––– This -Ef(n-2)…
+ 4Ef(n-2) | + Ef(n-1) - Ef(n-3) // and this +Ef(n-1). –––––––––––––––––– This -Ef(n-3)…
+ 4Ef(n-3) | + Ef(n-2) - Ef(n-4) // –––––––––––––––––– and this +Ef(n-2). –––––––––––––––––– This…
+ 4Ef(n-4) | + Ef(n-3) - Ef(n-5) // ––––––––––––––––––––––––––––––––––––– and this +Ef(n-3). ––––…
+ …        | + …
+ 4Ef(5)   | + Ef(6)   - Ef(4)   // ––––––––––––––––––––––––––––––––––––– This -Ef(4)… ––––––––––…    
+ 4Ef(4)   | + Ef(5)   - Ef(3)   // –––––––––––––––––– This -Ef(3)… –––––––––––––––––––––––– and …
+ 4Ef(3)   | + Ef(4)   - Ef(2)   // This -Ef(2)… –––––––––––––––––––––––– and this +Ef(4).
+ 4Ef(2)   | + Ef(3)   - Ef(1)   // –––––––––––––––––– and this +Ef(3).
+ 4Ef(1)   | + Ef(2)   - Ef(0)   // and this +Ef(2).

// We can leave out this row because 4Ef(0) = 0.
+ 4Ef(0)   | + Ef(1)   - Ef(-1)
```

Oops, we sorta ran out of room. Let's rearrange this a little. It's pretty clear that the left hand side will add up to 4Es<sub>n</sub>, so we'll only worry about the right. Since everything on each side is being added up and addition is commutative it won't actually change the total if we shift a column up or down to line things up:

```pseudocode
// Shift the right column down by 2:

  Ef(n+1)
+ Ef(n)
+ Ef(n-1) - Ef(n-1) //  –––
+ Ef(n-2) - Ef(n-2) //   |
+ Ef(n-3) - Ef(n-3) //   |
+ …                 //   | – Now all these terms cancel!
+ Ef(4)   - Ef(4)   //   |
+ Ef(3)   - Ef(3)   //   |
+ Ef(2)   - Ef(2)   //  –––
          - Ef(1)
          - Ef(0)

4Es(n) =  Ef(n+1) + Ef(n) - Ef(1) - Ef(0)  // Substitute known values…
4Es(n) =  Ef(n+1) + Ef(n) - 2     - 0      // Shuffle some more…
 Es(n) = (Ef(n+1) + Ef(n) - 2) / 4         // There it is.
```

Previously the final sum consisted of just calling ```sum``` on some final list, but now there's an actual formula involved. Lets move this to its own function:

```haskell
-- For clarity let's move the sum calculation out of the main function:
eFibSum n = flip quot 4 $ efib n + efib (n + 1)
```

Ok - we've eliminated the need to sum all the intermediate terms, but calculating Ef<sub>n</sub> with ```efib``` will still end up generating all the intermediate values. Sure, we avoid n additions, but the whole algorithm works out to 2n additions and n multiplications by 4 anyway. What we need is a blazingly fast way to calculate F<sub>n</sub> – and with just a little more work Ef<sub>n</sub>. Fortunately, linear algebra can come to our rescue!

A recurrence relation can be represented through matrix multiplication like so:

```pseudocode
|  F(n)  |     | c0 c1 c2 …  cr |  | F(n-1) |
| F(n-1) |     | 1  0  0  …  0  |  | F(n-2) |
| F(n-2) |  =  | 0  1  0  …  0  |  | F(n-3) |
|   …    |     | …  …  …  …  …  |  |   …    |
| F(n-r) |     | 0  0  0  …  0  |  | F(n-r) |

|  F(n+r)  |     | c0 c1 c2 …  cr | n  | F(r-1) |
| F(n+r-1) |     | 1  0  0  …  0  |    | F(r-2) |
| F(n+r-2) |  =  | 0  1  0  …  0  |    | F(r-3) |
|    …     |     | …  …  …  …  …  |    |   …    |
|   F(n)   |     | 0  0  0  …  0  |    |  F(0)  |
```

And filling in the blanks for the even fibonacci recurrence we derived back in Cheat 3:

```pseudocode
// So for the even fibonacci sequence:

| F(n+1) |  =  | c0 c1 | n  | F(1) |
| F(n)   |     | 1  0  |    | F(0) |

| F(n+1) |  =  | 4 1 | n  | 2 |
| F(n)   |     | 1 0 |    | 0 |

// Let's try n=3:

| 4 1 | 3  =  | 72 17 |
| 1 0 |       | 17  4 |

| 144 |  =  | 72 17 |  | 2 |
|  34 |     | 17  4 |  | 0 |

// It worked!
```

We *could* write our own fast exponentiation by squaring function for matrices, but the ```Num``` typeclass already implements exponentiation by squaring for us. All we need to do is make a super simple matrix type and write a barebones ```Num``` instance for it: 

```haskell
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
    -- You could try to implement the rest, but abs and signum may cause you some trouble.

    fromInteger n =
        let m = fromInteger n
        in  SqMat2 m m m m

    (*) (SqMat2 a0 b0 c0 d0) (SqMat2 a1 b1 c1 d1) =
        SqMat2
            (a0 * a1 + b0 * c1) (a0 * b1 + b0 * d1)
            (c0 * a1 + d0 * c1) (c0 * b1 + d0 * d1)
```

The last thing we're missing is a function to multiply a matrix by a column vector. We might write something like ```mVec (SqMat2 a0 b0 c0 d0) (a1, b1) = (a0*a1 + b0*b1, c0*a1 + d0*b1)``` but there's a simpler option for our case. Our column vector is [2, 0] and we only want the first element in the resulting vector anyway, so we can just pull the (0,0) element of the matrix and multiply it by 2:

```haskell
-- Black magic:
efib 0 = 0
efib n =
    ( (\ (SqMat2 a _ _ _) -> 2 * a) -- Pull the (0,0) element and double it
    . ((SqMat2 4 1 1 0)^)           -- Exponentiation
    ) (n - 1) -- Subtract 1 from our input (Remember r from earlier? It's 1 here.)
```

Nice! This is good, but now we need to figure out what our value of n should be. All the work we did so far finds the sum of the sequence Ef up to Ef<sub>n</sub>, which again is the same as the sum of even fibonacci numbers through F<sub>3n</sub>.

The problem statement though doesn't say "sum the even fibonacci numbers up through F<sub>{some value}</sub>", it says "sum the even fibonacci numbers whose value does not exceed {some value}". In other words we have a solution in terms of the index of a sequence value, and a problem in terms of a size limit on the value itself.

So how do we find the index of the largest fibonacci number below some limit, *without* calculating all the intermediate values? There's a fast way to find the inverse of any monotonically increasing function: the exponential search! Originally this algorithm was not for this purpose. It's a modification of the simpler binary search, which was (and still is) mostly used to find the index of an element in a sorted collection (array, vector, list, etc.).

Let's start by going over the binary search. Its original form finds some target element (or finds that the element is not present) in a sorted collection by a fairly straightforward divide and conquer algorithm: First, check the middle element. If it's the target, great! We're done. If not, find out which way we missed: if the middle element is greater than the target, redo the search on just the lower half of the collection, excluding the midpoint. Otherwise, search the upper half – again, excluding the midpoint. If at any point the upper bound exceeds the lower bound it means that the target element is not present.

Lets look at how a simple search might play out:

```pseudocode
// find 34 in this sorted list:
[2, 25, 34, 36, 41, 74, 81, 89, 97, 101, 102, 193, 199, 255, 511]
                            89  // 81 > 34, so next search the low half of the list.
[2, 25, 34, 36, 41, 74, 81]
            36                  // 36 > 34, so next search the low half of the list.
[2, 25, 34]
    25                          // 25 < 34, so next search the high half of the list.
       [34]
        34                      // 34 = 34, there it is!
```

Much like with other divide and conquer algorithms, even in the worst case the number of "expensive" operations ends up being proportional to the logarithm of the size of the input. In the above case, the "expensive" operations are accessing collection elements and comparison operations on those elements. In our case, it will be the F<sub>n</sub> or Ef<sub>n</sub> calculation.

Let's write our binary search function. We'll make 2 small changes to the classic algorithm to get what we want. Instead of returning the index corresponding to the *exact* target value we asked about and failing if the target isn't there, we want the index of the *largest value less than* our target:

```haskell
bSearch f t l u =
    case 1 == u - l of
        True  -> l -- if u - l = 1 then l must be the largest index below target
        False -> let m = quot (l + u) 2 in
            case compare (f m) t of
                LT -> bSearch f t m u
                EQ -> m - 1 -- if f m = t then f (m - 1) is the largest value less than the target
                GT -> bSearch f t l m
```

This function takes 4 inputs:

- f: the function we're searching over
- t: the target
- l: the lower bound of the search (inclusive)
- u: the upper bound of the search (exclusive)

The main difference here shows up in the first stopping criterion: where originally the search would terminate in failure if l and u crossed, now the algorithm returns l if l and u are separated by 1. As a consequence, the midpoint *is* included in the next round of the search. Think about it: if we throw out m and the target value is between m-1 and m (making m-1 the correct return value), m-1 becomes our new upper bound. The upper bound in this search is exclusive, so we've just thrown out our answer!

The other change is that the search needs to return m-1 if m is equal to the target, unlike the original which returned m. This is because we want the largest value *less than* the target – not the largest value *less than or equal to* the target.

From here we use the exponential search to find the initial values for l and u. All it does is iterate through the powers of 2 until it finds one that exceeds the target.

```haskell
expSearch f t =
    let (l, u) = until -- "Until" reads like a sentence: "Until
            (\ (_, !u) -> f u > t)                     -- this is true
            (\ (!l, !u) -> (u, 2 * u))                 -- do this
            (0, 1)                                     -- to this."
    in  bSearch f t l u
```

Now we can just throw ```fib``` or ```efib``` at ```expSearch``` and we'll get the behavior we were looking for:

```haskell
λ fib 58
591286729879
(0.01 secs, 85,048 bytes)
λ expSearch' fib $ 591286729879 + 8127634
58
(0.02 secs, 152,096 bytes)
λ expSearch' fib $ 591286729879 + 1
58
(0.02 secs, 151,952 bytes)
λ expSearch' fib $ 591286729879
57
(0.02 secs, 144,928 bytes)
λ expSearch' fib $ 591286729879 - 8127634
57
(0.02 secs, 155,456 bytes)
```

And now, finally, we can write our program.

```haskell
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
        True  -> l -- if u - l = 1 then l must be the largest index below target
        False -> let m = quot (l + u) 2 in
            case compare (f m) t of
                LT -> bSearch f t m u
                EQ -> m - 1 -- if f m = t then f (m - 1) is the largest value less than the target
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
```

And there we have it! One last major improvement in the asymptotic time complexity of the algorithm! Let's look at the profiling results. First, here's the last version's result for an input of 2<sup>1000000</sup> (deja vu!):

```
	Thu Sep 16 01:07 2021 Time and Allocation Profiling Report  (Final)

	   2ccc +RTS -p -h -RTS 1000000

	total time  =        5.28 secs   (5276 ticks @ 1000 us, 1 processor)
	total alloc = 91,363,938,120 bytes  (excludes profiling overheads)

COST CENTRE MODULE SRC                   %time %alloc

efibs       Main   2ccc.hs:4:1-60         69.1   66.9
main        Main   2ccc.hs:(6,1)-(9,41)   30.9   33.1
```

And the current version:

```
	Thu Sep 16 01:07 2021 Time and Allocation Profiling Report  (Final)

	   2cccc +RTS -p -h -RTS 1000000

	total time  =        0.26 secs   (262 ticks @ 1000 us, 1 processor)
	total alloc =  70,084,192 bytes  (excludes profiling overheads)

COST CENTRE MODULE SRC                      %time %alloc

*           Main   2cccc.hs:(27,5)-(30,51)   87.4   68.1
main        Main   2cccc.hs:(57,1)-(60,23)   11.1   26.5
main.n      Main   2cccc.hs:59:9-62           1.1    0.5
efib        Main   2cccc.hs:(33,1)-(34,72)    0.4    4.5
```

Now there's a fast program! In fact it's so efficient that printing the result as a base 10 number at the end takes up a noticeable amount of the total execution time! That's what the 11% total time ascribed to the ```main``` item in the cost center overview is (for the most part). You can tell by printing a comparison of the final answer to zero instead of the answer itself. This still forces the calculation of the answer but bypasses the bulk of the printing cost, and sure enough that 11% disappears.

Remember that the initial version of this solution took ~0.800 seconds for the problem statement's bound of 4000000? This version (compiled without the profiler, just like the first one) takes ~1.854 seconds – **not for 4000000, but for 2<sup>4000000</sup>**. To give you an idea of how enormous the numbers we're working with have become, piping the program's output to a text file consumes **1.1MB**.

That's probably a good place to leave that.

