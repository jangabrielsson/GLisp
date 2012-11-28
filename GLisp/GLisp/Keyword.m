//
//  Keyword.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-24.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "Keyword.h"

@implementation Keyword

- (id)initWithName:(NSString *)name {
    if( (self=[super init])) {
        _name = name;
    }
    return self;
}

- (NSString *)description {
    return self.name;
}

@end
