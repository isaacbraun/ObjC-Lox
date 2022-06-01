#import "interpreter.h"
#import "stmt.h"
#import "expr.h"
#import "token.h"
#import "lox.h"
#import "environment.h"

@implementation Interpreter
- (instancetype)initWithStatements:(NSMutableArray *)param_statements andLox:(Lox *)param_lox {
    if ((self = [super init])) {
        environment = [[Environment alloc] initWithLox:param_lox andEnclosing:nil];
        statements = param_statements;
        lox = param_lox;
    }
    return self;
    
}

- (void)interpret {
    @try {
        for (Stmt *stmt in statements) {
            [self execute:stmt];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        // [lox runtimeError:exception.line withMessage:exception.reason];
        // [lox runtimeError:exception.reason];
    }
}

- (NSString *)visitLiteral:(Literal *)expr {
    return expr.value;
}

- (id)visitLogical:(Logical *)expr {
    id left = [self evaluate:expr.left];
    if ([expr.operator.token_type isEqualToString:@"OR"]) {
        if ([self isTruthy:left]) {
            return left;
        }
    }
    else {
        if (![self isTruthy:left]) {
            return left;
        }
    }
    return [self evaluate:expr.right];
}

- (BOOL)visitUnary:(Unary *)expr {
    id right = [self evaluate:expr.right];
    if ([expr.operator.token_type isEqualToString:@"BANG"]) {
        return ![self isTruthy:right];
    }
    return NO;
}

- (NSNumber *)visitNegate:(Negate *)expr {
    id right = [self evaluate:expr.right];
    if ([expr.operator.token_type isEqualToString:@"MINUS"]) {
        return [NSNumber numberWithDouble:-1 * [right doubleValue]];
    }
    return nil;
}

- (NSString *)visitVariable:(Variable *)expr {
    return [environment get:expr.name];
}

- (id)visitGrouping:(Grouping *)expr {
    return [self evaluate:expr.expression];
}

- (void)visitBlock:(Block *)stmt {
    [self executeBlock:stmt.statements withEnvironment:environment];
}

- (id)visitExpression:(Expression *)stmt {
    return [self evaluate:stmt.expression];
}

- (void)visitIf:(If *)stmt {
    id condition = [self evaluate:stmt.condition];

    if ([self isTruthy:condition]) {
        [self execute:stmt.thenBranch];
    }
    else if (stmt.elseBranch != nil) {
        [self execute:stmt.elseBranch];
    }
}

- (void)visitPrint:(Print *)stmt {
    id value = [self evaluate:stmt.expression];
    NSLog(@"%@", [self stringify:value]);
}

- (void)visitVar:(Var *)stmt {
    id value = nil;
    if (stmt.initializer != nil) {
        value = [self evaluate:stmt.initializer];
    }
    [environment define:stmt.name.lexeme value:value];
}

- (void)visitWhile:(While *)stmt {
    while ([self isTruthy:[self evaluate:stmt.condition]]) {
        [self execute:stmt.body];
    }
}

- (id)visitAssign:(Assign *)expr {
    id value = [self evaluate:expr.value];
    [environment assign:expr.name value:value];
    return value;
}

- (id)visitMath:(Math *)expr {
    id left = [self evaluate:expr.left];
    id right = [self evaluate:expr.right];

    if ([expr.operator.token_type isEqualToString:@"MINUS"]) {
        [self checkNumberOperands:expr.operator left:left right:right];
        return [NSNumber numberWithDouble:[left doubleValue] - [right doubleValue]];
    }
    else if ([expr.operator.token_type isEqualToString:@"SLASH"]) {
        [self checkNumberOperands:expr.operator left:left right:right];
        return [NSNumber numberWithDouble:[left doubleValue] / [right doubleValue]];
    }
    else if ([expr.operator.token_type isEqualToString:@"STAR"]) {
        [self checkNumberOperands:expr.operator left:left right:right];
        return [NSNumber numberWithDouble:[left doubleValue] * [right doubleValue]];
    }
    else if ([expr.operator.token_type isEqualToString:@"PLUS"]) {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left stringByAppendingString:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [NSNumber numberWithDouble:[left doubleValue] + [right doubleValue]];
        }
    }
    else {
        return nil;
    }
}

