//
//  Binding.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-10-28.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface Binding : NSObject

- (id)init:(NSObject *)value;

@property NSObject *value;

@end
