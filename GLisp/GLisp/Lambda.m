//
//  Lambda.m
//  GGLisp
//
//  Created by Jan on 2012-09-25.
//  Copyright (c) 2012 Jan. All rights reserved.
//

#import "Lambda.h"
#import "TailCall.h"

@implementation Lambda

-(id)init:(NSArray *)parameters andFree:(NSArray *)free andBody:(NSArray *)body andRest:(Atom *)rest {
  	if( (self=[super init]) ) {
        _parameters = parameters;
        _free = free;
        _body = body;
        _rest = rest;
        _isSpecial = NO;
        _isMacro = NO;
 	}
	return self;
    
}

-(NSObject *)eval:(NSObject *)tail
{
    return [[Closure alloc] init:self andFree:_free andTail:tail];
}

// Shallow binding...

-(NSObject *)apply:(NSArray *)args andTail:(NSObject *)tail {
 
    if (tail == self) {  // Tail recursive call
        return [[TailCall alloc] init:self andArgs:args];
    }
    
    BOOL isTail = NO;
    
    NSInteger nParams = [_parameters count];
    NSObject *restArgs;

tailentry:;

    NSInteger nArgs = [args count];

    if (nArgs > nParams && _rest != nil)
        restArgs = [self arrToList:args from:nParams tail:[Lisp lisp].NIL];
    else if (nArgs == nParams && _rest != nil)
        restArgs = [Lisp lisp].NIL;
    else if (nArgs != nParams)
        [Lisp throwException:LispRuntimeException withReasonFormat:@"Wrong number of args:%@",[self toString:YES]];
    
    if (isTail) {
        for(int i = 0; i < nParams; i++) {
            Atom *v = (Atom *)[_parameters objectAtIndex:i];
            v.value = (NSObject *)[args objectAtIndex:i];
        }
        if (_rest != nil) {
            _rest.value = restArgs;
        }
    } else {
        for(int i = 0; i < nParams; i++) {
            Atom *v = (Atom *)[_parameters objectAtIndex:i];
            NSObject *a = (NSObject *)[args objectAtIndex:i];
            [[Lisp lisp] pushBinding:v];
            v.binding = [[Binding alloc] init:a];
        }
        if (_rest != nil) {
            [[Lisp lisp] pushBinding:_rest];
            _rest.binding = [[Binding alloc] init:restArgs];
            nParams++;
        }
    }
    
    NSObject *res;
    
    @try {
        NSUInteger n = [_body count];
        for(int i = 0; i < n; i++) {
            res = [[_body objectAtIndex:i] eval: (i == n-1) ? self : nil];
        }
    } @catch (NSException * e) {           // If we get an exceptio while evaluating the body...
        [[Lisp lisp] popBindings:nParams]; // ...don't forget to unwind the stack
        @throw e;
    }
    
    if ([res isKindOfClass:[TailCall class]]) {   // Ok, we got back a tailCall...
        TailCall *tc = (TailCall *)res;
        if (tc.fun == self) {                     // ...and it's from ourselves (could be a chained tailcall)
            if ([[Lisp lisp] isTrue:@"*trace-tailcall*"])
                NSLog(@"Tailcall[%ld]:%@",[Lisp lisp].stackSize, [self toString:YES]);
            isTail = YES;
            args = tc.args;  // get the new args
            goto tailentry;  // and go back to the top...
        }
    }
    
    [[Lisp lisp] popBindings:nParams];
    return res;
}

-(id <Function>)funBinding {
    return self;
}

-(NSString *)toString:(BOOL)qf {
    NSObject *theTail = (_rest != nil) ? _rest : [Lisp lisp].NIL;
    NSObject *res = makeCons([Lisp lisp].LAMBDA, makeCons([self arrToList:_parameters from:0 tail:theTail],[Lisp arrayToList:_body]));
    return [res toString:qf];
}

-(NSObject *)arrToList:(NSArray *)arr from:(NSInteger)start tail:(NSObject *)theTail{
    if ([arr count] == 0) return [Lisp lisp].NIL;
    Cons *res = makeCons((NSObject *)[arr objectAtIndex:start],nil);
    Cons *ptr = res;
    for(NSInteger i = start+1; i < [arr count]; i++) {
        ptr.cdr = makeCons([arr objectAtIndex:i],nil);
        ptr = (Cons *)ptr.cdr;
    }
    ptr.cdr = theTail;
    return res;
}

@end
