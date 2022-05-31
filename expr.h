#import <Foundation/Foundation.h>
#import "token.h"

@interface Expr : NSObject
@end

@interface Assign : Expr
@property(nonatomic, readwrite) Token *name;
@property(nonatomic, readwrite) Expr *value;
- (instancetype)initWithName:(Token *)name value:(Expr *)value;
- (void)accept:(Visitor *)visitor;
@end

@interface Binary : Expr
@property(nonatomic, readwrite) Expr *left;
@property(nonatomic, readwrite) Token *operator;
@property(nonatomic, readwrite) Expr *right;
- (instancetype)initWithLeft:(Expr *)left operator:(Token *)operator right:(Expr *)right;
- (void)accept:(Visitor *)visitor;
@end

@interface Grouping : Expr
@property(nonatomic, readwrite) Expr *expression;
- (instancetype)initWithExpression:(Expr *)expression;
- (void)accept:(Visitor *)visitor;
@end

@interface Literal : Expr
@property(nonatomic, readwrite) id value;
- (instancetype)initWithValue:(id)value;
- (void)accept:(Visitor *)visitor;
@end

@interface Logical : Expr
@property(nonatomic, readwrite) Expr *left;
@property(nonatomic, readwrite) Token *operator;
@property(nonatomic, readwrite) Expr *right;
- (instancetype)initWithLeft:(Expr *)left operator:(Token *)operator right:(Expr *)right;
- (void)accept:(Visitor *)visitor;
@end

@interface Unary : Expr
@property(nonatomic, readwrite) Token *operator;
@property(nonatomic, readwrite) Expr *right;
- (instancetype)initWithOperator:(Token *)operator right:(Expr *)right;
- (void)accept:(Visitor *)visitor;
@end

@interface Variable : Expr
@property(nonatomic, readwrite) Token *name;
- (instancetype)initWithName:(Token *)name;
- (void)accept:(Visitor *)visitor;
@end