#import <Foundation/Foundation.h>
#import "token.h"

@interface Lox : NSObject {
    BOOL hadError;
    BOOL hadRuntimeError;
}

// @property(nonatomic, readwrite) BOOL *hadError;
// @property(nonatomic, readwrite) BOOL *hadRuntimeError;

- (instancetype)init;
- (void)runFile:(NSString *)path;
- (void)runPrompt;
- (void)run:(NSString *)source;
- (void)error:(NSNumber *)line message:(NSString *)message;
- (void)runtimeError:(NSNumber *)line message:(NSString *)message;
- (void)parserError:(Token *)token message:(NSString *)message;
- (void)report:(NSNumber *)line where:(NSString *)where message:(NSString *)message;

@end