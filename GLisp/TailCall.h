//
//  TailCall.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-10-14.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface TailCall : NSObject

@property Lambda *fun;
@property NSArray *args;

-(id)init:(Lambda *)fun andArgs:(NSArray *)args;

@end
