//
//  Closure.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-10-25.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@class Atom;
@class Lambda;

#import "Function.h"

@interface Closure : NSObject <Function>

@property Lambda *lambda;
@property NSMutableArray *freeBindings;

- (id)init:(Lambda *)lambda andFree:(NSArray *)free andTail:(NSObject *)tail;
- (NSObject *)apply:(NSArray *)args andTail:(NSObject *)tail;
- (id <Function>)funBinding;

@end
