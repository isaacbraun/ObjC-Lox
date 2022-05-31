#import <Foundation/Foundation.h>
#import "expr.h"
#import "stmt.h"
#import "token.h"

@interface Parser : NSObject
@property(nonatomic, readwrite) NSMutableArray *tokens;
@property(nonatomic, readwrite) NSNumber *current;

- (instancetype)initWithTokens:(NSMutableArray *)tokens;
- (NSMutableArray *)parse;
- (Stmt *)declaration;
- (Stmt *)statement;
- (Stmt *)forStatement;
- (Stmt *)ifStatement;
- (Stmt *)varDeclaration;
- (Stmt *)whileStatement;
- (Stmt *)printStatement;
- (Stmt *)expressionStatement;
- (NSMutableArray *)block;
- (Expr *)expression;
- (Expr *)assignment;
- (Expr *)OR;
- (Expr *)AND;
- (Expr *)equality;
- (Expr *)comparison;
- (Expr *)term;
- (Expr *)factor;
- (Expr *)unary;
- (Expr *)primary;
- (BOOL)match:(NSArray *)types;
- (Token *)consume:(NSString *)type message:(NSString *)message;
- (BOOL)check:(NSString *)type;
- (Token *)advance;
- (BOOL)isAtEnd;
- (Token *)peek;
- (Token *)previous;
- (void)synchronize;
@end