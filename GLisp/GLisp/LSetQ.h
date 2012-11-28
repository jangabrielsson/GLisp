//
//  FunSetQ.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-20.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface LSetQ : NSObject

@property NSArray *args;

- (id)initWithArgs:(NSArray *)args;

@end
