//
//  Lambda.h
//  GLisp
//
//  Created by Jan Gabrielsson on 2012-09-25.
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

#import "Lisp.h"

@class Atom;

#import "Function.h"

@interface Lambda : NSObject <Function>
{
    NSArray *_parameters;    // Parameters
    Atom *_rest;         // ...and eventual rest parameter  (lambda (a b . c) ... )
    NSArray *_body;          // Body is implicit progn
    NSArray *_free;          // Free variables in the body. Used when creating closure
}

@property BOOL isSpecial;
@property BOOL isMacro;

-(id)init:(NSArray *)parameters andFree:(NSArray *)free andBody:(NSObject *)body andRest:(Atom *)rest;
-(NSObject *)apply:(NSArray *)args andTail:(NSObject *)tail;
-(id <Function>)funBinding;
@end
