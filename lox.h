#import <Foundation/Foundation.h>

@interface Lox : NSObject

@property(nonatomic, readwrite) BOOL *hadError;
@property(nonatomic, readwrite) BOOL *hadRuntimeError;

- (instancetype)init;
- (void)runFile:(NSString *)path;
- (void)runPrompt;
- (void)run:(NSString *)source;
+ (void)error:(NSNumber *)line message:(NSString *)message;
+ (void)runtimeError:(Error *)error;
+ (void)parserError:(Token *)token message:(NSString *)message;
+ (void)report:(NSNumber *)line where:(NSString *)where message:(NSString *)message;

@end