# ObjC-Lox


Objective-C Interpreter for Lox based on [Bob Nystrom's](https://github.com/munificent) implementation in his [Crafting Interpreters](http://www.craftinginterpreters.com/)
book.

Command to run on windows: gcc -o lox.exe lox.m environment.m expr.m interpreter.m parser.m scanner.m stmt.m token.m -I /GNUstep/GNUstep/System/Library/Headers -L /GNUstep/GNUstep/System/Library/Libraries -std=c99 -lobjc -lgnustep-base -fconstant-string-class=NSConstantString -fobjc-exceptions -Wall