//
//  Atom.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-15.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"
#import "Function.h"

@class Binding;

@interface Atom : NSObject {
@private
    id <Function> _funBinding;
}

@property NSString *name;
@property NSObject *properties;
@property Binding *binding;
@property NSObject *value;
@property id <Function> funBinding;

- (id)initWithName:(NSString *)name;
- (BOOL)unbound;

@end
