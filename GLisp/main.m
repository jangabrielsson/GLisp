//
//  main.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-07.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lisp.h"
#import "Compiler.h"
#import "SReader.h"

int main(int argc, const char * argv[])
{    
    NSFileHandle *input = [NSFileHandle fileHandleWithStandardInput];
    SReader *reader = [[SReader alloc] initWithFileHandle:input isConsole:YES];
    [Lisp lisp].STD_IN.value = reader;

    NSFileHandle *output = [NSFileHandle fileHandleWithStandardOutput];
    SPrinter *printer = [[SPrinter alloc] initWithFileHandle:output isConsole:YES];
    [Lisp lisp].STD_OUT.value = printer;
    [[Lisp lisp] loadFile:@"/Users/jan/Desktop/Development/GGLisp/GGLisp/init.lsp"];
/*
    while (1) {
        
        fprintf(stdout,"eval>");
        fflush(stdout);
        
        @try {
            
            NSObject *obj = [reader read];
            
            //NSLog(@"Read:%@",obj);
            
            NSObject *cObj = [Compiler compile:obj];
            
            NSObject *eObj = [cObj eval:nil];
            
            printf("%s\n",[[eObj toString:YES] UTF8String]);
        }
        @catch (NSException *exception) {
            NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        }
    }
*/    
    return 0;
}

