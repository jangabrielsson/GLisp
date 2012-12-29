//
//  Call.m
//  GLisp
//
//  Created by Jan Gabrielsson on 2012-09-23.
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

#import "Call.h"

@implementation Call

- (id)init:(NSObject *)fun andArgs:(NSArray *)args andOrgArgs:(NSArray *)orgArgs {
  	if( (self=[super init]) ) {
        _fun = fun;
        _args = args;
        _orgArgs = orgArgs;
 	}
	return self;
}

- (id <Function>)funBinding {
    NSObject *res = [self eval:nil];
    if ([[res class] conformsToProtocol:@protocol(Function)])
        return (id <Function>)res;
    [Lisp throwException:LispRuntimeException withReasonFormat:@"Not a Fun: %@",[self toString:YES]];
    return nil;
}

// Macros get their arguments uncompiled
// Specials get their arguments unevaluated
// Regular functions get their arguments evaluated
- (NSObject *)eval:(NSObject *)tail {
    //NSLog(@"CALL:%@",[self toString:YES]);
    id <Function> f = self.fun.funBinding;
    if (f.isMacro) {
        return [[Compiler compile:[f apply:self.orgArgs andTail:tail]] eval:tail];
    } else if (f.isSpecial) {
        return [f apply:self.args andTail:tail];
    } else {
        NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:[self.args count]];

        for(NSObject *a in self.args)
            [params addObject:[a eval:nil]];
        return [f apply:params andTail:tail];
    }
}

- (NSString *)toString:(BOOL)qf {
    return [[[Cons alloc] initWithCar:self.fun andCdr:[Lisp arrayToList:self.args]] toString:qf];
}

@end
