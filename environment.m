#import "environment.h"
#import "token.h"
#import "lox.h"

@implementation Environment

@synthesize values;
@synthesize enclosing;

- (instancetype)initWithLox:(Lox *)param_lox andEnclosing:(Environment *)param_enclosing {
    if (self = [super init]) {
        self.values = [NSMutableDictionary dictionary];
        self.enclosing = param_enclosing;
        lox = param_lox;
    }
    return self;
}

- (void)define:(NSString *)name value:(id)value {
    [self.values setObject:value  forKey:name];
}

- (id)get:(Token *)name {
    id value = [self.values objectForKey:name.lexeme];
    if (value != nil) {
        return value;
    }
    if (self.enclosing != nil) {
        return [self.enclosing get:name];
    }

    [lox runtimeError:(NSNumber *)name.line message:[NSString stringWithFormat:@"Undefined variable '%@'.", name.lexeme]];
    return nil;
}

- (void)assign:(Token *)name value:(id)value {
    if ([self.values objectForKey:name.lexeme] != nil) {
        [self.values setObject:value forKey:name.lexeme];
        return;
    }

    if (self.enclosing != nil) {
        [self.enclosing assign:name value:value];
        return;
    }
    
    [lox runtimeError:(NSNumber *)name.line message:[NSString stringWithFormat:@"Undefined variable '%@'.", name.lexeme]];
}

@end