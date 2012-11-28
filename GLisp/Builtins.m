//
//  Builtins.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-23.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "Builtins.h"
#import "SReader.h"

enum {
	CAR = 100,
	CDR,
    CONS,
	ADD,
	SUB,
	MUL,
	DIV,
	LESSP,
    AND,
    OR,
	RPLACA,
	RPLACD,
	FUNCTION,
	FUNSET,
	APPLY,
	FUNCALL,
	EVAL,
	EQ,
	ATOM,
	NUMBERP,
	CONSP,
    STRINGP,
    KEYWORDP,
    CLASS,
    SETPROP,
    GETPROP,
	THROW,
	ERROR,
	STRFORMAT,
	GENSYM,
	WHILE,
    CATCH,
    TEST
};

NSString * const bNames[] =
{ @"car", @"cdr", @"cons", @"add", @"sub", @"mul", @"div", @"lessp", @"%and", @"%or", @"rplaca", @"rplacd", @"function", @"funset", @"apply", @"funcall", @"eval", @"eq", @"atom", @"numberp", @"consp", @"stringp", @"keywordp", @"class", @"*setprop*", @"*getprop*", @"throw", @"*error*", @"strformat", @"gensym", @"%while", @"%catch", @"test", nil};

NSUInteger gGensyms = 42;

@implementation Builtins

+ (void)setup {
    for(int i = 0; bNames[i] != nil; i++) {
        NSString *name = bNames[i];
        Builtins *b = [[Builtins alloc] init:CAR+i];
        BOOL special = [name hasPrefix:@"%"];
        if (special) {
            name = [name substringFromIndex:1];
            b.isSpecial = YES;
        }
        Atom *a = (Atom *)[[Lisp lisp] intern:[[Atom alloc] initWithName:name]];
        a.funBinding = b;
        [[Lisp lisp] intern:a];
        //NSLog(@"Defining:%@=%@",a,b);
    }
}

- (id)init:(NSInteger)aType {
    if( (self=[super init])) {
        type = aType;
        _isSpecial = NO;
        _isMacro = NO;
    }
    return self;
}

- (NSObject *)eval: (NSObject *)tail {
    return self;
}

- (NSString *)builtinName {
    return (self.isSpecial && self.isMacro) ? [bNames[type-CAR] substringFromIndex:1] : bNames[type-CAR];
}

#define CHECKARGS(N) if (n != N) [Lisp throwException:LispRuntimeException withReasonFormat:@"Wrong number of arguments to: %@",self];

#define CHECKATLEASTARGS(N) if (n < N) [Lisp throwException:LispRuntimeException withReasonFormat:@"Too few arguments to: %@",self];

#define ERROR(MSG,A)[Lisp throwException:LispRuntimeException withReasonFormat:MSG,A];

