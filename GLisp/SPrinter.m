//
//  SPrinter.m
//  GGLisp
//
//  Created by Jan on 2012-11-25.
//  Copyright (c) 2012 Jan. All rights reserved.
//

#import "SPrinter.h"

@implementation SPrinter

- (id)initWithFileHandle:(NSFileHandle *)file isConsole:(BOOL)flag {
 	if( (self=[super init]) ) {
        _file = file;
 	}
	return self;
}

- (void) close {
    
}

- (void) flush {
    [self.file synchronizeFile];
}

- (void) print:(NSObject *)obj qf:(BOOL)flag {
    NSString *str = [obj toString:flag];
    NSData* data=[str dataUsingEncoding: [NSString defaultCStringEncoding] ];
    [self.file writeData:data];
}

@end
