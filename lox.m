#import "lox.h"
#import "parser.h"
#import "scanner.h"
#import "interpreter.h"
#import "token.h"

@implementation Lox

- (instancetype)init {
    self = [super init];
    if (self) {
        hadError = NO;
        hadRuntimeError = NO;
    }
    return self;
}

- (void)runFile:(NSString *)path {
    NSLog(@"Running file %@\n", path);
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:path] == YES) {
        NSData *data = [fileManager contentsAtPath:path];
        NSString *source = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self run:source];
    }
    else {
        NSLog(@"Invalid File Path");
    }

    if (hadError) { exit(1); }
    if (hadRuntimeError) { exit(1); }
}

- (void)runPrompt {
    @try {
        while YES {
            NSLog(@"> ");
            // grab input from the command line and return it
            NSFileHandle *handle = [NSFileHandle fileHandleWithStandardInput];
            NSData *data = handle.availableData;
            NSString *input = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
            [self run:input];
            hadError = NO;
        }
    }
    @catch(NSException *exception) {
        NSLog(@"\nExited Plox");
        NSLog(@"%@ ", exception.name);
        NSLog(@"Reason: %@ ", exception.reason);
    }
}

- (void)run:(NSString *)source {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 

    Scanner *scanner = [[Scanner alloc] initWithSource:source andLox:self];
    NSMutableArray *tokens = [scanner scanTokens];

    // Stop if there was a scanning error
    if (sizeof(tokens) == 0) { return; }

    // UNCOMMENT for loop to test scanning - COMMENT OUT interpreter function call
    // for (Token *token in tokens) {
    //     [token print];
    // }

    Parser *parser = [[Parser alloc] initWithTokens:tokens andLox:self];
    NSMutableArray *statements = [parser parse];
    NSLog(@"Statements: %@\n", statements);

    // Stop if there was a syntax error
    if (sizeof(statements) == 0) { return; }

    Interpreter *interpreter = [[Interpreter alloc] initWithLox:self];
    [interpreter interpret:statements];
    NSLog(@"Interpreter Finished\n");

    [pool drain];
}

- (void)error:(NSNumber *)line message:(NSString *)message {
    [self report:line where:@"" message:message];
}

- (void)runtimeError:(NSNumber *)line message:(NSString *)message {
    // NSLog(@"%@ \n[line %d]", [error getMessage], error.token.line);
    [self report:line where:@"" message:message];
    hadRuntimeError = YES;
}

- (void)parserError:(Token *)token message:(NSString *)message {
    if (token.token_type == @"EOF") {
        [self report:(NSNumber *)token.line where:@" at end" message:message];
    }
    else {
        [self report:(NSNumber *)token.line where:@" at '%@'", token.lexeme message:message];
    }
}

- (void)report:(NSNumber *)line where:(NSString *)where message:(NSString *)message {
    NSLog(@"[line %@] Error %@: %@\n", line, where, message);
    hadError = YES;
}

@end

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    Lox *lox = [[Lox alloc] init];

    if (argc > 2) {
        NSLog(@"Usage: plox [script]");
        exit(64);
    }
    else if (argc == 2) {
        [lox runFile:[NSString stringWithUTF8String:argv[1]]];
    }
    else {
        [lox runPrompt];
    }

    [pool drain];

    return 0;
}