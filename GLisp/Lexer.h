//
//  Lexer.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-11-03.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void * YY_BUFFER_STATE;

@interface Lexer : NSObject {
    NSFileHandle *_file;
    BOOL _isConsole;
    BOOL _closed;
    YY_BUFFER_STATE _yybuffer;

}

- (id)initWithFileHandle:(NSFileHandle *)file isConsole:(BOOL)flag;
- (int)yylex:(char **)yytextPtr;
- (void)close;
- (void)flush;

@end
