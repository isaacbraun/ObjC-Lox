#import <Foundation/Foundation.h>
#import "token.h"

@interface Environment : NSObject

@property(nonatomic, readwrite, retain) NSMutableDictionary *values;
@property(nonatomic, readwrite, retain) Environment *enclosing;

- (instancetype)init;
- (instancetype)initWithEnclosing:(Environment *)enclosing;
- (void)define:(NSString *)name value:(id)value;
- (id)get:(Token *)name;
- (void)assign:(Token *)name value:(id)value;

@end