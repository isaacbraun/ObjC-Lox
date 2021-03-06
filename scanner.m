#import "scanner.h"
#import "lox.h"
#import "token.h"

@implementation Scanner

- (instancetype)initWithSource:(NSString *)param_source andLox:(Lox *)param_lox {
    self = [super init];
    if (self) {
        source = param_source;
        tokens = [[NSMutableArray alloc] init];
        start = 0;
        current = 0;
        line = 1;        
        lox = param_lox;
    }
    return self;
}

- (NSMutableDictionary *)GetLiteralTokenTypes {
    NSMutableDictionary *LiteralTokenTypes = [NSMutableDictionary dictionary];
    [LiteralTokenTypes setObject: @"("  forKey: @"L_PAREN"];
    [LiteralTokenTypes setObject: @")"  forKey: @"R_PAREN"];
    [LiteralTokenTypes setObject: @"{"  forKey: @"L_BRACE"];
    [LiteralTokenTypes setObject: @"}"  forKey: @"R_BRACE"];
    [LiteralTokenTypes setObject: @","  forKey: @"COMMA"];
    [LiteralTokenTypes setObject: @"."  forKey: @"DOT"];
    [LiteralTokenTypes setObject: @";"  forKey: @"SEMICOLON"];
    [LiteralTokenTypes setObject: @"+"  forKey: @"PLUS"];
    [LiteralTokenTypes setObject: @"-"  forKey: @"MINUS"];
    [LiteralTokenTypes setObject: @"*"  forKey: @"STAR"];
    [LiteralTokenTypes setObject: @"!"  forKey: @"BANG"];
    [LiteralTokenTypes setObject: @"!=" forKey: @"BANG_EQ"];
    [LiteralTokenTypes setObject: @">"  forKey: @"GR"];
    [LiteralTokenTypes setObject: @">=" forKey: @"GR_EQ"];
    [LiteralTokenTypes setObject: @"<"  forKey: @"LT"];
    [LiteralTokenTypes setObject: @"<=" forKey: @"LT_EQ"];
    [LiteralTokenTypes setObject: @"="  forKey: @"EQ"];
    [LiteralTokenTypes setObject: @"==" forKey: @"IS_EQ"];

    return LiteralTokenTypes;
}

- (NSMutableDictionary *)GetKeywordTokenTypes {
    NSMutableDictionary *KeywordTokenTypes = [NSMutableDictionary dictionary];
    [KeywordTokenTypes setObject: @"AND" forKey: @"and"];
    [KeywordTokenTypes setObject: @"CLASS" forKey: @"class"];
    [KeywordTokenTypes setObject: @"ELSE" forKey: @"else"];
    [KeywordTokenTypes setObject: @"FALSE" forKey: @"false"];
    [KeywordTokenTypes setObject: @"FUN" forKey: @"fun"];
    [KeywordTokenTypes setObject: @"FOR" forKey: @"for"];
    [KeywordTokenTypes setObject: @"IF" forKey: @"if"];
    [KeywordTokenTypes setObject: @"NIL" forKey: @"nil"];
    [KeywordTokenTypes setObject: @"OR" forKey: @"or"];
    [KeywordTokenTypes setObject: @"PRINT" forKey: @"print"];
    [KeywordTokenTypes setObject: @"RETURN" forKey: @"return"];
    [KeywordTokenTypes setObject: @"SUPER" forKey: @"super"];
    [KeywordTokenTypes setObject: @"THIS" forKey: @"this"];
    [KeywordTokenTypes setObject: @"TRUE" forKey: @"true"];
    [KeywordTokenTypes setObject: @"VAR" forKey: @"var"];
    [KeywordTokenTypes setObject: @"WHILE" forKey: @"while"];

    return KeywordTokenTypes;
}

- (NSMutableArray *)scanTokens {
    while (![self isAtEnd]) {
        start = current;
        [self scanToken];
    }

    // Append EOF token to the end of the token array
    Token *eof = [[Token alloc] initWithData:@"EOF" lexeme:@"" literal:NULL line:line];
    [tokens addObject:eof];

    return tokens;
}

