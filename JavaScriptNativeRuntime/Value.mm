//
//  JSNRValue.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JavaScriptNativeRuntime.h"
#import "JSNRInvoke.h"
#import "JSNRSigType.hpp"

namespace JSNR {
    
    Value::Value(JSContextRef ctx, JSValueRef valueRef) {
        this->context = ctx;
        this->valueRef = valueRef;
        this->objectRef = (JSObjectRef)valueRef;
    }

    Value Value::null(JSContextRef ctx) {
        return Value(ctx, JSValueMakeNull(ctx));
    }

    Value Value::string(JSContextRef ctx, std::string str) {
        return String(str).value(ctx);
    }
    
    void *Value::getPrivate() {
        return JSObjectGetPrivate(this->objectRef);
    }
    
    void Value::setPrivate(void *data) {
        JSObjectSetPrivate(this->objectRef, data);
    }

    bool Value::isObject() {
        return JSValueIsObject(this->context, this->valueRef);
    }

    bool Value::isNumber() {
        return JSValueIsNumber(this->context, this->valueRef);
    }

    bool Value::isBoolean() {
        return JSValueIsBoolean(this->context, this->valueRef);
    }

    bool Value::isString() {
        return JSValueIsString(this->context, this->valueRef);
    }

    bool Value::isArray() {
        return JSValueIsArray(this->context, this->valueRef);
    }

    bool Value::isNull() {
        return JSValueIsNull(this->context, this->valueRef);
    }
    
    bool Value::isUndefined() {
        return JSValueIsUndefined(context, valueRef);
    }
    
    double Value::toNumber() {
        return JSValueToNumber(context, valueRef, NULL);
    }
    
    bool Value::toBoolean() {
        return JSValueToBoolean(context, valueRef);
    }
    
    bool Value::isClass() {
        return JSValueIsObjectOfClass(context, objectRef, ObjCClass::classRef());
    }
    
    bool Value::isInstance() {
        return JSValueIsObjectOfClass(context, objectRef, Instance::classRef());
    }
    
    NSString *Value::toString() {
        return String(*this).NSString();
    }
    
    id Value::toObject() {
        if (isClass() || isInstance()) {
            InvokeInfo *info = static_cast<InvokeInfo *>(getPrivate());
            
            id target = info->target;
            
            return target;
        }
        
        return nil;
    }
    
    
    id Value::toObjCTypeObject(SigType sigInfo) {
        // handles number types to NSNumber
        
        if (sigInfo.type == SigType::ENCTypeObject || sigInfo.type == SigType::ENCTypeClass) {
            // convert the JSValue to the corresponding signature type which is object
            if (isClass() || isInstance()) {
                
                return toObject();
            } else if (isString()) {
                return toString();
            } else if (isNumber()) {
                return @(toNumber());
            } else if (isBoolean()) {
                return @(toBoolean());
            }
        }
        return nil;
    }
    
//    id Value::toObjCType() {
//        JSContextRef ctx = this->context;
//
//        if (isObject()) {
//
//            if (JSValueIsObjectOfClass(ctx, objectRef, ObjCClass::classRef())) {
//                InvokeInfo *info = static_cast<InvokeInfo *>(getPrivate());
//                id target = info->target;
//
//                return target;
//            } else {
//                // handle other types like Arrays, Etc
//            }
//        }
//        else if (isString()) {
//            // totally unsafe
//            return String(*this).NSString();
//        }
//
//        return @"LOLZ WE AREHEREXXZ";
//    }
}
