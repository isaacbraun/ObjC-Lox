#import "lox.h"
#import "parser.h"
#import "scanner.h"
#import "interpreter.h"
#import "token.h"

@implementation Lox

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hadError = NO;
        self.hadRuntimeError = NO;
    }
    return self;
}

- (void)runFile:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:path] == YES) {
        NSData *data = [fileManager contentsAtPath:path];
    }
    else {
        NSLog(@"Invalid File Path");
    }

    if (self.hadError) { exit(1); }
    if (self.hadRuntimeError) { exit(1); }
}

- (void)runPrompt {
    @try {
        while YES {
            NSLog(@"> ");
            // grab input from the command line and return it
            NSFileHandle *handle = [NSFileHandle fileHandleWithStandardInput];
            NSData *data = handle.availableData;
            NSString *input = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
            [self run:input];
            self.hadError = NO;
        }
    }
    @catch(NSException *exception) {
        // KeyboardInterrupt:
        NSLog(@"\nExited Plox");
        NSLog(@"%@ ", exception.name);
        NSLog(@"Reason: %@ ", exception.reason);
    }
    // @catch(NSException *exception) {
    //     // EOFError:
    //     continue;
    // }
}

- (void)run:(NSString *)source {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 

    Scanner *scanner = [[Scanner alloc] init];
    scanner.source = source;
    
    NSMutableArray *tokens = [scanner scanTokens];
    // Stop if there was a scanning error
    if (sizeof(tokens) == 0) { return }

    // UNCOMMENT for loop to test scanning - COMMENT OUT interpreter function call
    // int i;
    // for (i = 0; i < sizeof(tokens); i++ ) {
    //     NSLog(@"Token[%d]: %d\n", i, tokens[i] );
    // }

    Parser *parser = [[Parser alloc] init];
    parser.tokens = tokens;
    
    NSMutableArray *statements = [parser parse];
    // Stop if there was a syntax error
    if (sizeof(statements) == 0) { return }

    Interpreter *interpreter = [[Interpreter alloc] init];
    [interpreter interpret:statements];

    [pool drain];
}

+ (void)error:(NSNumber *)line message:(NSString *)message {
    [self report:line where:@"" message:message];
}

// + (void)runtimeError:(Error *)error {
//     NSLog(@"%@ \n[line %d]", [error getMessage], error.token.line);
//     hadRuntimeError = YES;
// }

+ (void)parserError:(Token *)token message:(NSString *)message {
    if (token.token_type == @"EOF") {
        [self report:token.line where:@" at end" message:message];
    }
    else {
        [self report:token.line where:@" at '%@'", token.lexeme message:message];
    }
}

+ (void)report:(NSNumber *)line where:(NSString *)where message:(NSString *)message {
    NSLog(@"[line %@] Error %@: %@", line, where, message);
    hadError = YES;
}

@end

void main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    Lox *lox = [[Lox alloc] init];

    if (sizeof(argv) > 2) {
        NSLog(@"Usage: plox [script]");
        sys.exit(64)
    }
    else if (sizeof(args) == 2) {
        [lox runFile:argv[1]];
    }
    else {
        [lox runPrompt];
    }

    [pool drain];
}