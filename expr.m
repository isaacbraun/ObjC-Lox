#import "expr.h"
#import "interpreter.h"
#import "token.h";

@implementation Assign
- (instancetype)initWithName:(Token *)name value:(Expr *)value {
    if (self = [super init]) {
        self.name = name;
        self.value = value;
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
        self.left = left;
        self.operator = operator;
        self.right = right;
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
        self.expression = expression;
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
        self.value = value;
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
        self.left = left;
        self.operator = operator;
        self.right = right;
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
        self.operator = operator;
        self.right = right;
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
        self.name = name;
    }
    return self;
}
- (void)accept:(id *)visitor {
    [visitor visitVariable:self];
}
@end