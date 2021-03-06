#import "parser.h"
#import "stmt.h"
#import "expr.h"
#import "token.h"
#import "lox.h"

@implementation Parser
- (instancetype)initWithTokens:(NSMutableArray *)param_tokens andLox:(Lox *)param_lox {
    if ((self = [super init])) {
        tokens = param_tokens;
        current = 0;
        lox = param_lox;
    }
    return self;
}

- (NSMutableArray *)parse {
    @try {
        NSMutableArray *statements = [NSMutableArray array];

        while (![self isAtEnd]) {
            [statements addObject:[self declaration]];
        }
        return statements;
    }
    @catch (NSException *exception) {
        return nil;
    }
}
- (id)declaration {
    @try {
        if ([self match:[NSArray arrayWithObjects:@"VAR", nil]]) {
            return [self varDeclaration];
        }
        return [self statement];
    }
    @catch (NSException *exception) {
        NSLog(@"Declaration error: %@", exception);
        [self synchronize];
        return nil;
    }
}

- (id)statement {
    if ([self match:[NSArray arrayWithObjects:@"FOR", nil]]) {
        return [self forStatement];
    }
    else if ([self match:[NSArray arrayWithObjects:@"IF", nil]]) {
        return [self ifStatement];
    }
    else if ([self match:[NSArray arrayWithObjects:@"PRINT", nil]]) {
        return [self printStatement];
    }
    else if ([self match:[NSArray arrayWithObjects:@"WHILE", nil]]) {
        return [self whileStatement];
    }
    else if ([self match:[NSArray arrayWithObjects:@"L_BRACE", nil]]) {
        return [[Block alloc] initWithStatements:[self block]];
    }
    else {
        return [self expressionStatement];
    }
}

- (id)forStatement {
    [self consume:@"L_PAREN" message:@"Expect '(' after 'for'."];

    id initializer = nil;
    if ([self match:[NSArray arrayWithObjects:@"VAR", nil]]) {
        initializer = [self varDeclaration];
    }
    else if (![self match:[NSArray arrayWithObjects:@"SEMICOLON", nil]]) {
        initializer = [self expressionStatement];
    }

    Expr *condition = nil;
    if (![self check:@"SEMICOLON"]) {
        condition = [self expression];
    }

    [self consume:@"SEMICOLON" message:@"Expect ';' after loop condition."];

    Expr *increment = nil;
    if (![self check:@"R_PAREN"]) {
        increment = [self expression];
    }

    [self consume:@"R_PAREN" message:@"Expect ')' after for clauses."];

    id body = [self statement];

    if (increment) {
        Expression *incrementExpression = [[Expression alloc] initWithExpression:increment];
        body = [[Block alloc] initWithStatements:[NSArray arrayWithObjects:body, incrementExpression]];
    }

    if (condition == nil) {
        condition = [[Literal alloc] initWithValue:@"YES"];
    }

    body = [[While alloc] initWithCondition:condition body:body];

    if (initializer) {
        body = [[Block alloc] initWithStatements:[NSArray arrayWithObjects:initializer, body]];
    }

    return body;
}

- (id)ifStatement {
    [self consume:@"L_PAREN" message:@"Expect '(' after 'if'."];
    Expr *condition = [self expression];
    [self consume:@"R_PAREN" message:@"Expect ')' after if condition."];

    id thenBranch = [self statement];
    id elseBranch = nil;

    if ([self match:[NSArray arrayWithObjects:@"ELSE", nil]]) {
        elseBranch = [self statement];
    }

    return [[If alloc] initWithCondition:condition thenBranch:thenBranch elseBranch:elseBranch];
}

- (id)varDeclaration {
    Token *name = [self consume:@"IDENTIFIER" message:@"Expect variable name."];
    id initializer = nil;
    if ([self match:[NSArray arrayWithObjects:@"EQ", nil]]) {
        initializer = [self expression];
    }

    [self consume:@"SEMICOLON" message:@"Expect ';' after variable declaration."];
    return [[Var alloc] initWithName:name initializer:initializer];
}

- (id)whileStatement {
    [self consume:@"L_PAREN" message:@"Expect '(' after 'while'."];
    Expr *condition = [self expression];
    [self consume:@"R_PAREN" message:@"Expect ')' after while condition."];
    id body = [self statement];

    return [[While alloc] initWithCondition:condition body:body];
}

- (id)printStatement {
    Expr *value = [self expression];
    [self consume:@"SEMICOLON" message:@"Expect ';' after value."];
    return [[Print alloc] initWithExpression:value];
}

- (id)expressionStatement {
    Expr *expression = [self expression];
    [self consume:@"SEMICOLON" message:@"Expect ';' after expression."];
    return [[Expression alloc] initWithExpression:expression];
}

- (NSMutableArray *)block {
    NSMutableArray *statements = [NSMutableArray array];

    while (![self check:@"R_BRACE"] && ![self isAtEnd]) {
        [statements addObject:[self declaration]];
    }

    [self consume:@"R_BRACE" message:@"Expect '}' after block."];
    return statements;
}

- (id)expression {
    return [self assignment];
}

