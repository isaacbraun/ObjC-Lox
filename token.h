#import <Foundation/Foundation.h>

@interface Token : NSOjbect

@property NSString *token_type;
@property NSString *lexeme;
@property NSString *literal;
@property int *line;

- (instancetype)initWithData:(NSString)type lexeme:(NSString)lexeme literal:(NSString)literal line:(int)line;
+ (NSString)print;

@end