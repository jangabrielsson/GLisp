//
//  BuiltinPopList.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-10-08.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "LPopList.h"

@implementation LPopList

- (id)initWithAtom:(Atom *)atom {
  	if( (self=[super init]) ) {
        _atom = atom;
        //_atom.properties = [Lisp lisp].NIL;
 	}
	return self;
}

- (NSObject *)eval: (NSObject *)tail {
    NSObject *res = self.atom.value;
    if ([res isKindOfClass:[Cons class]]) {
        NSObject *pop = res.first;
        self.atom.value = res.rest;
        return pop;
    }
    return [Lisp lisp].NIL;
}

- (NSString *)toString:(BOOL)qf {
    return [[Cons list: [Lisp lisp].POP, self.atom, nil] toString:qf];
}

@end
