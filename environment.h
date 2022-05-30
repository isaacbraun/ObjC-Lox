#import <Foundation/Foundation.h>
#import "token.h"

@interface Environment : NSObject

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) Environment *enclosing;

- (instancetype)init;
- (instancetype)initWithEnclosing:(Environment)enclosing;
- (void)define:(NSString *)name value:(id)value;
- (id)get:(Token *)name;
- (void)assign:(Token *)name value:(id)value;

@end