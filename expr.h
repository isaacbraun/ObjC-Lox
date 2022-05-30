#import <Foundation/Foundation.h>
#import "token.h"

@interface Expr : NSObject
@end

@interface Assign : Expr
@property (nonatomic, strong) Token *name;
@property (nonatomic, strong) Expr *value;
- (instancetype)initWithName:(Token *)name value:(Expr *)value;
- (void)accept:(Visitor *)visitor;
@end

@interface Binary : Expr
@property (nonatomic, strong) Expr *left;
@property (nonatomic, strong) Token *operator;
@property (nonatomic, strong) Expr *right;
- (instancetype)initWithLeft:(Expr *)left operator:(Token *)operator right:(Expr *)right;
- (void)accept:(Visitor *)visitor;
@end

@interface Grouping : Expr
@property (nonatomic, strong) Expr *expression;
- (instancetype)initWithExpression:(Expr *)expression;
- (void)accept:(Visitor *)visitor;
@end

@interface Literal : Expr
@property (nonatomic, strong) id value;
- (instancetype)initWithValue:(id)value;
- (void)accept:(Visitor *)visitor;
@end

@interface Logical : Expr
@property (nonatomic, strong) Expr *left;
@property (nonatomic, strong) Token *operator;
@property (nonatomic, strong) Expr *right;
- (instancetype)initWithLeft:(Expr *)left operator:(Token *)operator right:(Expr *)right;
- (void)accept:(Visitor *)visitor;
@end

@interface Unary : Expr
@property (nonatomic, strong) Token *operator;
@property (nonatomic, strong) Expr *right;
- (instancetype)initWithOperator:(Token *)operator right:(Expr *)right;
- (void)accept:(Visitor *)visitor;
@end

@interface Variable : Expr
@property (nonatomic, strong) Token *name;
- (instancetype)initWithName:(Token *)name;
- (void)accept:(Visitor *)visitor;
@end