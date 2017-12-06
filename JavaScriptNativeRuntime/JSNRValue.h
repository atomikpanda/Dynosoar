//
//  JSNRValue.hpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRValue_hpp
#define JSNRValue_hpp

#import "JSNRInternal.h"
#import <string>

namespace JSNR {
    class String; class SigType;
    class Value {
        
    public:
        JSValueRef valueRef;
        JSObjectRef objectRef;
        JSContextRef context;
        bool isObject();
        bool isNumber();
        bool isBoolean();
        bool isString();
        bool isArray();
        bool isNull();
        bool isUndefined();
        double toNumber();
        bool toBoolean();
        NSString *toString();
        id toObject();
        bool isClass();
        bool isInstance();
        
        void *getPrivate();
        void setPrivate(void *data);
        
        
        id toObjCTypeObject(SigType sigInfo);
        void *toSignatureTypePointer(SigType sigInfo);
        
        Value(JSContextRef ctx, JSValueRef valueRef);
        static Value null(JSContextRef ctx);
        static Value string(JSContextRef ctx, std::string str);
    };
}
#endif /* JSNRValue_hpp */
