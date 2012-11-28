//
//  Keyword.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-24.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface Keyword : NSObject

@property NSString *name;

-(id) initWithName:(NSString *)name;

@end
