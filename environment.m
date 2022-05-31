#import "environment.h"
#import "token.h"
#import "lox.h"

@implementation Environment

- (instancetype)init {
    if (self = [super init]) {
        self.values = [NSMutableDictionary dictionary];
        self.enclosing = nil;
    }
    return self;
}

- (instancetype)initWithEnclosing:(Environment *)enclosing {
    if (self = [super init]) {
        self.values = [NSMutableDictionary dictionary];
        self.enclosing = enclosing;
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

    [Lox runtimeError:name.line message:[NSString stringWithFormat:@"Undefined variable '%@'.", name.lexeme]];
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
    
    [Lox runtimeError:name.line message:[NSString stringWithFormat:@"Undefined variable '%@'.", name.lexeme]];
}

@end