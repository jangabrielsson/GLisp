//
//  Const.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-17.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//
//  (quote ...) -> [[Const alloc] init:...]

#import "Const.h"

@implementation Const


-(id)init:(NSObject *)obj {
  	if( (self=[super init]) ) {
        _obj = obj;
 	}
	return self;
   
}

-(NSObject *)eval:(NSObject *)tail {
    return _obj;
}

-(NSString *)toString:(BOOL)qf {
    return [@"'" stringByAppendingString:[_obj toString:qf]];
}
@end
