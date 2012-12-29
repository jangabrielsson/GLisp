//
//  LexInputStream.m
//  GLisp
//
//  Wrapper for lex to read from a NSFileHandle...
//
//  Created by Janb Gabrielsson on 2012-11-03.
//
//  Copyright (c) 2012, Jan Gabrielsson
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.
//

#import "LexInputStream.h"

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
static LexInputStream *gLexStream;

int readInputForLexer( char *buffer, int *numBytesRead, int maxBytesToRead ) {
    return [gLexStream readInputForLexer:buffer numBytes:numBytesRead maxBytes:maxBytesToRead];
}

@implementation LexInputStream

- (id)initWithFileHandle:(NSFileHandle *)file isConsole:(BOOL)flag
{
  	if( (self=[super init]) ) {
        _file = file;
        _data = nil;
        _isConsole = flag;
        _closed = NO;
        _yybuffer = yy_create_buffer(0, 8192);
 	}
	return self;
}

- (id)initWithData:(NSData *)data
{
  	if( (self=[super init]) ) {
        _data = data;
        _file = nil;
        _isConsole = NO;
        _closed = NO;
        _yybuffer = yy_create_buffer(0, 8192);
 	}
	return self;
}

- (int)yylex:(char **)yytextPtr {
    if (_closed)
        return 0;
    gLexStream = self;
    yy_switch_to_buffer (_yybuffer);
    int y = yylex();
    *yytextPtr = lexBuffer;
    return y;
}

- (int) readInputForLexer:(char *)buffer numBytes:(int *)numBytesRead maxBytes:(int)maxBytesToRead {
    if (self.isConsole)
        maxBytesToRead = 1;
    NSData *rd = (self.file != nil) ? [self.file readDataOfLength:maxBytesToRead] : self.data;
    if (maxBytesToRead > [rd length])
        maxBytesToRead = (int)[rd length];
    *numBytesRead = maxBytesToRead;
    [rd getBytes:buffer length:maxBytesToRead];
    return 0;
}

- (void)close {
    if (!_closed) {
        yy_delete_buffer(_yybuffer);
        _closed = YES;
    }
}

- (void)flush {
    if (!_closed)
        yy_flush_buffer(_yybuffer);
}

@end