- (id)assignment {
    id expr = [self OR];

    if ([self match:[NSArray arrayWithObjects:@"EQ", nil]]) {
        Token *equals = [self previous];
        id value = [self assignment];

        if ([expr isKindOfClass:[Variable class]]) {
            Token *name = [(Variable *)expr name];
            return [[Assign alloc] initWithName:name value:value];
        }
        else {
            [lox error:(NSNumber *)equals.line message:@"Invalid assignment target."];
        }
    }

    return expr;
}

- (id)OR {
    id expr = [self AND];

    while ([self match:[NSArray arrayWithObjects:@"OR", nil]]) {
        Token *operator = [self previous];
        id right = [self AND];
        expr = [[Logical alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (id)AND {
    id expr = [self equality];

    while ([self match:[NSArray arrayWithObjects:@"AND", nil]]) {
        Token *operator = [self previous];
        id right = [self equality];
        expr = [[Logical alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (id)equality {
    id expr = [self comparison];

    while ([self match:[NSArray arrayWithObjects:@"BANG_EQ", @"IS_EQ", nil]]) {
        Token *operator = [self previous];
        id right = [self comparison];
        expr = [[Binary alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (id)comparison {
    id expr = [self term];

    while ([self match:[NSArray arrayWithObjects:@"LT", @"LT_EQ", @"GR", @"GR_EQ", nil]]) {
        Token *operator = [self previous];
        id right = [self term];
        expr = [[Binary alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (id)term {
    id expr = [self factor];

    while ([self match:[NSArray arrayWithObjects:@"PLUS", @"MINUS", nil]]) {
        Token *operator = [self previous];
        id right = [self factor];
        expr = [[Math alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (id)factor {
    id expr = [self unary];

    while ([self match:[NSArray arrayWithObjects:@"STAR", @"SLASH", nil]]) {
        Token *operator = [self previous];
        id right = [self unary];
        expr = [[Math alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (id)unary {
    if ([self match:[NSArray arrayWithObjects:@"BANG", nil]]) {
        Token *operator = [self previous];
        id right = [self unary];
        return [[Unary alloc] initWithOperator:operator right:right];
    }

    return [self primary];
}

- (id)negate {
    if ([self match:[NSArray arrayWithObjects:@"MINUS", nil]]) {
        Token *operator = [self previous];
        id right = [self unary];
        return [[Negate alloc] initWithOperator:operator right:right];
    }

    return nil;
}

- (id)primary {
    if ([self match:[NSArray arrayWithObjects:@"FALSE", nil]]) {
        return [[Literal alloc] initWithValue:@"NO"];
    }
    else if ([self match:[NSArray arrayWithObjects:@"TRUE", nil]]) {
        return [[Literal alloc] initWithValue:@"YES"];
    }
    else if ([self match:[NSArray arrayWithObjects:@"NIL", nil]]) {
        return [[Literal alloc] initWithValue:@"nil"];
    }
    else if ([self match:[NSArray arrayWithObjects:@"NUMBER", @"STRING", nil]]) {
        return [[Literal alloc] initWithValue:[NSString stringWithFormat:@"%@", [self previous].literal]];
    }
    else if ([self match:[NSArray arrayWithObjects:@"IDENTIFIER", nil]]) {
        return [[Variable alloc] initWithName:[self previous]];
    }
    else if ([self match:[NSArray arrayWithObjects:@"L_PAREN", nil]]) {
        id expr = [self expression];
        [self consume:@"R_PAREN" message:@"Expect ')' after expression."];
        return [[Grouping alloc] initWithExpression:expr];
    }
    else {
        [lox error:(NSNumber *)[self peek].line message:@"Expect expression."];
        return nil;
    }
}

- (BOOL)match:(NSArray *)types {
    for (NSString *type in types) {
        if ([self check:type]) {
            [self advance];
            return YES;
        }
    }

    return NO;
}

- (Token *)consume:(NSString *)type message:(NSString *)message {
    if ([self check:type]) {
        return [self advance];
    }
    else {
        [lox error:(NSNumber *)[self peek].line message:message];
        return nil;
    }
}

- (BOOL)check:(NSString *)type {
    if ([self isAtEnd]) {
        return NO;
    }
    // NSLog(@"Checking %@ against %@: %@", [self peek].token_type, type, [[self peek].token_type isEqualToString:type] ? @"YES" : @"NO");

    return [[self peek].token_type isEqualToString:type];
}

- (Token *)advance {
    if (![self isAtEnd]) {
        current++;
    }
    return [self previous];
}

- (BOOL)isAtEnd {
    return [[self peek].token_type isEqualToString:@"EOF"];
}

- (Token *)peek {
    return [tokens objectAtIndex:current];
}

- (Token *)previous {
    return [tokens objectAtIndex:current - 1];
}

- (void)synchronize {
    [self advance];

    while (![self isAtEnd]) {
        if ([[self previous].token_type isEqualToString:@"SEMICOLON"]) {
            return;
        }

        NSString *type = [self peek].token_type;
        if ([type isEqualToString:@"CLASS"] ||
            [type isEqualToString:@"FUN"] ||
            [type isEqualToString:@"VAR"] ||
            [type isEqualToString:@"FOR"] ||
            [type isEqualToString:@"IF"] ||
            [type isEqualToString:@"WHILE"] ||
            [type isEqualToString:@"PRINT"] ||
            [type isEqualToString:@"RETURN"]) 
        {
            [self advance];
        }
        else if ([type isEqualToString:@"RETURN"]) {
            return;
        }
    }
}

@end