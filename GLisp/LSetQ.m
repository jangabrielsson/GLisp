//
//  FunSetQ.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-20.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "LSetQ.h"

@implementation LSetQ

- (id)initWithArgs:(NSArray *)args {
  	if( (self=[super init]) ) {
        _args = args;
 	}
	return self;
}

- (NSObject *)eval: (NSObject *)tail {
    NSObject *res = [Lisp lisp].NIL;
    for(int i = 0; i < self.args.count; i+=2) {
        res = [[self.args objectAtIndex:i+1] eval:nil];
        ((Atom *)[self.args objectAtIndex:i]).value = res;
    }
    return res;
}

-(NSString *)toString:(BOOL)qf {
    return [[Cons list:[Lisp lisp].SETQ, [self.args objectAtIndex:0], [self.args objectAtIndex:1], nil] toString:qf];
}

@end
