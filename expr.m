#import "expr.h"
#import "token.h"

@implementation Expr
+ (void)accept:(id)visitor {
    // https://stackoverflow.com/questions/9366079/visitor-pattern-in-objective-c
    Class class = [visitor class];
    while (class && class != [NSObject class])
    {
        NSString *methodName = [NSString stringWithFormat:@"visit%@:", class];
        SEL selector = NSSelectorFromString(methodName);
        if ([visitor respondsToSelector:selector])
        {
            [visitor performSelector:selector withObject:self];
            return;
        }
        class = [class superclass];
    }
}
@end

@implementation Assign
@synthesize name;
@synthesize value;

- (instancetype)initWithName:(Token *)param_name value:(Expr *)param_value {
    if (self = [super init]) {
        self.name = param_name;
        self.value = param_value;
    }
    return self;
}

@end

@implementation Binary
@synthesize left;
@synthesize operator;
@synthesize right;

- (instancetype)initWithLeft:(Expr *)param_left operator:(Token *)param_operator right:(Expr *)param_right {
    if (self = [super init]) {
        self.left = param_left;
        self.operator = param_operator;
        self.right = param_right;
    }
    return self;
}

@end

@implementation Grouping
@synthesize expression;

- (instancetype)initWithExpression:(Expr *)param_expression {
    if (self = [super init]) {
        self.expression = param_expression;
    }
    return self;
}

@end

@implementation Literal
@synthesize value;

- (instancetype)initWithValue:(id)param_value {
    if (self = [super init]) {
        self.value = param_value;
    }
    return self;
}

@end

@implementation Logical
@synthesize left;
@synthesize operator;
@synthesize right;

- (instancetype)initWithLeft:(Expr *)param_left operator:(Token *)param_operator right:(Expr *)param_right {
    if (self = [super init]) {
        self.left = param_left;
        self.operator = param_operator;
        self.right = param_right;
    }
    return self;
}

@end

@implementation Unary
@synthesize operator;
@synthesize right;

- (instancetype)initWithOperator:(Token *)param_operator right:(Expr *)param_right {
    if (self = [super init]) {
        self.operator = param_operator;
        self.right = param_right;
    }
    return self;
}

@end

@implementation Variable
@synthesize name;

- (instancetype)initWithName:(Token *)param_name {
    if (self = [super init]) {
        self.name = param_name;
    }
    return self;
}

@end