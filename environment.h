#import <Foundation/Foundation.h>
#import "token.h"
#import "lox.h"

@interface Environment : NSObject {
    Environment *enclosing;
    NSMutableDictionary *values;
    Lox *lox;
}

@property(nonatomic, readwrite, retain) NSMutableDictionary *values;
@property(nonatomic, readwrite, retain) Environment *enclosing;

- (instancetype)initWithLox:(Lox *)param_lox andEnclosing:(Environment *)param_enclosing;
- (void)define:(NSString *)name value:(id)value;
- (id)get:(Token *)name;
- (void)assign:(Token *)name value:(id)value;

@end