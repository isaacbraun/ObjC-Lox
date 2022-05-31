#import <Foundation/Foundation.h>
#import "token.h"

@interface Environment : NSObject

@property(nonatomic, readwrite) NSMutableDictionary *values;
@property(nonatomic, readwrite) Environment *enclosing;

- (instancetype)init;
- (instancetype)initWithEnclosing:(Environment)enclosing;
- (void)define:(NSString *)name value:(id)value;
- (id)get:(Token *)name;
- (void)assign:(Token *)name value:(id)value;

@end