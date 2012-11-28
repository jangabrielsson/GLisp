//
//  Lisp.h
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-15.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
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

+ (Lisp *)lisp;

+ (void)throwException:(NSString *)type withReasonFormat:(NSString *)aReasonFormat, ...;

+ (NSObject *)arrayToList:(NSArray *)arr;
+ (NSArray *)listToArray:(NSObject *)list;
+ (NSArray *)listToArrayWithTail:(NSObject *)list andTail:(NSObject **) tail;

@end
