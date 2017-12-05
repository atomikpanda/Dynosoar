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

SigType sigInfo = SigType(signatureType);

void *ptr = NULL;
if (val.isNumber()) {
    ptr = sigInfo.numberToSig(val);
} else if (val.isBoolean()) {
    ptr = sigInfo.boolToSig(val);
}
else if (val.isString()) {
    ptr = sigInfo.stringToSig(val);
} else if (val.isNull()) {
    ptr = SigType::createPointer<long>(NULL);
} else if (val.isUndefined()) {
    ptr = ptr = SigType::createPointer<nullptr_t>(nil); // ???????
} else if (val.isObject()) {
    // handle object classes
    if (val.isInstance()) {
        ptr = sigInfo.instanceOrClassToSig(val);
    } else if (val.isClass()) {
        ptr = sigInfo.instanceOrClassToSig(val);
    } else if (sigInfo.type == SigType::ENCTypeUnknown) {
        
        // essentially if {CGRect={CGPoint=dd}{CGSize=dd}} pull out the types and add the sizeof(d)
        int numberOfFields = 4;
        int sizeOfField = sizeof(double);
        int sizeOfStruct = sizeOfField*numberOfFields;
        void *structPtr = (void *)malloc(sizeOfStruct);

        memset(structPtr, 0, sizeOfStruct); // zero out struct
      
        for (int i=0; i < numberOfFields; i++) {
            CGFloat mynum = 400;
            JSValueRef propAtIdx= JSObjectGetPropertyAtIndex(val.context, val.objectRef, i, NULL);
            mynum = JSValueToNumber(val.context, propAtIdx, NULL);
            
            void *fieldAddr = ((char *)structPtr)+(sizeOfField*i);
            memcpy(fieldAddr, &mynum, sizeOfField);
        }

        
        ptr = structPtr;
    }
}
assert(ptr != NULL);
// basically this will fail if ptr is NULL but will succeed if ptr is a pointer to NULL
[invocation setArgument:ptr atIndex:i+2];
