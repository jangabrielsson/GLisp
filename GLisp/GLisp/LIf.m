//
//  FunIf.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-20.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "LIf.h"

@implementation LIf

- (id)initWithTest:(NSObject *)aTest andThen:(NSObject *)aThen andElse:(NSObject *)aElse {
  	if( (self=[super init]) ) {
        testArg = aTest;
        thenArg = aThen;
        elseArg = aElse;
 	}
	return self;
}

- (NSObject *)eval: (NSObject *)tail {
    if ([testArg eval:nil] != [Lisp lisp].NIL)
        return [thenArg eval:tail];
    else return [elseArg eval:tail];
}

-(NSString *)toString:(BOOL)qf {
    return [[Cons list: [Lisp lisp].IF, testArg, thenArg, elseArg, nil] toString:qf];
}

@end