- (BOOL)visitBinary:(Binary *)expr {
    id left = [self evaluate:expr.left];
    id right = [self evaluate:expr.right];

    if ([expr.operator.token_type isEqualToString:@"GR"]) {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left isGreaterThan:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [left doubleValue] > [right doubleValue];
        }
    }
    else if ([expr.operator.token_type isEqualToString:@"GR_EQ"]) {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left isGreaterThanOrEqualTo:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [left doubleValue] >= [right doubleValue];
        }
    }
    else if ([expr.operator.token_type isEqualToString:@"LT"]) {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left isLessThan:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [left doubleValue] < [right doubleValue];
        }
    }
    else if ([expr.operator.token_type isEqualToString:@"LT_EQ"]) {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left isLessThanOrEqualTo:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [left doubleValue] <= [right doubleValue];
        }
    }
    else if ([expr.operator.token_type isEqualToString:@"IS_EQ"]) {
        return [left isEqualTo:right];
    }
    else if ([expr.operator.token_type isEqualToString:@"BANG_EQ"]) {
        return ![left isEqualTo:right];
    }
    else {
        return NO;
    }
}

- (BOOL)checkNumberOperand:(Token *)operator operand:(Token *)operand {
    if ([operand.token_type isEqualToString:@"NUMBER"]) {
        return YES;
    }
    else {
        [lox error:(NSNumber *)operator.line message:@"Operand must be a number."];
        return NO;
    }
}

- (BOOL)checkNumberOperands:(Token *)operator left:(Token *)left right:(Token *)right {
    if ([left.token_type isEqualToString:@"NUMBER"] && [right.token_type isEqualToString:@"NUMBER"]) {
        return YES;
    }
    else {
        [lox error:(NSNumber *)operator.line message:@"Operands must be numbers."];
        return NO;
    }
}

- (BOOL)checkStringOperands:(Token *)operator left:(Token *)left right:(Token *)right {
    if ([left.token_type isEqualToString:@"STRING"] && [right.token_type isEqualToString:@"STRING"]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isTruthy:(id)object {
    if (object == nil || [object isEqualToString:@"nil"] || [object isEqualToString:@"false"]) {
        return NO;
    }
    // if (object == @"true" || object == @"1" || object == @(1)) {
    //     return YES;
    // }
    return YES;
}

- (NSString *)stringify:(id)object {
    if (object == nil) {
        return @"nil";
    }

    if ([object isKindOfClass:[NSNumber class]]) {
        NSString *text = [object stringValue];
        if ([text hasSuffix:@".0"]) {
            text = [text substringToIndex:text.length - 2];
        }

        return text;
    }

    NSString *output = [NSString stringWithFormat:@"%@", object];

    if ([output isEqualToString:@"YES"]) {
        return @"true";
    }
    else if ([output isEqualToString:@"NO"]) {
        return @"false";
    }

    return output;
}

- (id)evaluate:(id)expr {
    NSString *methodName = [NSString stringWithFormat:@"visit%@:", [expr class]];
    SEL selector = NSSelectorFromString(methodName);

    if ([self respondsToSelector:selector]) {
        return [self performSelector:selector withObject:expr];
    }
    else {
        NSLog(@"Invalid Expression");
        return nil;
    }
}

- (void)execute:(id)stmt {
    NSString *methodName = [NSString stringWithFormat:@"visit%@:", [stmt class]];
    SEL selector = NSSelectorFromString(methodName);

    if ([self respondsToSelector:selector]) {
        [self performSelector:selector withObject:stmt];
    }
}

- (void)executeBlock:(NSMutableArray *)statements withEnvironment:(Environment *)param_environment {
    Environment *previous = environment;

    @try {
        environment = param_environment;

        for (Stmt *stmt in statements) {
            [self execute:stmt];
        }
    }
    @finally {
        environment = previous;
    }
}

@end