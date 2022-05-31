#import "stmt.h"
#import "expr.h"
#import "token.h"

@implementation Stmt
+ (void)accept:(id *)visitor {
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
- (instancetype)initWithStatements:(NSMutableArray *)statements {
    if (self = [super init]) {
        self.statements = statements;
    }
    return self;
}

// - (void)accept:(id *)visitor {
//     [visitor visitBlock:self];
// }

@end

@interface Expression : Stmt
- (instancetype)initWithExpression:(Expr *)expression {
    if (self = [super init]) {
        self.expression = expression;
    }
    return self;
}
// - (void)accept:(id *)visitor {
//     [visitor visitExpression:self];
// }
@end

@interface If : Stmt
- (instancetype)initWithCondition:(Expr *)condition thenBranch:(Stmt *)thenBranch elseBranch:(Stmt *)elseBranch {
    if (self = [super init]) {
        self.condition = condition;
        self.thenBranch = thenBranch;
        self.elseBranch = elseBranch;
    }
    return self;
}
// - (void)accept:(id *)visitor {
//     [visitor visitIf:self];
// }
@end

@interface Print : Stmt
- (instancetype)initWithExpression:(Expr *)expression {
    if (self = [super init]) {
        self.expression = expression;
    }
    return self;
}
// - (void)accept:(id *)visitor {
//     [visitor visitPrint:self];
// }
@end

@interface Var : Stmt
- (instancetype)initWithName:(Token *)name initializer:(Expr *)initializer {
    if (self = [super init]) {
        self.name = name;
        self.initializer = initializer;
    }
    return self;
}
// - (void)accept:(id *)visitor {
//     [visitor visitVar:self];
// }
@end

@interface While : Stmt
- (instancetype)initWithCondition:(Expr *)condition body:(Stmt *)body {
    if (self = [super init]) {
        self.condition = condition;
        self.body = body;
    }
    return self;
}
// - (void)accept:(id *)visitor {
//     [visitor visitWhile:self];
// }
@end