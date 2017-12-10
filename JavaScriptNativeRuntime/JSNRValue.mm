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
#import "JSNRObjCClassClass.h"
#import "JSNRInstanceClass.h"
#import "JSNRInvokeInfo.h"

@implementation NSString (JSNR)

+ (instancetype)stringWithJSStringRef:(JSStringRef)jsString {
    size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(jsString);
    char* utf8Buffer = new char[maxBufferSize];
    size_t bytesWritten = JSStringGetUTF8CString(jsString, utf8Buffer, maxBufferSize);
    std::string utf_string = std::string(utf8Buffer, bytesWritten -1); // the last byte is a null \0 which std::string doesn't need.
    delete[] utf8Buffer;
    
    return @(utf_string.c_str());
}

- (JSValue *)valueInContext:(JSContext *)context {
    JSStringRef jsString = JSStringCreateWithUTF8CString(self.UTF8String);
    return [JSValue valueWithJSValueRef:JSValueMakeString((JSContextRef)context.JSGlobalContextRef, jsString) inContext:context];
}

@end

@implementation JSValue (JSNRValue)

- (void)setPrivateData:(void *)data {
    JSObjectSetPrivate((JSObjectRef)self.JSValueRef, data);
}

- (void *)privateData {
    return JSObjectGetPrivate((JSObjectRef)self.JSValueRef);
}

- (void)setContainer:(JSNRContainer *)container {
    self.privateData = container;
}

- (JSNRContainer *)container {
    return (JSNRContainer *)self.privateData;
}

- (BOOL)isClassObject {
    JSContextRef ctx = (JSContextRef)self.context.JSGlobalContextRef;
    return JSValueIsObjectOfClass(ctx, self.JSValueRef, [[[JSNRObjCClassClass alloc] init] classReference]);
}

- (BOOL)isInstanceObject {
    JSContextRef ctx = (JSContextRef)self.context.JSGlobalContextRef;
    return JSValueIsObjectOfClass(ctx, self.JSValueRef, [[[JSNRInstanceClass alloc] init] classReference]);
}

- (void)dealloc {
    
    [super dealloc];
}

@end

namespace JSNR {
    
    Value::Value(JSContextRef ctx, JSValueRef valueRef) {
        this->context = ctx;
        this->valueRef = valueRef;
        this->objectRef = (JSObjectRef)valueRef;
    }
    // this handles return data from JSNRInvokes
    Value::Value(JSContextRef ctx, SigType sigInfo, void *methodReturnData) {
        this->context = ctx;
        
        JSValueRef localValueRef = JSValueMakeUndefined(ctx);
        
        if (sigInfo.isEncodingBoolean()) {
            localValueRef = JSValueMakeBoolean(ctx, sigInfo.boolFromPointer<bool>(methodReturnData));
        } else if (sigInfo.isEncodingInstanceOrClass()) {
            if (sigInfo.type == SigType::ENCTypeClass) {
                
                localValueRef = [JSNRSuperClass createEmptyObjectRefWithContext:ctx classRef:[JSNRObjCClassClass sharedReference]];
                JSNRContainer *container = (id)JSObjectGetPrivate((JSObjectRef)localValueRef);
                container.info = [JSNRInvokeInfo infoWithTarget:(id)methodReturnData selector:nil isClass:YES];
                
            } else if (sigInfo.type == SigType::ENCTypeObject) {
                
                localValueRef = [JSNRSuperClass createEmptyObjectRefWithContext:ctx classRef:[JSNRInstanceClass sharedReference]];
                JSNRContainer *container = (id)JSObjectGetPrivate((JSObjectRef)localValueRef);
                container.info = [JSNRInvokeInfo infoWithTarget:(id)methodReturnData selector:nil isClass:NO];
            }
        } else if (sigInfo.type == SigType::ENCTypeCharPointer) {
            localValueRef = JSNR::String((const char *)methodReturnData).value(ctx).valueRef;
        } else if (sigInfo.isEncodingNumber()) {
            
            localValueRef = JSValueMakeNumber(ctx, sigInfo.doubleFromPointer<double>(methodReturnData));
            
        }
        
        this->valueRef = localValueRef;
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
        return JSValueIsObjectOfClass(context, objectRef, [JSNRObjCClassClass sharedReference].classReference);
    }
    
    bool Value::isInstance() {
        return JSValueIsObjectOfClass(context, objectRef, [JSNRInstanceClass sharedReference].classReference);
    }
    
    NSString *Value::toString() {
        return String(*this).NSString();
    }
    
    id Value::toObject() {
        if (isClass() || isInstance()) {
            JSNRContainer *container = (id)getPrivate();
            JSNRInvokeInfo *info = container.info;
            
            return info.target;
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
    
    void *Value::toSignatureTypePointer(SigType sigInfo) {
        void *ptr = NULL;
        
        if (isNumber()) {
            ptr = sigInfo.numberToSig(*this);
        } else if (isBoolean()) {
            ptr = sigInfo.boolToSig(*this);
        }
        else if (isString()) {
            ptr = sigInfo.stringToSig(*this);
        } else if (isNull()) {
            ptr = sigInfo.createPointer<long>(NULL);
        } else if (isUndefined()) {
            ptr = sigInfo.createPointer<nullptr_t>(nil); // ???????
        } else if (isObject()) {
            // handle object classes
            if (isInstance()) {
                ptr = sigInfo.instanceOrClassToSig(*this);
                
            } else if (isClass()) {
                ptr = sigInfo.instanceOrClassToSig(*this);
            } else if (sigInfo.type == SigType::ENCTypeUnknown) {
                
                // essentially if {CGRect={CGPoint=dd}{CGSize=dd}} pull out the types and add the sizeof(d)
                int numberOfFields = 4;
                unsigned long *fieldSizes = (unsigned long *)malloc(sizeof(unsigned long)*numberOfFields);
                memset(fieldSizes, 0, sizeof(unsigned long)*numberOfFields);
                
                for(int i=0; i < numberOfFields; i++) {
                    
                    unsigned long aSize = sizeof(CGFloat); // here we would access some array of field sizes that was parsed from sigInfo
                    memcpy(((char *)fieldSizes)+(sizeof(unsigned long)*i), &aSize, sizeof(unsigned long));
                }
                
                ptr = SigType::allocateAggregatePointer(*this, fieldSizes, numberOfFields);
            }
        }
        assert(ptr != NULL);
        
        return ptr;
    }

}
