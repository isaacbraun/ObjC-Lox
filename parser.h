#import <Foundation/Foundation.h>
#import "expr.h"
#import "stmt.h"
#import "token.h"
#import "lox.h"

@interface Parser : NSObject {
    NSMutableArray *tokens;
    int current;
    Lox *lox;
}

- (instancetype)initWithTokens:(NSMutableArray *)param_tokens andLox:(Lox *)param_lox;
- (NSMutableArray *)parse;
- (id)declaration;
- (id)statement;
- (id)forStatement;
- (id)ifStatement;
- (id)varDeclaration;
- (id)whileStatement;
- (id)printStatement;
- (id)expressionStatement;
- (NSMutableArray *)block;
- (id)expression;
- (id)assignment;
- (id)OR;
- (id)AND;
- (id)equality;
- (id)comparison;
- (id)term;
- (id)factor;
- (id)unary;
- (id)primary;
- (BOOL)match:(NSArray *)types;
- (Token *)consume:(NSString *)type message:(NSString *)message;
- (BOOL)check:(NSString *)type;
- (Token *)advance;
- (BOOL)isAtEnd;
- (Token *)peek;
- (Token *)previous;
- (void)synchronize;
@end