//
//  Compiler.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-17.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface Compiler : NSObject

+ (NSObject *)compile:(NSObject *)aObj;
+ (NSObject *)compile:(NSObject *)aObj andEnv:(NSMutableArray *)env;
+ (NSArray *)compileArgs:(NSArray *)args andEnv:(NSMutableArray *)env;

@end
