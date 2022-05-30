#import "token.h"

@implementation Token

- (instancetype)initWithData:(NSString)type lexeme:(NSString)lexeme literal:(NSString)literal line:(int)line {
    self = [super init]
    if (self) {
        _token_type = type;
        _lexeme = lexeme;
        _literal = literal;
        _line = line;
    }
    return self;
}

+ (NSString)print {
    return @"%@ %@ %@", _token_type, _lexeme, _literal;
}

@end