#import "token.h"

@implementation Token

- (instancetype)initWithData:(NSString *)type lexeme:(NSString *)lexeme literal:(NSString *)literal line:(int)line {
    self = [super init]
    if (self) {
        self.token_type = type;
        self.lexeme = lexeme;
        self.literal = literal;
        self.line = line;
    }
    return self;
}

+ (NSString *)print {
    return @"%@ %@ %@", self.token_type, self.lexeme, self.literal;
}

@end