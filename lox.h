#import <Foundation/Foundation.h>

@interface Lox : NSOjbect

@property (nonatomic, strong) BOOL *hadError;
@property (nonatomic, strong) BOOL *hadRuntimeError;

- (void)runFile:(NSString)path;
- (void)runPrompt;
- (void)run:(NSString)source;
+ (void)error:(NSNumber)line message:(NSString)message;
+ (void)runtimeError:(Error)error;
+ (void)parserError:(Token)token message:(NSString)message;
+ (void)report:(NSNumber)line where:(NSString)where message:(NSString)message;

@end