#import <Foundation/Foundation.h>
#import "stmt.h"
#import "expr.h"
#import "token.h"
#import "environment.h"

@interface Interpreter : NSObject {
    Environment *environment;
    Lox *lox;
}

// @property(nonatomic, readwrite, retain) Environment *environment;

- (instancetype)initWithLox:(Lox *)param_lox;
- (void)interpret:(NSMutableArray *)statements;
- (NSString *)visitLiteral:(Literal *)expr;
- (id)visitLogical:(Logical *)expr;
- (BOOL)visitUnary:(Unary *)expr;
- (NSNumber *)visitNegate:(Negate *)expr;
- (NSString *)visitVariable:(Variable *)expr;
- (id)visitGrouping:(Grouping *)expr;
- (void)visitBlock:(Block *)stmt;
- (id)visitExpression:(Expression *)stmt;
- (void)visitIf:(If *)stmt;
- (void)visitPrint:(Print *)stmt;
- (void)visitVar:(Var *)stmt;
- (void)visitWhile:(While*)stmt;
- (id)visitAssign:(Assign *)expr;
- (id)visitMath:(Math *)expr;
- (BOOL)visitBinary:(Binary *)expr;
- (BOOL)checkNumberOperand:(Token *)operator operand:(Token *)operand;
- (BOOL)checkNumberOperands:(Token *)operator left:(Token *)left right:(Token *)right;
- (BOOL)checkStringOperands:(Token *)operator left:(Token *)left right:(Token *)right;
- (BOOL)isTruthy:(id)object;
// - (BOOL)isEqual:(id)a b:(id)b;
- (NSString *)stringify:(id)object;
- (id)evaluate:(Expr *)expr;
- (void)execute:(Stmt *)stmt;
- (void)executeBlock:(NSMutableArray *)statements withEnvironment:(Environment *)param_environment;

@end