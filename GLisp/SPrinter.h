//
//  SPrinter.h
//  GGLisp
//
//  Created by Jan on 2012-11-25.
//  Copyright (c) 2012 Jan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@interface SPrinter : NSObject {
    
}

@property NSFileHandle *file;

- (id)initWithFileHandle:(NSFileHandle *)file isConsole:(BOOL)flag;
- (void)close;
- (void)flush;
- (void)print:(NSObject *)obj qf:(BOOL)flag;

@end
