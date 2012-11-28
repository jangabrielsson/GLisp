//
//  Cons.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-15.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

#define makeCons(Car,Cdr) ([[Cons alloc] initWithCar:Car andCdr:Cdr])

@interface Cons : NSObject

@property NSObject *car;
@property NSObject *cdr;

- (id)initWithCar:(NSObject *)car andCdr:(NSObject *)cdr;

+ (NSObject *)list:(NSObject *)firstArg, ...
NS_REQUIRES_NIL_TERMINATION;

@end
