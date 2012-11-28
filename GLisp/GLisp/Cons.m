//
//  Cons.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-15.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "Cons.h"

@implementation Cons

- (id)initWithCar:(NSObject *)car andCdr:(NSObject *)cdr {
    if( (self=[super init])) {
        _car = car;
        _cdr = cdr;
    }
    return self;
}

- (NSObject *)first {
    return self.car;
}

- (NSObject *)rest {
    return self.cdr;
}

- (NSObject *)second {
    return self.cdr.rest.first;
}

- (NSObject *)third {
    return self.cdr.rest.rest.first;
}

+ (NSObject *)list:(NSString *)firstArg, ...
{
    Cons *res = [[Cons alloc] initWithCar:firstArg andCdr:nil];
    Cons *tail = res;
    
    va_list args;
    va_start(args, firstArg);
    for (NSObject *arg = va_arg(args, NSObject *); arg != nil; arg = va_arg(args, NSObject *))
    {
        tail.cdr = [[Cons alloc] initWithCar:arg andCdr:nil];
        tail = (Cons *)tail.cdr;
    }
    tail.cdr = [Lisp lisp].NIL;
    va_end(args);
    return res;
}

- (NSString *)stringRest:(NSString *)pad quote:(BOOL)qf {
    NSString *rest;
    if ([self.cdr isKindOfClass:[Cons class]])
        rest = [((Cons *)self.cdr) stringRest:@" " quote:qf];
    else if (self.cdr == [Lisp lisp].NIL) rest = @"";
    else rest = [@" . " stringByAppendingString: [self.cdr toString:qf]];
    return [pad stringByAppendingString:[NSString stringWithFormat:@"%@%@",[self.car toString:qf],rest]];
}

- (NSString *)toString:(BOOL)qf {
    return [NSString stringWithFormat:@"(%@)",[self stringRest:@"" quote:qf]];
}

- (NSString *) description {
    return [self toString:NO];
}

@end
