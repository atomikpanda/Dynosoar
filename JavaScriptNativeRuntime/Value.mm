//
//  JSNRValue.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JavaScriptNativeRuntime.h"

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
}
