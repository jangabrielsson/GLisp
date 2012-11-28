//
//  Lambda.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-25.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@class Atom;

#import "Function.h"

@interface Lambda : NSObject <Function>
{
    NSArray *_parameters;    // Parameters
    Atom *_rest;         // ...and eventual rest parameter  (lambda (a b . c) ... )
    NSArray *_body;          // Body is implicit progn
    NSArray *_free;          // Free variables in the body. Used when creating closure
}

@property BOOL isSpecial;
@property BOOL isMacro;

-(id)init:(NSArray *)parameters andFree:(NSArray *)free andBody:(NSObject *)body andRest:(Atom *)rest;
-(NSObject *)apply:(NSArray *)args andTail:(NSObject *)tail;
-(id <Function>)funBinding;
@end
