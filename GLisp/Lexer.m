//
//  Lexer.m
//  GGLisp
//
//  Wrapper for lex to read from a NSFileHandle...
//
//  Created by Janb Gabrielsson on 2012-11-03.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "Lexer.h"

extern YY_BUFFER_STATE yy_create_buffer(FILE *file, int size);
extern void yy_delete_buffer(YY_BUFFER_STATE buffer);
extern void yypush_buffer_state(YY_BUFFER_STATE buffer);
extern void yypop_buffer_state();
extern void yy_flush_buffer(YY_BUFFER_STATE buffer);
extern void yy_switch_to_buffer(YY_BUFFER_STATE new_buffer);

extern void yyerror(char* s);
extern int yylex();
extern void yylex_init();
extern char *yytext;
extern char lexBuffer[];

extern int readInputForLexer(char* buffer,int *numBytesRead,int maxBytesToRead);

static NSFileHandle *gNSFileHandle;
static BOOL gIsConsole;

int readInputForLexer( char *buffer, int *numBytesRead, int maxBytesToRead ) {
    if (gIsConsole)
        maxBytesToRead = 1;
    NSData *data = [gNSFileHandle readDataOfLength:maxBytesToRead];
    if (maxBytesToRead > [data length])
        maxBytesToRead = (int)[data length];
    *numBytesRead = maxBytesToRead;
    [data getBytes:buffer length:maxBytesToRead];
    return 0;
}

@implementation Lexer

- (id)initWithFileHandle:(NSFileHandle *)file isConsole:(BOOL)flag {
 	if( (self=[super init]) ) {
        _file = file;
        _isConsole = flag;
        _closed = NO;
        _yybuffer = yy_create_buffer(0, 8192);
 	}
	return self;
}

- (int)yylex:(char **)yytextPtr {
    if (_closed)
        return 0;
    gNSFileHandle = _file;
    gIsConsole = _isConsole;
    yy_switch_to_buffer (_yybuffer);
    int y = yylex();
    *yytextPtr = lexBuffer;
    return y;
}

- (void)close {
    if (!_closed) {
        yy_delete_buffer(_yybuffer);
        _closed = YES;
    }
}

- (void)flush {
    if (_closed)
        yy_flush_buffer(_yybuffer);
}

@end
