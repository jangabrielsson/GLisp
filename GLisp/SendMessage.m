//
//  SendMessage.m
//  GLisp
//
//  Created by Jan Gabrielsson on 2012-09-24.
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

#import "SendMessage.h"

@implementation SendMessage

-(id)init:(NSObject *)obj andArgs:(NSArray *)args {
  	if( (self=[super init]) ) {
        _obj = obj;
        _args = args;
    }
    
    NSString *selString = @"";
    theArgs = [[NSMutableArray alloc] init];
        
    if ([self.args count] == 1) {
        NSObject *msg = [self.args objectAtIndex:0];
        if ([msg class] != [Keyword class ])
            [Lisp throwException:LispCompileException withReasonFormat:@"Message identifier error"];
        selString = ((Keyword *)msg).name;
        selString = [selString substringWithRange:NSMakeRange(0, [selString length]-1)];
    } else {
        for(int i = 0; i < [self.args count]; i += 2) {
            NSObject *msg = [self.args objectAtIndex:i];
            if ([msg class] != [Keyword class])
                [Lisp throwException:LispCompileException withReasonFormat:@"Message identifier error"];
            selString = [selString stringByAppendingString:((Keyword *)msg).name];
            [theArgs addObject:[self.args objectAtIndex:i+1]];
        }
    }
    
    selector = NSSelectorFromString(selString);
    if (selector == nil)
        [Lisp throwException:LispCompileException withReasonFormat:@"Message identifier error"];

    return self;
}

-(NSObject *)eval:(NSObject *)tail{
    
    NSObject *target = [self.obj eval:nil];
    signature = [target methodSignatureForSelector:selector];
    if (signature == nil)
        [Lisp throwException:LispCompileException withReasonFormat:@"Message identifier error"];
    
    // Check that we have the right # of args
    NSUInteger parameterCount = [theArgs count];
    NSUInteger argumentCount = [signature numberOfArguments] - 2;
    if (parameterCount != argumentCount)
        [Lisp throwException:LispCompileException withReasonFormat:@"Wrong number of args"];
    
    NSInvocation *theInvocation =
    [NSInvocation invocationWithMethodSignature:signature];
    
    [theInvocation setTarget:target];       // There's our index 0.
    [theInvocation setSelector:selector];   // There's our index 1.
    
    // Setup the arguments
    for (NSUInteger i = 0; i < parameterCount; i++) {
        
        id currentValue = [[theArgs objectAtIndex:i] eval:nil];
        const char *argType = [signature getArgumentTypeAtIndex:i+2];
        
        [self packParameter:currentValue ofType:argType toInvocation:theInvocation atIndex:i];
     }
    
    [theInvocation invoke];
    
    NSUInteger length = [signature methodReturnLength];
    const char *retType = [signature methodReturnType];
    
    return [self unpackResult:theInvocation ofType:retType ofLength:length];
}

-(void) packParameter:(id)currentValue ofType:(const char*)argType toInvocation:(NSInvocation *)theInvocation atIndex:(NSUInteger)index
{   int i = (int)index;

    switch(argType[0]) {
            case 'c': // A char
        {
            NSNumber *num = (NSNumber *)currentValue;
            char c1 = (char)[num longLongValue];
            [theInvocation setArgument:&c1 atIndex:(i + 2)];
        }
            break;
            case 'i': // An int
        {
            NSNumber *num = (NSNumber *)currentValue;
            int i1 = (int)[num longLongValue];
            [theInvocation setArgument:&i1 atIndex:(i + 2)];
        }
            break;
            case 's': // A short
        {
            NSNumber *num = (NSNumber *)currentValue;
            short s1 = (short)[num longLongValue];
            [theInvocation setArgument:&s1 atIndex:(i + 2)];
        }
            break;
            case 'l': // A long l is treated as a 32-bit quantity on 64-bit programs.
        {
            NSNumber *num = (NSNumber *)currentValue;
            long l1 = (long)[num longLongValue];
            [theInvocation setArgument:&l1 atIndex:(i + 2)];
        }
            break;
            case 'q': // A long long
        {
            NSNumber *num = (NSNumber *)currentValue;
            long long l1 = [num longLongValue];
            [theInvocation setArgument:&l1 atIndex:(i + 2)];
        }
            break;
            case 'C': // An unsigned char
        {
            NSNumber *num = (NSNumber *)currentValue;
            unsigned char c1 = (unsigned char)[num longLongValue];
            [theInvocation setArgument:&c1 atIndex:(i + 2)];
        }
            break;
            case 'I': // An unsigned int
        {
            NSNumber *num = (NSNumber *)currentValue;
            unsigned int i1 = (unsigned int)[num longLongValue];
            [theInvocation setArgument:&i1 atIndex:(i + 2)];
        }
            break;
            case 'S': // An unsigned short
        {
            NSNumber *num = (NSNumber *)currentValue;
            unsigned short s1 = (unsigned short)[num longLongValue];
            [theInvocation setArgument:&s1 atIndex:(i + 2)];
        }
            break;
            case 'L': // An unsigned long
        {
            NSNumber *num = (NSNumber *)currentValue;
            unsigned long l1 = (unsigned long)[num longLongValue];
            [theInvocation setArgument:&l1 atIndex:(i + 2)];
        }
            break;
            case 'Q': // An unsigned long long
        {
            NSNumber *num = (NSNumber *)currentValue;
            unsigned long long l1 = (unsigned long long)[num longLongValue];
            [theInvocation setArgument:&l1 atIndex:(i + 2)];
        }
            break;
            case 'f': // A float
        {
            NSNumber *num = (NSNumber *)currentValue;
            float f1 = (float)[num doubleValue];
            [theInvocation setArgument:&f1 atIndex:(i + 2)];
        }
            break;
            case 'd': // A double
        {
            NSNumber *num = (NSNumber *)currentValue;
            double d1 = [num doubleValue];
            [theInvocation setArgument:&d1 atIndex:(i + 2)];
        }
            break;
            case 'B': // A C++ bool or a C99 _Bool
        {
            BOOL b = (currentValue == [Lisp lisp].NIL) ? NO : YES;
            [theInvocation setArgument:&b atIndex:(i + 2)];
        }
            break;
            case 'v': // A void
        {
            // ???
        }
            break;
            case '*': // A character string (char *)
        {
            // ???
        }
            break;
            case '@': // An object (whether statically typed or typed id)
        {
            [theInvocation setArgument:&currentValue atIndex:(i + 2)];
        }
            break;
            case '#': // A class object (Class)
        {
            [theInvocation setArgument:&currentValue atIndex:(i + 2)];
        }
            break;
            case ':': // A method selector (SEL)
        {
            [theInvocation setArgument:&currentValue atIndex:(i + 2)];
        }
            break;
            case '[': // ...array type] An array
            break;
            case '{': // ...name=type...} A structure
            break;
            case '(': // ...name=type...) A union
            break;
            case 'b': // bnum. A bit field of num bits
            break;
            case '^': // ^type. A pointer to type
            break;
            case '?': // An unknown type (among other things, this code is used for function pointers)
            break;
    }
}

