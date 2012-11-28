//
//  SendMessage.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-24.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface SendMessage : NSObject {
    NSMutableArray *theArgs;
    NSMethodSignature *signature;
    SEL selector;
}

@property NSArray *args;
@property NSObject *obj;

-(id)init:(NSObject *)obj andArgs:(NSArray *)args;
@end
