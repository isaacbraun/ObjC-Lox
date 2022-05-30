# ObjC-Lox


Objective-C Interpreter for Lox based on [Bob Nystrom's](https://github.com/munificent) implementation in his [Crafting Interpreters](http://www.craftinginterpreters.com/)
book.


gcc -o <NAME>.exe <NAME>.m -I /GNUstep/GNUstep/System/Library/Headers -L /GNUstep/GNUstep/System/Library/Libraries -std=c99 -lobjc -lgnustep-base -fconstant-string-class=NSConstantString