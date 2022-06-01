#import <Foundation/Foundation.h>
#import "token.h"
#import "expr.h"

@interface Stmt : NSObject
@end

@interface Block : Stmt {
    NSMutableArray *statements;
}
@property(nonatomic, readwrite, retain) NSMutableArray *statements;
- (instancetype)initWithStatements:(NSMutableArray *)param_statements;
@end

@interface Expression : Stmt {
    Expr *expression;
}
@property(nonatomic, readwrite, retain) Expr *expression;
- (instancetype)initWithExpression:(Expr *)param_expression;
@end

@interface If : Stmt {
    Expr *condition;
    Stmt *thenBranch;
    Stmt *elseBranch;
}
@property(nonatomic, readwrite, retain) Expr *condition;
@property(nonatomic, readwrite, retain) Stmt *thenBranch;
@property(nonatomic, readwrite, retain) Stmt *elseBranch;
- (instancetype)initWithCondition:(Expr *)param_condition thenBranch:(Stmt *)param_thenBranch elseBranch:(Stmt *)param_elseBranch;
@end

@interface Print : Stmt {
    Expr *expression;
}
@property(nonatomic, readwrite, retain) Expr *expression;
- (instancetype)initWithExpression:(Expr *)param_expression;
@end

@interface Var : Stmt {
    Token *name;
    Expr *initializer;
}
@property(nonatomic, readwrite, retain) Token *name;
@property(nonatomic, readwrite, retain) Expr *initializer;
- (instancetype)initWithName:(Token *)param_name initializer:(Expr *)param_initializer;
@end

@interface While : Stmt {
    Expr *condition;
    Stmt *body;
}
@property(nonatomic, readwrite, retain) Expr *condition;
@property(nonatomic, readwrite, retain) Stmt *body;
- (instancetype)initWithCondition:(Expr *)param_condition body:(Stmt *)param_body;
@end