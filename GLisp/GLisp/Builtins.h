//
//  Builtins.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-23.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface Builtins : NSObject <Function> {
@private
    NSInteger type;
}

@property BOOL isSpecial;
@property BOOL isMacro;

+ (void)setup;

- (id)init:(NSInteger)aType;

- (NSObject *)eval: (NSObject *)tail;
- (NSObject *)apply:(NSArray *)args andTail:(NSObject *)tail;

@end

