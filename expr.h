#import <Foundation/Foundation.h>
#import "token.h"

@interface Expr : NSObject
+ (id)accept:(id)expr vistor:(id)visitor;
@end


@interface Assign : Expr {
    Token *name;
    Expr *value;
}
@property(nonatomic, readwrite, retain) Token *name;
@property(nonatomic, readwrite, retain) Expr *value;
- (instancetype)initWithName:(Token *)param_name value:(Expr *)param_value;
@end

@interface Math : Expr {
    Expr *left;
    Token *operator;
    Expr *right;
}
@property(nonatomic, readwrite, retain) Expr *left;
@property(nonatomic, readwrite, retain) Token *operator;
@property(nonatomic, readwrite, retain) Expr *right;
- (instancetype)initWithLeft:(Expr *)param_left operator:(Token *)param_operator right:(Expr *)param_right;
@end

@interface Binary : Expr {
    Expr *left;
    Token *operator;
    Expr *right;
}
@property(nonatomic, readwrite, retain) Expr *left;
@property(nonatomic, readwrite, retain) Token *operator;
@property(nonatomic, readwrite, retain) Expr *right;
- (instancetype)initWithLeft:(Expr *)param_left operator:(Token *)param_operator right:(Expr *)param_right;
@end


@interface Grouping : Expr {
    Expr *expression;
}
@property(nonatomic, readwrite, retain) Expr *expression;
- (instancetype)initWithExpression:(Expr *)param_expression;
@end


@interface Literal : Expr {
    id value;
}
@property(nonatomic, readwrite, retain) id value;
- (instancetype)initWithValue:(id)param_value;
@end


@interface Logical : Expr {
    Expr *left;
    Token *operator;
    Expr *right;
}
@property(nonatomic, readwrite, retain) Expr *left;
@property(nonatomic, readwrite, retain) Token *operator;
@property(nonatomic, readwrite, retain) Expr *right;
- (instancetype)initWithLeft:(Expr *)param_left operator:(Token *)param_operator right:(Expr *)param_right;
@end


@interface Unary : Expr {
    Token *operator;
    Expr *right;
}
@property(nonatomic, readwrite, retain) Token *operator;
@property(nonatomic, readwrite, retain) Expr *right;
- (instancetype)initWithOperator:(Token *)param_operator right:(Expr *)param_right;
@end


@interface Negate : Expr {
    Token *operator;
    Expr *right;
}
@property(nonatomic, readwrite, retain) Token *operator;
@property(nonatomic, readwrite, retain) Expr *right;
- (instancetype)initWithOperator:(Token *)param_operator right:(Expr *)param_right;
@end


@interface Variable : Expr {
    Token *name;
}
@property(nonatomic, readwrite, retain) Token *name;
- (instancetype)initWithName:(Token *)param_name;
@end