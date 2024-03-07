# Trie

Trie is very basic datastructure.   
I'm sure i would find better implementations.  
But this project is for me to learn zig and try to optimize this structure as i can.

## Why even bother?
Why even bother implementing my own trie? And than trying to optimize it?  
Lot of times i hear people saying things like: 
 - why would you reinvent wheel?
 - why would you try to squeeze performance to last drop?
 - why learning low level languages  

only think making algorithm fast is its O(n) witch is in some cases true. Trie has very good O(N). Comparing to linear array where it would be something like O(word_count). there we could forget word lenght, it would be in mid case scenario avrage of our word lenghts. this is quite ineficient. Trie is O(word.len). It is lot faster. But we can do more. Optimize it further and further. At some point gains can become small. But in larger systems idk. you can use for example games i know trie isnt right for that. but imagine your engine is 2 times slowe and your pc instead of steady 60 fps there would be noticible change if it was dropping to 30 or 15. Am I right?  
So there are usecases like games, embeded, realtime systems and much more that require as fast as possible solutions to every problem. Yeah trie is faster than array in large sets and lots of operations. But if you can do it even faster using less memory why not do it. Also i know someone already for sure did better mind bending trie than i would ever do that executes everything in like -1uS and using fixed memory of 2 bytes. I'm not that kind of wizzard. 
To end this section with this i think lot about how to optimize those things hopefully helping me solve problems in future more complex problems in job or my personal projects.

### ToDo:
 - recheck all parts of readme and try to make it more clean and more makeing sense
 - make non recursive solution (for (word) |letter| ...) should help performance (V1.1)
 - make shortening of long chains by storing them in one node as string shoudl help to reduce memory footprint in most realword cases (shortening words, sentences from basicaly lined lists to array) (V1.2)
 - make all nodes not just randomly allocated in memory but in array or more arrays connected as linked list (this is just my thought that it could help with cache usage) leading better performance. Also i could use smaller adress than 8 bytes, 4 or even 2 should be more than good, specialy if adressing would be done in sizeof node. This would help with memory footprint. Child adressing arrays would shrink in size 2 or 4 times. (V1.3)

## Tests

For each version run all tests 5 times.
There is more types of test some are for tracking changes in performance, some for checking if code work as should.  
For performance tracking is used test "Mainly performance oriented test"  
Here are test results (time(uS) and memory footprint(Bytes)).   
I'm hoping future versions will be better and better.

|       |Time  |      |      |      |      |      |Memory |     
|-------|------|------|------|------|------|------|-------|
|Version|Test1 |Test2 |Test3 |Test4 |Test5 |Avrage|       |
|V1.0   |65.0ms|63.9ms|70.1ms|62.1ms|66.9ms|65.6ms|3.514MB|
|       |      |      |      |      |      |      |       |
|       |      |      |      |      |      |      |       |
