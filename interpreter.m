#import "interpreter.h"
#import "stmt.h"
#import "expr.h"
#import "token.h"
#import "lox.h"

@implementation Interpreter
- (instancetype)init {
    if (self = [super init]) {
        _environment = [[Environment alloc] init];
    }
    return self;
    
}

- (void)interpret:(NSMutableArray *)statements {
    @try {
        for (Stmt *stmt in statements) {
            [self execute:stmt];
            
        }
    }
    @catch (NSException *exception) {
        [lox runtimeError:exception.reason];
    }
}

- (NSString *)visitLiteral:(Expr *)expr {
    return expr.value;
}

- (id)visitLogical:(Expr *)expr {
    id left = [self evaluate:expr.left];
    if (expr.operator.token_type == @"OR") {
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

- (id)visitUnary:(Expr *)expr {
    id right = [self evaluate:expr.right];
    if (expr.operator.token_type == @"BANG") {
        return ![self isTruthy:right];
    }
    else if (expr.operator.token_type == @"MINUS") {
        [self checkNumberOperand:expr.operator operand:right];
        return @(-[right doubleValue]);
    }
    return nil;
}

- (NSString *)visitVariable:(Expr *)expr {
    return [_environment get:expr.name];
}

- (id)visitGrouping:(Expr *)expr {
    return [self evaluate:expr.expression];
}

- (id)visitBlock:(Stmt *)stmt {
    [self executeBlock:stmt.statements withEnvironment:_environment];
}

- (id)visitExpression:(Stmt *)stmt {
    return [self evaluate:stmt.expression];
}

- (id)visitIf:(Stmt *)stmt {
    id condition = [self evaluate:stmt.condition];

    if ([self isTruthy:condition]) {
        [self execute:stmt.thenBranch];
    }
    else if (stmt.elseBranch != nil) {
        [self execute:stmt.elseBranch];
    }
    else {
        return nil;
    }
}

- (id)visitPrint:(Stmt *)stmt {
    id value = [self evaluate:stmt.expression];
    NSLog(@"%@", [self stringify:value]);
}

- (id)visitVar:(Stmt *)stmt {
    id value = nil;
    if (stmt.initializer != nil) {
        value = [self evaluate:stmt.initializer];
    }

    [_environment define:stmt.name.lexeme value:value];
    return nil;
}

- (id)visitWhile:(Stmt *)stmt {
    while ([self isTruthy:[self evaluate:stmt.condition]]) {
        [self execute:stmt.body];
    }

    return nil;
}

- (id)visitAssign:(Expr *)expr {
    id value = [self evaluate:expr.value];
    [_environment assign:expr.name value:value];
    return value;
}

- (id)visitBinary:(Expr *)expr {
    id left = [self evaluate:expr.left];
    id right = [self evaluate:expr.right];

    if (expr.operator.token_type == @"MINUS") {
        [self checkNumberOperands:expr.operator left:left right:right];
        return [NSNumber numberWithDouble:[left doubleValue] - [right doubleValue]];
    }
    else if (expr.operator.token_type == @"SLASH") {
        [self checkNumberOperands:expr.operator left:left right:right];
        return [NSNumber numberWithDouble:[left doubleValue] / [right doubleValue]];
    }
    else if (expr.operator.token_type == @"STAR") {
        [self checkNumberOperands:expr.operator left:left right:right];
        return [NSNumber numberWithDouble:[left doubleValue] * [right doubleValue]];
    }
    else if (expr.operator.token_type == @"PLUS") {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left stringByAppendingString:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [NSNumber numberWithDouble:[left doubleValue] + [right doubleValue]];
        }
    }
    else if (expr.operator.token_type == @"GR") {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left isGreaterThan:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [left doubleValue] > [right doubleValue];
        }
    }
    else if (expr.operator.token_type == @"GR_EQ") {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left isGreaterThanOrEqualTo:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [left doubleValue] >= [right doubleValue];
        }
    }
    else if (expr.operator.token_type == @"LT") {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left isLessThan:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [left doubleValue] < [right doubleValue];
        }
    }
    else if (expr.operator.token_type == @"LT_EQ") {
        if ([self checkStringOperands:expr.operator left:left right:right]) {
            return [left isLessThanOrEqualTo:right];
        }
        else {
            [self checkNumberOperands:expr.operator left:left right:right];
            return [left doubleValue] <= [right doubleValue];
        }
    }
    else if (expr.operator.token_type == @"IS_EQ") {
        return [left isEqualTo:right];
    }
    else if (expr.operator.token_type == @"BANG_EQ") {
        return ![left isEqualTo:right];
    }
    
    return nil;
}

- (BOOL *)checkNumberOperand:(Token *)operator operand:(Expr *)operand {
    if ([operand.token_type isEqualToString:@"NUMBER"]) {
        return YES;
    }
    [lox error:operator.line message:@"Operand must be a number."];
}

- (BOOL *)checkNumberOperands:(Token *)operator left:(Expr *)left right:(Expr *)right {
    if ([left.token_type isEqualToString:@"NUMBER"] && [right.token_type isEqualToString:@"NUMBER"]) {
        return YES;
    }
    [lox error:operator.line message:@"Operands must be numbers."];
}

- (BOOL *)checkStringOperands:(Token *)operator left:(Expr *)left right:(Expr *)right {
    if ([left.token_type isEqualToString:@"STRING"] && [right.token_type isEqualToString:@"STRING"]) {
        return YES;
    }
    // [lox error:operator.line message:@"Operands must be strings."];
}

- (BOOL *)isTruthy:(id)object {
    if (object == nil || object == @"nil" || object == @"false") {
        return NO;
    }
    if ([object isKindOfClass:[BOOL class]]) {
        return object;
    }
    return YES;
}

// - (BOOL *)isEqual:(id)a b:(id)b

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

    NSString *output = (NSString) object;

    if (output == YES) {
        return @"true";
    }
    else if (output == NO) {
        return @"false";
    }

    return nil;
}

- (id)evaluate:(Expr *)expr {
    return [expr accept:self];
}

- (void)execute:(Stmt *)stmt {
    [stmt accept:self];
}

- (void)executeBlock:(NSMutableArray *)statements withEnvironment:(Environment *)environment {
    Environment *previous = _environment;

    @try {
        _environment = environment;

        for (Stmt *stmt in statements) {
            [self execute:stmt];
        }
    }
    @finally {
        _environment = previous;
    }
}

@end