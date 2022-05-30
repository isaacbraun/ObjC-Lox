#import <Foundation/Foundation.h>
#import "token.h"
#import "expr.h"

@interface Stmt : NSObject
@end

@interface Block : Stmt
@property (nonatomic, strong) NSMutableArray *statements;
- (instancetype)initWithStatements:(NSMutableArray *)statements;
- (void)accept:(Visitor *)visitor;
@end

@interface Expression : Stmt
@property (nonatomic, strong) Expr *expression;
- (instancetype)initWithExpression:(Expr *)expression;
- (void)accept:(Visitor *)visitor;
@end

@interface If : Stmt
@property (nonatomic, strong) Expr *condition;
- (instancetype)initWithCondition:(Expr *)condition thenBranch:(Stmt *)thenBranch elseBranch:(Stmt *)elseBranch;
- (void)accept:(Visitor *)visitor;
@end

@interface Print : Stmt
@property (nonatomic, strong) Expr *expression;
- (instancetype)initWithExpression:(Expr *)expression;
- (void)accept:(Visitor *)visitor;
@end

@interface Var : Stmt
@property (nonatomic, strong) Token *name;
- (instancetype)initWithName:(Token *)name initializer:(Expr *)initializer;
- (void)accept:(Visitor *)visitor;
@end

@interface While : Stmt
@property (nonatomic, strong) Expr *condition;
- (instancetype)initWithCondition:(Expr *)condition body:(Stmt *)body;
- (void)accept:(Visitor *)visitor;
@end