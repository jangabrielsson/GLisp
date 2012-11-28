//
//  Binding.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-10-28.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "Binding.h"

@implementation Binding

- (id)init:(NSObject *)value
{
  	if( (self=[super init]) ) {
        _value = value;
    }
    return self;
}

- (NSString *)description {
    return self.value.description;
}

@end
