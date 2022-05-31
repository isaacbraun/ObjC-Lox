#import <Foundation/Foundation.h>

@interface Token : NSOjbect

@property(nonatomic, readwrite) NSString *token_type;
@property(nonatomic, readwrite) NSString *lexeme;
@property(nonatomic, readwrite) NSString *literal;
@property(nonatomic, readwrite) int *line;

- (instancetype)initWithData:(NSString)type lexeme:(NSString)lexeme literal:(NSString)literal line:(int)line;
+ (NSString)print;

@end