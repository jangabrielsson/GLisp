//
//  Function.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-25.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Function <NSObject>

-(NSObject *)apply:(NSArray *)args andTail:(NSObject *)tail;
-(BOOL)isSpecial;                   // Specials are responsible for evaluating their own args (see Call.m)
-(BOOL)isMacro;                     // Macros get their args "uncompiled" and are treated special by the compiler (see Call.m)

@end
