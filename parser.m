#import "parser.h"
#import "stmt.h"
#import "expr.h"
#import "token.h"
#import "lox.h"

@implementation Parser
- (instancetype)initWithTokens:(NSMutableArray *)tokens {
    if (self = [super init]) {
        self.tokens = tokens;
        self.current = 0;
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
- (Stmt *)declaration {
    @try {
        if ([self match:@[@"VAR"]]) {
            return [self varDeclaration];
        }
        return [self statement];
    }
    @catch (NSException *exception) {
        [self synchronize];
        return nil;
    }
}

- (Stmt *)statement {
    if ([self match:@[@"FOR"]]) {
        return [self forStatement];
    }
    else if ([self match:@[@"IF"]]) {
        return [self ifStatement];
    }
    else if ([self match:@[@"PRINT"]]) {
        return [self printStatement];
    }
    else if ([self match:@[@"WHILE"]]) {
        return [self whileStatement];
    }
    else if ([self match:@[@"L_BRACE"]]) {
        return [[Block alloc] initWithStatements:[self block]];
    }
    else {
        return [self expressionStatement];
    }
}

- (Stmt *)forStatement {
    [self consume:@"L_PAREN" message:@"Expect '(' after 'for'."];

    Stmt *initializer = nil;
    if ([self match:@[@"VAR"]]) {
        initializer = [self varDeclaration];
    }
    else if (![self match:@[@"SEMICOLON"]]) {
        initializer = [self expressionStatement];
    }

    Stmt *condition = nil;
    if (![self check:@"SEMICOLON"]) {
        condition = [self expression];
    }

    [self consume:@"SEMICOLON" message:@"Expect ';' after loop condition."];

    Stmt *increment = nil;
    if (![self check:@"R_PAREN"]) {
        increment = [self expression];
    }

    [self consume:@"R_PAREN" message:@"Expect ')' after for clauses."];

    Stmt *body = [self statement];

    if (increment) {
        Expression *incrementExpression = [[Expression alloc] initWithExpression:increment];
        body = [[Block alloc] initWithStatements:@[body, incrementExpression]];
    }

    if (condition == Nil) {
        condition = [[Literal alloc] initWithValue:@YES];
    }

    Stmt *body = [[While alloc] initWithCondition:condition body:body];

    if (initializer) {
        body = [[Block alloc] initWithStatements:@[initializer, body]];
    }

    return body;
}

- (Stmt *)ifStatement {
    [self consume:@"L_PAREN" message:@"Expect '(' after 'if'."];
    Expr *condition = [self expression];
    [self consume:@"R_PAREN" message:@"Expect ')' after if condition."];

    Stmt *thenBranch = [self statement];
    Stmt *elseBranch = nil;

    if ([self match:@[@"ELSE"]]) {
        elseBranch = [self statement];
    }

    return [[If alloc] initWithCondition:condition thenBranch:thenBranch elseBranch:elseBranch];
}

- (Stmt *)varDeclaration {
    Token *name = [self consume:@"IDENTIFIER" message:@"Expect variable name."];

    Expr *initializer = nil;
    if ([self match:@[@"EQUAL"]]) {
        initializer = [self expression];
    }

    [self consume:@"SEMICOLON" message:@"Expect ';' after variable declaration."];
    return [[Var alloc] initWithName:name initializer:initializer];
}

- (Stmt *)whileStatement {
    [self consume:@"L_PAREN" message:@"Expect '(' after 'while'."];
    Expr *condition = [self expression];
    [self consume:@"R_PAREN" message:@"Expect ')' after while condition."];
    Stmt *body = [self statement];

    return [[While alloc] initWithCondition:condition body:body];
}

- (Stmt *)printStatement {
    Expr *value = [self expression];
    [self consume:@"SEMICOLON" message:@"Expect ';' after value."];
    return [[Print alloc] initWithValue:value];
}

- (Stmt *)expressionStatement {
    Expr *expression = [self expression];
    [self consume:@"SEMICOLON" message:@"Expect ';' after expression."];
    return [[ExpressionStatement alloc] initWithExpression:expression];
}

- (NSMutableArray *)block {
    NSMutableArray *statements = [NSMutableArray array];

    while (![self check:@"R_BRACE"] && ![self isAtEnd]) {
        [statements addObject:[self declaration]];
    }

    [self consume:@"R_BRACE" message:@"Expect '}' after block."];
    return statements;
}

- (Expr *)expression {
    return [self assignment];
}

- (Expr *)assignment {
    Expr *expr = [self OR];

    if ([self match:@[@"EQ"]]) {
        Token *equals = [self previous];
        Expr *value = [self assignment];

        if ([expr isKindOfClass:[Variable class]]) {
            Token *name = expr.name;
            return [[Assign alloc] initWithName:name value:value];
        }
        else {
            [Lox error:equals message:@"Invalid assignment target."];
        }
    }

    return expr;
}

- (Expr *)OR {
    Expr *expr = [self AND];

    while ([self match:@[@"OR"]]) {
        Token *operator = [self previous];
        Expr *right = [self AND];
        expr = [[Logical alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (Expr *)AND {
    Expr *expr = [self equality];

    while ([self match:@[@"AND"]]) {
        Token *operator = [self previous];
        Expr *right = [self equality];
        expr = [[Logical alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (Expr *)equality {
    Expr *expr = [self comparison];

    while ([self match:@[@"BANG_EQ", @"IS_EQ"]]) {
        Token *operator = [self previous];
        Expr *right = [self comparison];
        expr = [[Binary alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (Expr *)comparison {
    Expr *expr = [self term];

    while ([self match:@[@"LT", @"LT_EQ", @"GR", @"GR_EQ"]]) {
        Token *operator = [self previous];
        Expr *right = [self term];
        expr = [[Binary alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (Expr *)term {
    Expr *expr = [self factor];

    while ([self match:@[@"PLUS", @"MINUS"]]) {
        Token *operator = [self previous];
        Expr *right = [self factor];
        expr = [[Binary alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (Expr *)factor {
    Expr *expr = [self unary];

    while ([self match:@[@"STAR", @"SLASH"]]) {
        Token *operator = [self previous];
        Expr *right = [self unary];
        expr = [[Binary alloc] initWithLeft:expr operator:operator right:right];
    }

    return expr;
}

- (Expr *)unary {
    if ([self match:@[@"BANG", @"MINUS"]]) {
        Token *operator = [self previous];
        Expr *right = [self unary];
        return [[Unary alloc] initWithOperator:operator right:right];
    }

    return [self primary];
}

- (Expr *)primary {
    if ([self match:@[@"FALSE"]]) {
        return [[Literal alloc] initWithValue:@NO];
    }
    else if ([self match:@[@"TRUE"]]) {
        return [[Literal alloc] initWithValue:@YES];
    }
    else if ([self match:@[@"NIL"]]) {
        return [[Literal alloc] initWithValue:nil];
    }
    else if ([self match:@[@"NUMBER", @"STRING"]]) {
        return [[Literal alloc] initWithValue:@([self previous].literal)];
    }
    else if ([self match:@[@"IDENTIFIER"]]) {
        return [[Variable alloc] initWithValue:[self previous]];
    }
    else if ([self match:@[@"L_PAREN"]]) {
        Expr *expr = [self expression];
        [self consume:@"R_PAREN" message:@"Expect ')' after expression."];
        return [[Grouping alloc] initWithExpression:expr];
    }
    else {
        [Lox error:[self peek] message:@"Expect expression."];
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
        [Lox error:[self peek] message:message];
        return nil;
    }
}

- (BOOL)check:(NSString *)type {
    if ([self isAtEnd]) {
        return NO;
    }

    return [self peek].token_type == type;
}

- (Token *)advance {
    if (![self isAtEnd]) {
        self.current++;
    }
    return [self previous];
}

- (BOOL)isAtEnd {
    return [self peek].token_type == @"EOF";
}

- (Token *)peek {
    return [self.tokens objectAtIndex:self.current];
}

- (Token *)previous {
    return [self.tokens objectAtIndex:self.current - 1];
}

- (void)synchronize {
    [self advance];

    while (![self isAtEnd]) {
        if ([self previous].token_type == "SEMICOLON") {
            return;
        }

        switch ([self peek].token_type) {
            case @"CLASS": 
            case @"FUN":
            case @"VAR":
            case @"FOR":
            case @"IF":
            case @"WHILE":
            case @"PRINT":
            case @"RETURN":
                return;
        }

        [self advance];
    }
}
