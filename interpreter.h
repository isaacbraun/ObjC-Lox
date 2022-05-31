#import <Foundation/Foundation.h>
#import "stmt.h"
#import "expr.h"
#import "token.h"
#import "environment.h"

@interface Interpreter : NSObject

@property(nonatomic, readwrite) Environment *environment;

- (instancetype)init;
- (void)interpret:(NSMutableArray *)statements;
- (NSString *)visitLiteral:(Expr *)expr;
- (id)visitLogical:(Expr *)expr;
- (id)visitUnary:(Expr *)expr;
- (NSString *)visitVariable:(Expr *)expr;
- (id)visitGrouping:(Expr *)expr;
- (id)visitBlock:(Expr *)expr;
- (id)visitExpression:(Expr *)expr;
- (id)visitIf:(Expr *)expr;
- (id)visitPrint:(Expr *)expr;
- (id)visitVar:(Expr *)expr;
- (id)visitWhile:(Expr *)expr;
- (id)visitAssign:(Expr *)expr;
- (id)visitBinary:(Expr *)expr;
- (BOOL *)checkNumberOperand:(Token *)operator operand:(Expr *)operand;
- (BOOL *)checkNumberOperands:(Token *)operator left:(Expr *)left right:(Expr *)right;
- (BOOL *)checkStringOperands:(Token *)operator left:(Expr *)left right:(Expr *)right;
- (BOOL *)isTruthy:(id)object;
// - (BOOL *)isEqual:(id)a b:(id)b;
- (NSString *)stringify:(id)object;
- (id)evaluate:(Expr *)expr;
- (void)execute:(Stmt *)stmt;
- (void)executeBlock:(NSMutableArray *)statements withEnvironment:(Environment *)environment;

@end