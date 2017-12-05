//
//  JSNRInvoke.hpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/3/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRInvoke_hpp
#define JSNRInvoke_hpp

#include <stdio.h>
#include <string>
#import <JavaScriptCore/JavaScriptCore.h>

namespace JSNR {
    class String; class Value;
    class Invoke {
    public:
        static std::string parseSetSelector(std::string propertyName);
        static std::string parseGetSelector(std::string propertyName);
        static JSValueRef invokeFunction(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef);
    };
    
    class InvokeInfo {
        
    public:
        id target;
        std::string selector;
        bool targetIsClass;
        
        InvokeInfo(id target, std::string selector, bool targetIsClass=false);
    };
}

#endif /* JSNRInvoke_hpp */
