//
//  Atom.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-15.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "Atom.h"

#import "Function.h"

@implementation Atom

- (id)initWithName:(NSString *)name {
    if( (self=[super init])) {
        _name = name;
        _binding = [[Binding alloc] init:[NSNull null]];
        _funBinding = nil;
        _properties = ([name isEqualToString:@"nil"]) ? self : [Lisp lisp].NIL;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (BOOL)isEqual:(id)anObject {
    return [anObject isKindOfClass:[Atom class]] && [((Atom *)anObject).name isEqual:_name];
}

- (NSUInteger)hash {
    return [_name hash];
}

- (NSObject *)car {
    [Lisp throwException:LispRuntimeException withReasonFormat:@"Not a cons:%@",[self toString:YES]];
    return [Lisp lisp].NIL;
}

- (NSObject *)value {
    if (self.binding.value == [NSNull null])
        [Lisp throwException:LispRuntimeException withReasonFormat:@"Unbound symbol:%@",[self toString:YES]];
    return self.binding.value;
}

- (void)setValue:(NSObject *)avalueBinding {
    self.binding.value = avalueBinding;
}

- (id <Function>)funBinding {
    if (_funBinding != nil)
        return _funBinding;
    else if ([[self.binding.value class] conformsToProtocol:@protocol(Function)])
        return (id <Function>)self.binding.value;
    else [Lisp throwException:LispRuntimeException withReasonFormat:@"Not a fun:%@",[self toString:YES]];
    return nil;
}

- (void)setFunBinding:(id <Function>)fun {
    _funBinding = fun;
}

- (BOOL)isMacro {
    return _funBinding != nil && _funBinding.isMacro;
}

-(BOOL)isSpecial {
    return _funBinding != nil && _funBinding.isSpecial;
}

- (NSString *)description {
    return self.name;
}

- (BOOL)unbound {
    return _binding.value == [NSNull null];
}

- (NSObject *)eval:(NSObject *)tail {
    if (self.binding.value == [NSNull null])
        [Lisp throwException:LispRuntimeException withReasonFormat:@"Unbound value:%@", self.name];
    return self.binding.value;
}

@end
