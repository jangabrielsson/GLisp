//
//  Compiler.m
//  GGLisp
//
//  Created by Jan Gabrielsson on 2012-09-17.
//  Copyright (c) 2012 Jan Gabrielsson. All rights reserved.
//

#import "Compiler.h"

#import "LSetQ.h"
#import "LIf.h"
#import "LPopList.h"
#import "Call.h"
#import "SendMessage.h"

@implementation Compiler

+(NSObject *)compile:(NSObject *)aObj {
    NSMutableArray *env = [[NSMutableArray alloc] init];
    return [Compiler compile:aObj andEnv:env];
}

+(NSObject *)compile:(NSObject *)aObj andEnv:(NSMutableArray *)env {
    //NSLog(@"Compiling:%@",aObj);
    
    if ([aObj isKindOfClass:[Cons class]]) {        // (fun ....)
        NSObject *car = ((Cons *)aObj).car;
        NSObject *cdr = ((Cons *)aObj).cdr;
                
        if (car == [Lisp lisp].QUOTE) {
            return [[Const alloc] init:((Cons *)cdr).car];
        }
        
        else if (car == [Lisp lisp].SETQ) {
            NSArray *args = [Lisp listToArray:cdr];
            if (args.count % 2 != 0 || args.count < 2)
                [Lisp throwException:LispCompileException withReasonFormat:@"Wrong args to SETQ"];
            for (int i = 0; i < args.count; i+=2) {
                NSObject *a = (NSObject *)[args objectAtIndex:i];
                if (! [a isKindOfClass:[Atom class]])
                    [Lisp throwException:LispCompileException withReasonFormat:@"Wrong args to SETQ"];
            }
            return [[LSetQ alloc] initWithArgs: [Compiler compileArgs:args andEnv:env]];
        }
        
        else if (car == [Lisp lisp].POP) {
            NSArray *args = [Lisp listToArray:cdr];
            if (args.count != 1)
                [Lisp throwException:LispCompileException withReasonFormat:@"Wrong args to POPLIST"];
            NSObject *a = (NSObject *)[args objectAtIndex:0];
            if (! [a isKindOfClass:[Atom class]])
                [Lisp throwException:LispCompileException withReasonFormat:@"Wrong args to POPLIST"];
            return [[LPopList alloc] initWithAtom:(Atom *)a];
        }
        
        else if (car == [Lisp lisp].IF) {
            NSArray *args = [Lisp listToArray:cdr];
            if (args.count > 3 || args.count < 2)
                [Lisp throwException:LispCompileException withReasonFormat:@"Wrong number of args to IF"];
            args = [self compileArgs:args andEnv:env];
            NSObject *aTest = (NSObject *)[args objectAtIndex:0];
            NSObject *aThen = (NSObject *)[args objectAtIndex:1];
            NSObject *aElse = (args.count == 3) ? (NSObject *)[args objectAtIndex:2] : [Lisp lisp].NIL;
            return [[LIf alloc] initWithTest:aTest andThen:aThen andElse:aElse];
        }
                        
        else if (car == [Lisp lisp].SEND) {
            NSObject *obj = ((Cons *)cdr).car;
            cdr = ((Cons *)cdr).cdr;
            NSArray *args = [Lisp listToArray:cdr];
            return [[SendMessage alloc] init:[self compile:obj andEnv:env] andArgs:[self compileArgs:args andEnv:env]];
        }
        
        else if (car == [Lisp lisp].LAMBDA
                 || car == [Lisp lisp].FN
                 || car == [Lisp lisp].NLAMBDA) {

            Atom *rest = nil;;
            NSArray *params = [Lisp listToArrayWithTail:cdr.first andTail:&rest];

            env = [env mutableCopy]; //[[NSMutableArray alloc] init];
            
            NSArray *body = [self compileArgs:[Lisp listToArray:cdr.rest] andEnv:env];

            [env removeObjectsInArray:params];
            if (rest == [Lisp lisp].NIL)
                rest = nil;
            else [env removeObject:rest];
   
            Lambda *lambda = [[Lambda alloc] init:params andFree:env andBody:body andRest:rest];
            if (car == [Lisp lisp].NLAMBDA)
                lambda.isMacro = YES;
            return lambda;
        }
                
        else {      // Lisp Call 
            NSObject *fun = car;
            NSArray *args = [Lisp listToArray:cdr];
            if (fun.isMacro) {
                id <Function> f = fun.funBinding;
                NSObject *expand = [self compile:[f apply:args andTail:nil] andEnv:env];
                if ([[Lisp lisp] isTrue:@"*trace-macroexpand*"])
                    NSLog(@"Macro expand:%@ to %@",aObj,[expand toString:YES]);
                return expand; //[self compile:expand andEnv:env];
            }
            NSArray *cargs = (fun.isMacro) ? args : [self compileArgs:args andEnv:env];
            return [[Call alloc] init:[self compile:fun andEnv:env] andArgs:cargs andOrgArgs:args]; // Use new Env here...;
        }
        
    } else if ([aObj isKindOfClass:[Atom class]]) { // Atom
        if (!([env containsObject:aObj] || aObj == [Lisp lisp].NIL))
            [env addObject:aObj];
        return aObj;
    }
    return aObj;                                    // Number/String/NSObject
}

+(NSArray *)compileArgs:(NSArray *)args andEnv:(NSMutableArray *)env {
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:[args count]];
    for(NSObject *a in args)
        [res addObject:[self compile:a andEnv:env]];
    return res;
}

@end
