//
//  JSNRExampleSubclass.hpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRInstance_hpp
#define JSNRInstance_hpp

#import "JSNRInternal.h"
#import <string>

#import "BaseClass.h"
namespace JSNR {
    class String; class Value;
    class Instance {
    public:
        static JSClassRef classRef();
        
        static JSValueRef convertToType(JSContextRef ctx, JSObjectRef objectRef, JSType type, JSValueRef *exceptionRef);
//        static JSObjectRef asConstructor(JSContextRef ctx, JSObjectRef constructorRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exception);
        static JSValueRef asFunction(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef);
        static void finalize(JSObjectRef objectRef);
        static JSValueRef getCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef *exceptionRef);
        static bool setCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef valueRef, JSValueRef *exceptionRef);
        static JSObjectRef instanceWithObject( JSContextRef ctx, id objcObject);
    };
}
#endif /* JSNRInstance_hpp */
