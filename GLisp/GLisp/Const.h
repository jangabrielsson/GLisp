//
//  Const.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-17.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface Const : NSObject {
@private
    NSObject *_obj;
}

-(id)init:(NSObject *)obj;

@end
