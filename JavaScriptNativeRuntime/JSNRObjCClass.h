//
//  JSNRObjCClass.hpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/30/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRObjCClass_hpp
#define JSNRObjCClass_hpp

#import "JSNRInternal.h"
#import <string>

template<class T>
T JSValueRefToPrimitive(JSContextRef ctx, JSValueRef value);
bool JSValueRefShouldConvertToPrimitive(JSContextRef ctx, JSValueRef value);
id JSValueRefToObjCType(JSContextRef ctx, JSValueRef value);

class JSNRObjCObjectInfo {
    
public:
    id target;
    std::string selector;
    JSNRObjCObjectInfo(id target, std::string selector);
};
class JSNRObjCClass {

    
public:
    static JSValueRef JSNRObjCClassGet(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef *exception);
};
//struct JSNRNSObjectWrap {
//    id target;
//    const char *selector;
//};
//JSNRNSObjectWrap *wrapTargetSelector(id target, const char *selector) ;
id toObject(JSContextRef ctx, JSValueRef value);
JSObjectRef JSNRObjCClassObjectFromId( JSContextRef ctx, id objcObject);
JSClassRef JSNRObjCClass();
#endif /* JSNRObjCClass_hpp */