- (NSObject *)apply:(NSArray *)args andTail:(NSObject *)tail {
    NSInteger n = [args count];
    switch (type) {
        case CAR:
            CHECKARGS(1);
            return ((NSObject *)[args objectAtIndex:0]).first;
            break;
        case CDR:
            CHECKARGS(1);
            return ((NSObject *)[args objectAtIndex:0]).rest;
            break;
        case CONS:
            CHECKARGS(2);
            return [[Cons alloc] initWithCar:(NSObject *)[args objectAtIndex:0] andCdr:(NSObject *)[args objectAtIndex:1]];
            break;
        case ADD:
            CHECKARGS(2);
        {
            NSDecimalNumber *op1 = [args objectAtIndex:0];
            NSDecimalNumber *op2 = [args objectAtIndex:1];
            return [op1 decimalNumberByAdding:op2];
        }
            break;
        case SUB:
            CHECKARGS(2);
        {
            NSDecimalNumber *op1 = [args objectAtIndex:0];
            NSDecimalNumber *op2 = [args objectAtIndex:1];
            return [op1 decimalNumberBySubtracting:op2];
        }
            break;
        case MUL:
            CHECKARGS(2);
        {
            NSDecimalNumber *op1 = [args objectAtIndex:0];
            NSDecimalNumber *op2 = [args objectAtIndex:1];
            return [op1 decimalNumberByMultiplyingBy:op2];
        }
            break;
        case DIV:
            CHECKARGS(2);
        {
            NSDecimalNumber *op1 = [args objectAtIndex:0];
            NSDecimalNumber *op2 = [args objectAtIndex:1];
            return [op1 decimalNumberByDividingBy:op2];
        }
            break;
        case LESSP:
            CHECKARGS(2);
        {
            NSDecimalNumber *op1 = [args objectAtIndex:0];
            NSDecimalNumber *op2 = [args objectAtIndex:1];
            return ([op1 isLessThan:op2]) ? [Lisp lisp].T : [Lisp lisp].NIL;
        }
            break;
        case AND:
            CHECKATLEASTARGS(2);
        {
            NSObject *res;
            NSObject *n = [Lisp lisp].NIL;
            for(NSObject *a in args) {
                res = [a eval:tail];
                if (res == n) break;
            }
            return res;
        }
        case OR:
            CHECKATLEASTARGS(2);
        {
            NSObject *res;
            NSObject *n = [Lisp lisp].NIL;
            for(NSObject *a in args) {
                res = [a eval:tail];
                if (res != n) return res;
            }
            return n;
        }
            break;
        case RPLACA:
            CHECKARGS(2);
        {
            Cons *c = [args objectAtIndex:0];
            c.car = [args objectAtIndex:1];
            return c;
        }
            break;
        case RPLACD:
            CHECKARGS(2);
        {
            Cons *c = [args objectAtIndex:0];
            c.cdr = [args objectAtIndex:1];
            return c;
        }
            break;
        case FUNCTION:
            CHECKARGS(1);
        {
            NSObject *arg = [args objectAtIndex:0];
            if ([arg isKindOfClass:[Atom class]]) {
                Atom *atom = (Atom *)arg;
                return (atom.funBinding == nil) ? [Lisp lisp].NIL : atom.funBinding;
            } else if ([arg isKindOfClass:[Cons class]]) {
                arg = [Compiler compile:arg];
                if ([arg isKindOfClass:[Lambda class]]) {
                    return [arg eval:nil];
                } else return [Lisp lisp].NIL;
            }
        }
            break;
        case FUNSET:
            CHECKARGS(2);
        {
            Atom *atom = (Atom *)[args objectAtIndex:0];
            atom.funBinding = [args objectAtIndex:1];
            return atom;
        }
            break;
        case APPLY:       // (apply (function 'append) (list '(1 2 3) '(4 5 6)))
            CHECKARGS(2);
        {
            id <Function> f = [args objectAtIndex:0];
            NSArray *arr = [Lisp listToArray:[args objectAtIndex:1]];
            NSObject *res;
            if (f.isSpecial) {
                ERROR(@"Can't make funcall with special: %@",[((NSObject *)f) toString:YES]);
            } else {
                res = [f apply:arr andTail:nil];
            }
            return (f.isMacro) ? [[Compiler compile:res] eval:nil] : res;
        }
            break;
        case FUNCALL:
            break;
        case EVAL:
            CHECKARGS(1);
            return [[Compiler compile:[args objectAtIndex:0]] eval:nil];
            break;
        case EQ:
            CHECKARGS(2);
            return ([[args objectAtIndex:0] isEqual:[args objectAtIndex:1]]) ? [Lisp lisp].T : [Lisp lisp].NIL;
            break;
        case ATOM:
            CHECKARGS(1);
            return ([[args objectAtIndex:0]isKindOfClass:[Atom class]]
                    || [[args objectAtIndex:0]isKindOfClass:[NSNumber class]]) ? [Lisp lisp].T : [Lisp lisp].NIL;
            break;
        case NUMBERP:
            CHECKARGS(1);
            return [[args objectAtIndex:0]isKindOfClass:[NSNumber class]] ? [Lisp lisp].T : [Lisp lisp].NIL;
            break;
        case CONSP:
            CHECKARGS(1);
            return [[args objectAtIndex:0]isKindOfClass:[Cons class]] ? [Lisp lisp].T : [Lisp lisp].NIL;
            break;
        case STRINGP:
            CHECKARGS(1);
            return [[args objectAtIndex:0]isKindOfClass:[NSString class]] ? [Lisp lisp].T : [Lisp lisp].NIL;
            break;
        case KEYWORDP:
            CHECKARGS(1);
            return [[args objectAtIndex:0]isKindOfClass:[Keyword class]] ? [Lisp lisp].T : [Lisp lisp].NIL;
            break;
        case CLASS:
            CHECKARGS(1);
            return (NSObject *)NSClassFromString([args objectAtIndex:0]);
            break;
        case SETPROP:
            CHECKARGS(2);
        {   NSObject *res = [args objectAtIndex:1];
            [(Atom *)[args objectAtIndex:0] setProperties:res];
            return res;
        }
            break;
        case GETPROP:
            CHECKARGS(1);
            return [(Atom *)[args objectAtIndex:0] properties];
            break;
        case THROW:
            CHECKARGS(2); // Tag and arg
        {
            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[args objectAtIndex:1] , [args objectAtIndex:0], nil];
            NSException *e = [NSException
                              exceptionWithName:LispUserException
                              reason: @"User throw"
                              userInfo:d];
            @throw e;
        }
            break;
        case ERROR:
            CHECKARGS(1);
            [Lisp throwException:LispRuntimeException withReasonFormat:@"%@",[args objectAtIndex:0]];
            break;
        case STRFORMAT:
            CHECKATLEASTARGS(2);
        {
            NSString *frmt = [[args objectAtIndex:0] stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
            NSArray *frmts = [frmt componentsSeparatedByString:@"%@"];
            NSString *res = @"";
            for(int i = 0; i < [frmts count]; i++) {
                res = [res stringByAppendingString:[[frmts objectAtIndex:i] description]];
                if ([args count] > i+1)
                    res = [res stringByAppendingString:[[args objectAtIndex:i+1] description]];
            }
            return res;
        }
            break;
        case GENSYM:
            CHECKARGS(0);
        {
            Atom *atom = [[Atom alloc] initWithName:@"<GENSYM:>"];
            NSString *name = [NSString stringWithFormat:@"<GENSYM:%lu>",gGensyms++];
            atom.name = name;
            return atom;
        }
            break;
        case WHILE:
            CHECKATLEASTARGS(1); // At least the test...
            while ([[args objectAtIndex:0] eval:nil] != [Lisp lisp].NIL) {
                for(int i = 1; i < [args count]; i++)
                    [[args objectAtIndex:i] eval:nil];
            }
            return [Lisp lisp].NIL;
            break;
        case CATCH:
            CHECKARGS(2); // Tag and body
        {   NSObject *res;
            @try {
                res = [[args objectAtIndex:1] eval:nil];
            } @catch (NSException * e) {
                NSObject *tag = [[args objectAtIndex:0] eval:nil];
                if ([e name] == LispUserException) {
                    NSDictionary *d = [e userInfo];
                    if (tag == [Lisp lisp].NIL) {
                        return [[d allValues] objectAtIndex:0];
                    }
                    NSObject *obj = [d objectForKey:tag];
                    if (obj != nil) return obj;
                    else @throw e;
                }
                if (tag == [Lisp lisp].NIL) {
                    return e;
                } else @throw e;
            }
            return res;
        }
        case TEST:
            CHECKARGS(0);
        {
            NSLog(@"<test>");
        }
    }
    return nil;
}

- (NSString *)description {
    return [self toString:YES];
}

- (NSString *)toString:(BOOL)qf {
    return (qf) ? [NSString stringWithFormat:@"<Builtin:%@>",[self builtinName]] : [self builtinName];
}

@end
