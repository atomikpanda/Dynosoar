//
//  JSNRPrimitiveTypeHandler.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/2/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//
//#define _setArg(TYPE,EXPR) { TYPE anArg = (TYPE)(EXPR);[invocation setArgument:&anArg atIndex:i+2]; }
#define _setArg(TYPE,EXPR) setArg<TYPE>((EXPR), invocation, i);
//#define _setArgNotWrapped(TYPE,EXPR) TYPE anArg = (TYPE)(EXPR);[invocation setArgument:&anArg atIndex:i+2];



std::string _st = signatureType;
void *ptr = NULL;
if (val.isNumber()) {
    double n = val.toNumber();
    
    ptr = Prim::numberToSig(n, _st);
} else if (val.isBoolean()) {
    bool b = val.toBoolean();
    ptr = Prim::boolToSig(b, _st);
}
else if (val.isString()) {
    JSNR::String str = JSNR::String(val);
    ptr = Prim::stringToSig(str, _st);
}
[invocation setArgument:ptr atIndex:i+2];
