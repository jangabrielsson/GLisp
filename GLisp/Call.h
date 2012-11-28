//
//  Call.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-23.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface Call : NSObject

@property NSArray *args;
@property NSArray *orgArgs;
@property NSObject *fun;

- (id)init:(NSObject *)fun andArgs:(NSArray *)args andOrgArgs:(NSArray *)orgArgs;
- (NSObject *)eval:(NSObject *)tail;
@end
