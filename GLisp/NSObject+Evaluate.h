//
//  NSObject+Evaluate.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-17.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface NSObject (Evaluate)

- (NSObject *)eval:(NSObject *)tail;
- (NSObject *)first;
- (NSObject *)rest;
- (NSObject *)second;
- (NSObject *)third;
- (NSString *)name;
- (BOOL)isMacro;
- (id <Function>)funBinding;
- (NSString *)toString:(BOOL)qf;

@property (readonly) NSObject *first;
@property (readonly) NSObject *rest;
@property (readonly) NSObject *second;
@property (readonly) NSObject *third;
@property (readonly) NSString *name;
@property (readonly) id <Function> funBinding;

@end