- (id)unpackResult:(NSInvocation *)theInvocation ofType:(const char *)retType ofLength:(NSUInteger)length
{
    switch(retType[0]) {
        case 'c': // A char
        {
            char c;
            [theInvocation getReturnValue:&c];
            return [NSDecimalNumber numberWithLongLong:(long long)c];
        }
            break;
        case 'i': // An int
        {
            int i;
            [theInvocation getReturnValue:&i];
            return [NSDecimalNumber numberWithLongLong:(long long)i];
        }
            break;
        case 's': // A short
        {
            short s;
            [theInvocation getReturnValue:&s];
            return [NSDecimalNumber numberWithLongLong:(long long)s];
        }
            break;
        case 'l': // A long l is treated as a 32-bit quantity on 64-bit programs.
        {
            long l;
            [theInvocation getReturnValue:&l];
            return [NSDecimalNumber numberWithLongLong:(long long)l];
        }
            break;
        case 'q': // A long long
        {
            long long ll;
            [theInvocation getReturnValue:&ll];
            return [NSDecimalNumber numberWithLongLong:(long long)ll];
        }
            break;
        case 'C': // An unsigned char
        {
            unsigned char uc;
            [theInvocation getReturnValue:&uc];
            return [NSDecimalNumber numberWithLongLong:(long long)uc];
        }
            break;
        case 'I': // An unsigned int
        {
            unsigned int ui;
            [theInvocation getReturnValue:&ui];
            return [NSDecimalNumber numberWithLongLong:(long long)ui];
        }
            break;
        case 'S': // An unsigned short
        {
            unsigned short us;
            [theInvocation getReturnValue:&us];
            return [NSDecimalNumber numberWithLongLong:(long long)us];
        }
            break;
        case 'L': // An unsigned long
        {
            unsigned long ul;
            [theInvocation getReturnValue:&ul];
            return [NSDecimalNumber numberWithLongLong:(long long)ul];
        }
            break;
        case 'Q': // An unsigned long long
        {
            long long ll;
            [theInvocation getReturnValue:&ll];
            return [NSDecimalNumber numberWithLongLong:(long long)ll];
        }
            break;
        case 'f': // A float
        {
            float f;
            [theInvocation getReturnValue:&f];
            return [NSDecimalNumber numberWithDouble:(double)f];
        }
            break;
        case 'd': // A double
        {
            double d;
            [theInvocation getReturnValue:&d];
            return [NSDecimalNumber numberWithDouble:d];
        }
            break;
        case 'B': // A C++ bool or a C99 _Bool
        {
            BOOL b;
            [theInvocation getReturnValue:&b];
            return (b) ? [Lisp lisp].T : [Lisp lisp].NIL;
        }
            break;
        case 'v': // A void
        {
            return [Lisp lisp].NIL;
        }
            break;
        case '*': // A character string (char *)
        {
            // ???
        }
            break;
        case '@': // An object (whether statically typed or typed id)
        {
            NSObject *no;
            [theInvocation getReturnValue:&no];
            return no;
        }
            break;
        case '#': // A class object (Class)
        {
            Class *cl;
            [theInvocation getReturnValue:&cl];
            return *cl;
        }
            break;
        case ':': // A method selector (SEL)
        {
            SEL sel;
            [theInvocation getReturnValue:&sel];
            //return sel;
        }
            break;
        case '[': // ...array type] An array
            break;
        case '{': // ...name=type...} A structure
            break;
        case '(': // ...name=type...) A union
            break;
        case 'b': // bnum. A bit field of num bits
            break;
        case '^': // ^type. A pointer to type
            break;
        case '?': // An unknown type (among other things, this code is used for function pointers)
            break;
    } 
    
    // If method is void:
    return [Lisp lisp].NIL;
}

-(NSString *)toString:(BOOL)qf {
    NSMutableString *res = [NSMutableString stringWithFormat:@"[%@",[self.obj toString:qf]];
    for(NSObject *a in self.args)
        [res appendFormat:@" %@",[a toString:qf]];
    [res appendString:@"]"];
    return res;
}

@end