- (void)scanToken {
    char c = [self advance];

    // Check for newline char
    if (c == '\n') {
        line++;
    }
    // Handle SLASH with check for a comment
    else if (c == '/') {
        if ([self match:'/']) {
            while (![self isAtEnd] && [self peek] != '\n') {
                [self advance];
            }
        }
        else {
            [self addSingleToken:@"SLASH"];
        }
    }
    // Check for String Literal
    else if (c == '"') {
        [self string];
    }
    // Check for Number Literal
    else if ([self isDigit:c]) {
        [self number];
    }
    // Ignore meaningless characters
    else if ((c == ' ') || (c == '\t') || (c == '\r')) {
        // Do nothing
    }
    else {
        NSString *possible_token = NULL;
        // Find maximal munch of chars in LiteralTokenTypes
        NSMutableDictionary *LiteralTokenTypes = [self GetLiteralTokenTypes];

        for (NSString *token_type in LiteralTokenTypes) {
            NSString *lexeme = [LiteralTokenTypes objectForKey:token_type];

            // Get first character of lexeme
            char first_char = [lexeme characterAtIndex:0];
            if (first_char == c) {
                if (possible_token == NULL || [self match:[lexeme characterAtIndex:1]]) {
                    possible_token = token_type;
                }
            }
        }
        if (possible_token != NULL) {
            [self addSingleToken:possible_token];
        }
        // If not literal, check for alpha
        else if ([self isAlpha:c]) {
            [self identifier];
        }
        // Error if not a literal or alpha
        else {
            [lox error:(NSNumber *)line message:[NSString stringWithFormat:@"Unexpected character %c", c]];
        }
    }
}

- (void)identifier {
    while ([self isAlphaNumeric:[self peek]]) {
        [self advance];
    }
    NSString *text = [source substringWithRange:NSMakeRange(start, current - start)];
    NSMutableDictionary *KeywordTokenTypes = [self GetKeywordTokenTypes];
    if ([KeywordTokenTypes objectForKey:text] != NULL) {
        [self addSingleToken:[KeywordTokenTypes objectForKey:text]];
    }
    else {
        [self addSingleToken:@"IDENTIFIER"];
    }
}

- (void)string {
    while ([self peek] != '"' && ![self isAtEnd]) {
        if ([self peek] == '\n') {
            line++;
        }
        [self advance];
    }

    if ([self isAtEnd]) {
        [lox error:(NSNumber *)line message:@"Unterminated string"];
    }

    [self advance];

    NSString *value = [source substringWithRange:NSMakeRange(start + 1, current - start - 2)];
    [self addToken:@"STRING" literal:value];
}

- (void)number {
    while ([self isDigit:[self peek]]) {
        [self advance];
    }

    // Look for fractional part
    if ([self peek] == '.' && [self isDigit:[self peekNext]]) {
        // Consume the "."
        [self advance];

        while ([self isDigit:[self peek]]) {
            [self advance];
        }
    }

    NSString *text = [source substringWithRange:NSMakeRange(start, current - start)];
    [self addToken:@"NUMBER" literal:text];
}

- (BOOL)isDigit:(char)c {
    return '0' <= c && c <= '9';
}

- (BOOL)isAlpha:(char)c {
    return ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || c == '_';
}

- (BOOL)isAlphaNumeric:(char)c {
    return [self isAlpha:c] || [self isDigit:c];
}

- (BOOL)match:(char)expected {
    if (![self isAtEnd] && [self peek] == expected) {
        current++;
        return YES;
    }

    return NO;
}

- (BOOL)isAtEnd {
    return current >= [source length];
}

- (char)peek {
    // May have to include end of string char
    return [source characterAtIndex:current];
}

- (char)peekNext {
    // May have to include end of string char
    return [source characterAtIndex:current + 1];
}

- (char)advance {
    char nextChar = [source characterAtIndex:current];
    current++;
    return nextChar;
}

- (void)addSingleToken:(NSString *)tempType {
    [self addToken:tempType literal:NULL];
}

- (void)addToken:(NSString *)tempType literal:(NSString *)literal {
    NSString *text = [source substringWithRange:NSMakeRange(start, current - start)];
    Token *token = [[Token alloc] initWithData:tempType lexeme:text literal:literal line:line];
    [tokens addObject:token];
}

@end