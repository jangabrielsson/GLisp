//
//  Call.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-23.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
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
