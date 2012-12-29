//
//  Lisp.h
//  GLisp
//
//  Created by Jan Gabrielsson on 2012-09-15.
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

#import <Foundation/Foundation.h>
#import "Atom.h"
#import "Binding.h"
#import "Keyword.h"
#import "Cons.h"
#import "Const.h"
#import "Lambda.h"
#import "Closure.h"
#import "Function.h"
#import "NSObject+Evaluate.h"
#import "SReader.h"
#import "SPrinter.h"
#import "Compiler.h"

extern NSString * const LispParseException;
extern NSString * const LispCompileException;
extern NSString * const LispRuntimeException;
extern NSString * const LispUserException;

@class Atom;
@class Lambda;

@interface Lisp : NSObject {
@private
    NSMutableDictionary *atoms;
    NSMutableArray *bindings;
}

@property (readonly) Atom *NIL;
@property (readonly) Atom *T;
@property (readonly) Atom *QUOTE;
@property (readonly) Atom *FUNCTION;
@property (readonly) Atom *SETQ;
@property (readonly) Atom *IF;
@property (readonly) Atom *SEND;
@property (readonly) Atom *LAMBDA;
@property (readonly) Atom *FN;
@property (readonly) Atom *NLAMBDA;
@property (readonly) Atom *POP;

@property (readonly) Atom *BACK_QUOTE;
@property (readonly) Atom *BACK_COMMA;
@property (readonly) Atom *BACK_COMMA_DOT;
@property (readonly) Atom *BACK_COMMA_AT;

@property (readonly) Atom *STD_IN;
@property (readonly) Atom *STD_OUT;

@property (readonly) NSInteger stackSize;

- (id)init;
- (NSObject *)intern:(NSObject *)symbol;
- (void)pushBinding:(Atom *)atom;
- (void)popBindings:(NSInteger)atoms;
- (void)loadFile:(NSString *)path;
- (BOOL)isTrue:(NSString *)symbol;

- (NSObject *)run:(NSString *)expr;

+ (Lisp *)lisp;

+ (void)throwException:(NSString *)type withReasonFormat:(NSString *)aReasonFormat, ...;

+ (NSObject *)arrayToList:(NSArray *)arr;
+ (NSArray *)listToArray:(NSObject *)list;
+ (NSArray *)listToArrayWithTail:(NSObject *)list andTail:(NSObject **) tail;

@end
