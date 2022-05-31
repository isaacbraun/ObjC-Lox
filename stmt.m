#import "stmt.h"
#import "expr.h"
#import "token.h"

@implementation Stmt
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

@implementation Block
@synthesize statements;

- (instancetype)initWithStatements:(NSMutableArray *)param_statements {
    if (self = [super init]) {
        self.statements = param_statements;
    }
    return self;
}
@end

@implementation Expression
@synthesize expression;

- (instancetype)initWithExpression:(Expr *)param_expression {
    if (self = [super init]) {
        self.expression = param_expression;
    }
    return self;
}
@end

@implementation If
@synthesize condition;
@synthesize thenBranch;
@synthesize elseBranch;

- (instancetype)initWithCondition:(Expr *)param_condition thenBranch:(Stmt *)param_thenBranch elseBranch:(Stmt *)param_elseBranch {
    if (self = [super init]) {
        self.condition = param_condition;
        self.thenBranch = param_thenBranch;
        self.elseBranch = param_elseBranch;
    }
    return self;
}
@end

@implementation Print
@synthesize expression;

- (instancetype)initWithExpression:(Expr *)param_expression {
    if (self = [super init]) {
        self.expression = param_expression;
    }
    return self;
}
@end

@implementation Var
@synthesize name;
@synthesize initializer;

- (instancetype)initWithName:(Token *)param_name initializer:(Expr *)param_initializer {
    if (self = [super init]) {
        self.name = param_name;
        self.initializer = param_initializer;
    }
    return self;
}
@end

@implementation While
@synthesize condition;
@synthesize body;

- (instancetype)initWithCondition:(Expr *)param_condition body:(Stmt *)param_body {
    if (self = [super init]) {
        self.condition = param_condition;
        self.body = param_body;
    }
    return self;
}
@end