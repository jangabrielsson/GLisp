//
//  NSObject+Evaluate.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-17.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "NSObject+Evaluate.h"
#import "Lisp.h"


@implementation NSObject (Evaluate)

- (NSObject *)eval:(NSObject *)tail {
    return self;
}

- (NSObject *)first {
    [Lisp throwException:LispRuntimeException withReasonFormat:@"Not a Cons: %@",[self toString:YES]];
    return nil;
}

- (NSObject *)rest {
    [Lisp throwException:LispRuntimeException withReasonFormat:@"Not a Cons: %@",[self toString:YES]];
    return nil;
}

- (NSObject *)second {
    [Lisp throwException:LispRuntimeException withReasonFormat:@"Not a Cons: %@",[self toString:YES]];
    return nil;
}

- (NSObject *)third {
    [Lisp throwException:LispRuntimeException withReasonFormat:@"Not a Cons: %@",[self toString:YES]];
    return nil;
}

- (NSString *)name {
    [Lisp throwException:LispRuntimeException withReasonFormat:@"Not a Symbol: %@",[self toString:YES]];
    return nil;
}

- (id <Function>)funBinding {
    [Lisp throwException:LispRuntimeException withReasonFormat:@"Not a Fun: %@",[self toString:YES]];
    return nil;
}

- (BOOL)isMacro {
    return NO;
}

- (NSString *)toString:(BOOL)qf {
    return self.description;
}

@end

@implementation NSString (Evaluate)

- (NSString *)toString:(BOOL)qf {   // Hack!!!
    if (!qf) return self.description;
    return [NSString stringWithFormat:@"\"%@\"",self];
}

@end
