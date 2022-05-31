#import <Foundation/Foundation.h>
#import "token.h"
#import "lox.h"

@interface Scanner : NSObject {
    NSString *source;
    NSMutableArray *tokens;
    int current;
    int start;
    int line;
}

// @property(nonatomic, readwrite, retain) NSString *source;
// @property(nonatomic, readwrite, retain) NSMutableArray *tokens;
// @property(nonatomic, readwrite) int *start;
// @property(nonatomic, readwrite) int *current;
// @property(nonatomic, readwrite) int *line;

- (instancetype)initWithSource:(NSString *)param_source andLox:(Lox *)param_lox;
- (NSMutableDictionary *)GetLiteralTokenTypes;
- (NSMutableDictionary *)GetKeywordTokenTypes;
- (NSMutableArray *)scanTokens;
- (void)scanToken;
- (void)identifier;
- (void)string;
- (void)number;
- (BOOL)isDigit:(char)c;
- (BOOL)isAlpha:(char)c;
- (BOOL)isAlphaNumeric:(char)c;
- (BOOL)match:(char)expected;
- (BOOL)isAtEnd;
- (char)peek;
- (char)peekNext;
- (char)advance;
- (void)addSingleToken:(NSString *)tempType;
- (void)addToken:(NSString *)tempType literal:(NSString *)literal;

@end