//
//  Closure.m
//  GGLisp
//
//  Created by Jan on 2012-10-25.
//  Copyright (c) 2012 Jan. All rights reserved.
//

#import "Closure.h"
#import "FreeRef.h"

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
