//
//  SReader
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-11-01.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lisp.h"

@class Lexer;

@interface SReader : NSObject {    
    NSObject *lastSymbol;
    Lexer *lexer;
    Atom *readMacroTable;
}

- (id)initWithFileHandle:(NSFileHandle *)file isConsole:(BOOL)flag;
- (NSObject *)read;

-(void)close;

@end
