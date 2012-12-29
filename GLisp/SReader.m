//
//  SReader
//  GLisp
//
//  Created by Jan Gabrielsson on 2012-11-01.
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

#include <stdio.h>
#include <string.h>

#import "SReader.h"
#import "LexInputStream.h"
#import "y.tab.h"

static NSObject *aDot;
static NSObject *aLPar;
static NSObject *aRPar;
static NSObject *aLBra;
static NSObject *aRBra;
static NSObject *aFun;
static NSObject *aQuote;
static NSObject *aBackQuote;
static NSObject *aComma;
static NSObject *aComDot;
static NSObject *aComAt;
static NSObject *aErr;

@implementation SReader

+ (void) initialize {
    aDot = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:."]];
    aLPar = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:("]];
    aRPar = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:)"]];
    aLBra = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:["]];
    aRBra = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:]"]];
    aFun = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:#"]];
    aQuote = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:'"]];
    aBackQuote = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:`"]];
    aComDot = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:,."]];
    aComma = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:,"]];
    aComAt = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok,@"]];
    aErr = [[Lisp lisp] intern:[[Atom alloc] initWithName:@"*tok:<<err>>"]];
    
    ((Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*aLBra*"]]).value = aLBra;
    ((Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*aRBra*"]]).value = aRBra;
    ((Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*aDot*"]]).value = aDot;
    ((Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*aFun*"]]).value = aFun;
    ((Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*aBackQuote*"]]).value = aBackQuote;
    ((Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*aComDot*"]]).value = aComDot;
    ((Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*aComma*"]]).value = aComma;
    ((Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*aComAt*"]]).value = aComAt;
}


- (id)initWithFileHandle:(NSFileHandle *)file isConsole:(BOOL)flag {
 	if( (self=[super init]) ) {
        lexer = [[LexInputStream alloc] initWithFileHandle:file isConsole:flag];
        readMacroTable = (Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*read-macro-table*"]];
 	}
	return self;
}

- (id)initWithData:(NSData*)data {
 	if( (self=[super init]) ) {
        lexer = [[LexInputStream alloc] initWithData:data];
        readMacroTable = (Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:@"*read-macro-table*"]];
 	}
	return self;
}

- (NSObject *)readSymbol {
    char *yytext;
    int y = [lexer yylex:&yytext];
    switch(y) {
        case tDOT: return aDot;
        case tLBRACE: return aLPar;
        case tRBRACE: return aRPar;
        case tLBRACK: return aLBra;
        case tRBRACK: return aRBra;
        case tINTEGER: return [NSDecimalNumber numberWithLong:[[NSString stringWithUTF8String:yytext] longLongValue]];
        case tFLOAT: return [NSDecimalNumber numberWithDouble:[[NSString stringWithUTF8String:yytext] doubleValue]];
        case tHEX_INTEGER:
        case tSTRLIT: return [NSString stringWithUTF8String:yytext];
        case tFUNCTION: return aFun;
        case tCHRLIT:

        case tATOM:
        case tGREATER:
        case tLESS:
        case tEQUAL:
        case tADD:
        case tSUB:
        case tMUL:
        case tDIV:
            return [[Lisp lisp] intern:[[Atom alloc] initWithName:[ NSString stringWithUTF8String:yytext ]]];
        case tBACK_QUOTE: return aBackQuote;
        case tQUOTE: return aQuote;
        case tCOM_DOT: return aComDot;
        case tCOM_AT: return aComAt;
        case tCOMMA: return aComma;
        case tKEYWORD: return [[Lisp lisp] intern:[[Keyword alloc] initWithName:[ NSString stringWithUTF8String:yytext ]]];
        case tMESSAGE:return [[Lisp lisp] intern:[[Keyword alloc] initWithName:[ NSString stringWithUTF8String:yytext ]]];
        case tERROR: return aErr;
    }
    return nil;
}

- (NSObject *)nextToken {
    if (lastSymbol != nil) {
        NSObject *s = lastSymbol;
        lastSymbol = nil;
        return s;
    } else return [self readSymbol];
}

- (void)pushBackToken:(NSObject *)symbol {
    lastSymbol = symbol;
}

- (NSObject *)read {
    NSObject *sym = [self nextToken];
    
    if (![readMacroTable unbound]) {
        NSMutableDictionary *dict = (NSMutableDictionary *)readMacroTable.value;
        id <Function> fun = [dict objectForKey: sym.description];
        if (fun != nil) {
            NSArray *args = [NSArray arrayWithObject:self];
            return [fun apply:args andTail:nil];
        }
    }

    if (sym == aQuote)
        return [Cons list:[Lisp lisp].QUOTE, [self read], nil];

    if (sym == aLPar) {
        sym = [self nextToken];
        if (sym == aRPar)
            return [Lisp lisp].NIL;
        else {
            [self pushBackToken:sym];
            Cons *l = (Cons *)[Cons list: [self read], nil];
            Cons *t = l;
            while (YES) {
                sym = [self nextToken];
                if (sym == aRPar) return l;
                if (sym == aDot) {
                    t.cdr = [self read];
                    if ([self nextToken]  != aRPar)
                        [self throwReaderException:@"Missing ')'"];
                    return l;
                }
                if (sym == nil)
                    [self throwReaderException:@"Malformed list"];
                
                [self pushBackToken:sym];
                t.cdr = makeCons([self read], [Lisp lisp].NIL);
                t = (Cons *)t.cdr;
            }
        }
    }
    
    if (sym == aErr)
        [self throwReaderException:@"Read error"];

    return sym;
}

-(void)close {
    [lexer close];
}

- (void)throwReaderException:(NSString *)aReason {
    [Lisp throwException:LispParseException withReasonFormat:aReason];
}

@end
