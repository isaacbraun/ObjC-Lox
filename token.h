#import <Foundation/Foundation.h>

@interface Token : NSObject {
    NSString *token_type;
    NSString *lexeme;
    NSString *literal;
    int line;
}

@property(nonatomic, readwrite, retain) NSString *token_type;
@property(nonatomic, readwrite, retain) NSString *lexeme;
@property(nonatomic, readwrite, retain) NSString *literal;
@property(nonatomic, readwrite) int line;

- (instancetype)initWithData:(NSString *)type lexeme:(NSString *)lexeme literal:(NSString *)literal line:(int)line;
- (void)print;

@end