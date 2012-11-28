//
//  FreeRef.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-10-25.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "FreeRef.h"

@implementation FreeRef

- (id)init:(Atom *)atom andBinding:(Binding *)binding
{
  	if( (self=[super init]) ) {
        _atom = atom;
        _binding = binding;
    }
    return self;
}

@end
