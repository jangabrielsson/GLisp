//
//  Lisp.m
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

#import "Lisp.h"

#import "Builtins.h"
#import "LexInputStream.h"

#define MKATOM(NAME) ((Atom *)[self intern:[[Atom alloc] initWithName:NAME]])

NSString * const LispParseException = @"LispParseException";
NSString * const LispCompileException = @"LispCompileException";
NSString * const LispRuntimeException = @"LispRuntimeException";
NSString * const LispUserException = @"LispUserException";

@implementation Lisp

@dynamic stackSize;

+ (Lisp *) lisp {
    static Lisp *gLisp=nil;
    if(!gLisp){
        gLisp=[Lisp alloc];
        
        gLisp = [gLisp init];
        
        [Builtins setup];
    }
    return gLisp;
}

+ (void) throwException:(NSString *)type withReasonFormat:(NSString *)aReasonFormat, ... {
    va_list args;
    va_start(args, aReasonFormat);
    NSString *reason = [[NSString alloc] initWithFormat:aReasonFormat arguments:args];
    va_end(args);
    NSException *e = [NSException
                      exceptionWithName:type
                      reason:reason
                      userInfo:nil];
    @throw e;
}

- (id) init {
    if( (self=[super init])) {
        atoms = [[NSMutableDictionary alloc] init];
        _NIL = MKATOM(@"nil");
        _T = MKATOM(@"t");
        _QUOTE = MKATOM(@"quote");
        _FUNCTION = MKATOM(@"function");
        _SETQ = MKATOM(@"setq");
        _IF = MKATOM(@"if");
        _SEND = MKATOM(@"send");
        _LAMBDA = MKATOM(@"lambda");
        _FN = MKATOM(@"fn");         // Synonym for Lambda
        _NLAMBDA = MKATOM(@"nlambda");
        _POP = MKATOM(@"poplist");

        _BACK_QUOTE = MKATOM(@"backquote");
        _BACK_COMMA = MKATOM(@"*back-comma*");
        _BACK_COMMA_DOT = MKATOM(@"*back-comma-dot*");
        _BACK_COMMA_AT = MKATOM(@"*back-comma-at*");
        
        _STD_IN = MKATOM(@"*stdin*");
        _STD_OUT = MKATOM(@"*stdout*");

        _STD_IN.value = [NSNull null];
        _STD_OUT.value = [NSNull null];
        
        _NIL.value = _NIL;
        _T.value = _T;
        
        MKATOM(@"*lisp*").value = self;
        
        bindings = [[NSMutableArray alloc] init];           // Shallow bindings (see lambda/closure)
    }
    return self;
}

- (NSInteger) stackSize {
    return [bindings count];
}

- (BOOL)isTrue:(NSString *)symbol {
    Atom *a = (Atom *)[atoms objectForKey:symbol];
    return (a != nil && a.value == self.T);
}

- (void) pushBinding:(Atom *)atom {
    [bindings addObject:atom];
    [bindings addObject:atom.binding];
}

- (void) popBindings:(NSInteger)nAtoms {
    while(nAtoms-- > 0) {
        Binding *binding = [bindings lastObject];
        [bindings removeLastObject];
        Atom *atom = [bindings lastObject];
        [bindings removeLastObject];
        atom.binding = binding;
    }
}

- (NSObject *) intern:(NSObject *)symbol {
    NSObject *iSymbol = [atoms objectForKey:symbol.description];
    if (iSymbol != nil) return iSymbol;
    else {
        [atoms setObject:symbol forKey:symbol.description];
        return symbol;
    }
}

- (NSObject *)run:(NSString *)expr {
    SReader *reader = [[SReader alloc] initWithData:[expr dataUsingEncoding: [NSString defaultCStringEncoding] ]];
    NSObject *obj = [reader read];
    if (obj == nil)
        return [Lisp lisp].NIL;
    return [[Compiler compile:obj] eval:nil];
}

- (void) loadFile:(NSString *)path {
    SReader *reader;
    
    @try {
        
        NSFileHandle *input = [NSFileHandle fileHandleForReadingAtPath:path];
        reader = [[SReader alloc] initWithFileHandle:input isConsole:NO];
        
        while (YES) {
            
            NSObject *obj = [reader read];
            
            if (obj == nil)
                return;
            
            NSObject *cObj = [Compiler compile:obj];
            
            NSObject *eObj = [cObj eval:nil];

            printf("%s\n",[[eObj toString:YES] UTF8String]);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"loadFile: Caught %@: %@", [exception name], [exception reason]);
    }
    @finally {
        [reader close];
    }
}

+ (NSObject *) arrayToList:(NSArray *)arr {
    if ([arr count] == 0)
        return [Lisp lisp].NIL;
    
    Cons *res = makeCons((NSObject *)[arr objectAtIndex:0],nil);
    Cons *ptr = res;
    for(int i = 1; i < [arr count]; i++) {
        ptr.cdr = makeCons([arr objectAtIndex:i],nil);
        ptr = (Cons *)ptr.cdr;
    }
    ptr.cdr = [Lisp lisp].NIL;
    return res;
}

+ (NSArray *) listToArrayWithTail:(NSObject *)list andTail:(NSObject **) tail {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while([list isKindOfClass:[Cons class]]) {
        [array addObject:((Cons *)list).car];
        list = ((Cons *)list).cdr;
    }
    *tail = list;
    return array;
}

+ (NSArray *) listToArray:(NSObject *)list {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while(list != [Lisp lisp].NIL) {
        [array addObject:((Cons *)list).car];
        list = ((Cons *)list).cdr;
    }
    return array;
}

@end
