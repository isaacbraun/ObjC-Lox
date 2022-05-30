#import <Foundation/Foundation.h>
#import "token.h"
#import "lox.h"

@interface Scanner : NSObject

@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, strong) int *start;
@property (nonatomic, strong) int *current;
@property (nonatomic, strong) int *line;

- (instancetype)initWithSource:(NSString *)source;
- (NSMutableDictionary *)GetLiteralTokenTypes;
- (NSMutableDictionary *)GetKeywordTokenTypes;
- (NSArray)scanTokens;
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