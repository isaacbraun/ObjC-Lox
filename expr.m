#import "expr.h"
#import "interpreter.h"
#import "token.h";

@implementation Assign
- (instancetype)initWithName:(Token *)name value:(Expr *)value {
    if (self = [super init]) {
        _name = name;
        _value = value;
    }
    return self;
}
- (void)accept:(id *)visitor {
    [visitor visitAssign:self];
}
@end

@implementation Binary
- (instancetype)initWithLeft:(Expr *)left operator:(Token *)operator right:(Expr *)right {
    if (self = [super init]) {
        _left = left;
        _operator = operator;
        _right = right;
    }
    return self;
}
- (void)accept:(id *)visitor {
    [visitor visitBinary:self];
}
@end

@implementation Grouping
- (instancetype)initWithExpression:(Expr *)expression {
    if (self = [super init]) {
        _expression = expression;
    }
    return self;
}
- (void)accept:(id *)visitor {
    [visitor visitGrouping:self];
}
@end

@implementation Literal
- (instancetype)initWithValue:(id)value {
    if (self = [super init]) {
        _value = value;
    }
    return self;
}
- (void)accept:(id *)visitor {
    [visitor visitLiteral:self];
}
@end

@implementation Logical
- (instancetype)initWithLeft:(Expr *)left operator:(Token *)operator right:(Expr *)right {
    if (self = [super init]) {
        _left = left;
        _operator = operator;
        _right = right;
    }
    return self;
}
- (void)accept:(id *)visitor {
    [visitor visitLogical:self];
}
@end

@implementation Unary
- (instancetype)initWithOperator:(Token *)operator right:(Expr *)right {
    if (self = [super init]) {
        _operator = operator;
        _right = right;
    }
    return self;
}
- (void)accept:(id *)visitor {
    [visitor visitUnary:self];
}
@end

@implementation Variable
- (instancetype)initWithName:(Token *)name {
    if (self = [super init]) {
        _name = name;
    }
    return self;
}
- (void)accept:(id *)visitor {
    [visitor visitVariable:self];
}
@end