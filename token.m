#import "token.h"

@implementation Token

@synthesize token_type;
@synthesize lexeme;
@synthesize literal;
@synthesize line;

- (instancetype)initWithData:(NSString *)param_type lexeme:(NSString *)param_lexeme literal:(NSString *)param_literal line:(int)param_line {
    self = [super init];
    if (self) {
        self.token_type = param_type;
        self.lexeme = param_lexeme;
        self.literal = param_literal;
        self.line = param_line;
    }
    return self;
}

- (void)print {
    NSLog(@"%@ %@ %@", token_type, lexeme, literal);
}

@end