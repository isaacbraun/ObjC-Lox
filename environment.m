#import "environment.h"
#import "token.h"
#import "lox.h"

@implementation Environment

- (instancetype)init {
    if (self = [super init]) {
        _values = [NSMutableDictionary dictionary];
        _enclosing = nil;
    }
    return self;
}

- (instancetype)initWithEnclosing:(Environment *)enclosing {
    if (self = [super init]) {
        _values = [NSMutableDictionary dictionary];
        _enclosing = enclosing;
    }
    return self;
}

- (void)define:(NSString *)name value:(id)value {
    [_values setObject:value  forKey:name];
}

- (id)get:(Token *)name {
    id value = [_values objectForKey:name.lexeme];
    if (value != nil) {
        return value;
    }
    if (_enclosing != nil) {
        return [_enclosing get:name];
    }

    [Lox runtimeError:name.line message:[NSString stringWithFormat:@"Undefined variable '%@'.", name.lexeme]];
    return nil;
}

- (void)assign:(Token *)name value:(id)value {
    if ([_values objectForKey:name.lexeme] != nil) {
        [_values setObject:value forKey:name.lexeme];
        return;
    }

    if (_enclosing != nil) {
        [_enclosing assign:name value:value];
        return;
    }
    
    [Lox runtimeError:name.line message:[NSString stringWithFormat:@"Undefined variable '%@'.", name.lexeme]];
}

@end