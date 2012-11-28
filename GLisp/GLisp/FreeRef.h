//
//  FreeRef.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-10-25.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface FreeRef : NSObject

@property Atom* atom;
@property Binding *binding;

- (id)init:(Atom *)atom andBinding:(Binding *)binding;

@end
