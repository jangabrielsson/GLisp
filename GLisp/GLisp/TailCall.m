//
//  TailCall.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-10-14.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "TailCall.h"

@implementation TailCall

-(id)init:(Lambda *)fun andArgs:(NSArray *)args {
  	if( (self=[super init]) ) {
        _fun = fun;
        _args = args;
    }
    return self;
}

@end
