//
//  Closure.m
//  GLisp
//
//  Created by Jan on 2012-10-25.
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

#import "Closure.h"

@implementation Closure

- (id)init:(Lambda *)lambda andFree:(NSArray *)free andTail:(NSObject *)tail {
  	if( (self=[super init]) ) {
        _lambda = lambda;
        _freeBindings = [[NSMutableArray alloc] init];
        for(Atom *a in free)
            [_freeBindings addObject:[[Cons alloc] initWithCar:a andCdr: a.binding ]];
 	}
    if ([[Lisp lisp] isTrue:@"*trace-closure*"])
        NSLog(@"Closure:%@",[self toString:YES]);
	return self;
    
}

- (BOOL)isSpecial {
    return self.lambda.isSpecial;
}

- (BOOL)isMacro {
    return self.lambda.isMacro;
}

- (NSObject *)apply:(NSArray *)args andTail:(NSObject *)tail {
    for(Cons *b in self.freeBindings) {
        [[Lisp lisp] pushBinding:(Atom *)b.car];
        ((Atom *)b.car).binding = (Binding *)b.cdr;
    }
    @try {
        return [self.lambda apply:args andTail:tail];
    } @finally {
        [[Lisp lisp] popBindings:[self.freeBindings count]];
    }
}

- (id <Function>)funBinding {
    return self;    
}

- (NSString *)toString:(BOOL)qf {
    return [NSString stringWithFormat:@"%@%@",[self freeToString],[self.lambda toString:qf]];
}

- (NSString *)freeToString {
    NSString *res = @"";
    for(Cons *b in self.freeBindings) {
        res = [res stringByAppendingFormat:@"[%@=%@]",b.car,b.cdr];
    }
    return res;
}

@end
