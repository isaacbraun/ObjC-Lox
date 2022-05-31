#import <Foundation/Foundation.h>
#import "token.h"
#import "lox.h"

@interface Scanner : NSObject

@property(nonatomic, readwrite) NSString *source;
@property(nonatomic, readwrite) NSMutableArray *tokens;
@property(nonatomic, readwrite) int *start;
@property(nonatomic, readwrite) int *current;
@property(nonatomic, readwrite) int *line;

- (instancetype)initWithSource:(NSString *)source;
- (NSMutableDictionary *)GetLiteralTokenTypes;
- (NSMutableDictionary *)GetKeywordTokenTypes;
- (NSMutableArray)scanTokens;
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
- (void)addSingleToken:(NSString)tempType;
- (void)addToken:(NSString)tempType literal:(NSString *)literal;

@end