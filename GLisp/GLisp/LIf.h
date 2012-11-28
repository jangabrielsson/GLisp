//
//  FunIf.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-20.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface LIf : NSObject {
@private
    NSObject *testArg;
    NSObject *thenArg;
    NSObject *elseArg;
}

- (id)initWithTest:(NSObject *)aTest andThen:(NSObject *)aThen andElse:(NSObject *)aElse;
- (NSObject *)eval: (NSObject *)tail;

@end
