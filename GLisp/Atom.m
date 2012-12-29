//
//  Atom.m
//  GLisp
//
//  Created by Jan Gabrielsson on 2012-09-15.
//
//  Copyright (c) 2012, Jan Gabrielsson
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.
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
