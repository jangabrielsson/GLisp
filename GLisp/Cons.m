//
//  Cons.m
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
