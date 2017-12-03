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
    class String;
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
        double toNumber();
        bool toBoolean();
        NSString *toString();
        id toObject();
        
        void *getPrivate();
        void setPrivate(void *data);
        
        
    
        template <typename Type_>
        Type_ &toObjCTypePrimitive(std::string signatureType) {
            // handles numbers and strings as double and const char*
            if (signatureType == "d") {
                double *r;
                double a = this->toNumber();
                r = &a;
//                void *pointer(reinterpret_cast<char *>(this->toNumber()));
                return *reinterpret_cast<Type_ *>(r);
            }
            int error=0;
            int *err; err = &error;
            return *reinterpret_cast<Type_ *>(err);
        }
        
        id toObjCTypeObject(std::string signatureType);
        
        Value(JSContextRef ctx, JSValueRef valueRef);
        static Value null(JSContextRef ctx);
        static Value string(JSContextRef ctx, std::string str);
    };
}
#endif /* JSNRValue_hpp */
