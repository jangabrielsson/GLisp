//
//  BuiltinPopList.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-10-08.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface LPopList : NSObject

@property Atom *atom;

- (id)initWithAtom:(Atom *)atom;
- (NSObject *)eval:(NSObject *)tail;

@end
