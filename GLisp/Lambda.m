//
//  Lambda.m
//  GLisp
//
//  Created by Jan on 2012-09-25.
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
