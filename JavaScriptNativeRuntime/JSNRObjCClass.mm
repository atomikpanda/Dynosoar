//
//  JSNRObjCClass.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/30/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRObjCClass.h"
#import "JavaScriptNativeRuntime.h"
#import <iostream>
#import <map>
#import <objc/runtime.h>

using namespace std;

JSNRObjCObjectInfo::JSNRObjCObjectInfo(id target, std::string selector) {
//    if (target) target = [target retain];
    this->target = target;
    this->selector = selector;
}

JSObjectRef JSNRObjCClassObjectFromId( JSContextRef ctx, id objcObject) {
    JSObjectRef obj = JSObjectMake(ctx, JSNR::ObjCClass::classRef(), NULL);
    JSNR::ObjCInvokeInfo *objectInfo = new JSNR::ObjCInvokeInfo(objcObject, "");
    JSObjectSetPrivate(obj, objectInfo);
    return obj;
}

//JSNRNSObjectWrap *wrapTargetSelector(id target, const char *selector) {
//    JSNRNSObjectWrap *wrapper = (JSNRNSObjectWrap *)malloc(sizeof(JSNRNSObjectWrap));
//    wrapper->target = target;
//    if (selector) {
//        char *copied = (char *)malloc(sizeof(selector));
//        strcpy(copied, selector);
//        selector = copied;
//    }
//    wrapper->selector = selector;
//    return wrapper;
//}

JSValueRef JSNRObjCClassFunction(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    cout << "ObjCClass called as function" << endl;

    JSNRObjCObjectInfo *info = static_cast<JSNRObjCObjectInfo *>(JSObjectGetPrivate(function));
    Class thisClass = (Class)info->target;
    cout << "looks like: " << class_getName(thisClass) << endl;
    
//    free(wrap);
    id firstObject = [[thisClass alloc] init];
    
    JSNRObjCObjectInfo *firstObjectInfo = new JSNRObjCObjectInfo(firstObject, "");
    JSObjectSetPrivate(function, firstObjectInfo);
    
    return function;
    
}

bool JSValueRefShouldConvertToPrimitive(JSContextRef ctx, JSValueRef value) {
    if (JSValueIsString(ctx, value)) {
        return false;
    } else if (JSValueIsNumber(ctx, value)) {
        return true;
    } else if (JSValueIsBoolean(ctx, value)) {
        return true;
    } else if (JSValueIsNull(ctx, value)) {
        return false;
    } else if (JSValueIsUndefined(ctx, value)) {
        return false;
    } else if (JSValueIsArray(ctx, value)) {
        return false;
    } else if (JSValueIsDate(ctx, value)) {
        return false;
    } else if (JSValueIsObject(ctx, value)) {
        
        if (JSObjectIsFunction(ctx, (JSObjectRef)value)) {
            return false;
        } else if (JSObjectIsConstructor(ctx, (JSObjectRef)value)) {
            return false;
        }
        
        return false;
    }
    
    return false;
}

id JSValueRefToObjCType(JSContextRef ctx, JSValueRef value) {
    
    if (JSValueIsObject(ctx, value)) {
        JSObjectRef object = (JSObjectRef)value;
        if (JSValueIsObjectOfClass(ctx, value, JSNR::ObjCClass::classRef())) {
            JSNR::ObjCInvokeInfo *info = static_cast<JSNR::ObjCInvokeInfo *>(JSObjectGetPrivate(object));
            id target = info->target;
            
            return target;
        } else {
            // handle other types like Arrays, Etc
        }
    }
     else if (JSValueIsString(ctx, value)) {
        // totally unsafe
         
        return JSNR::String(JSNR::Value(ctx, value)).NSString();
    }
    
    return @"LOLZ WE AREHEREXXZ";
}
template<typename T>
T JSValueRefToPrimitive(JSContextRef ctx, JSValueRef value) {
    if (JSValueIsNumber(ctx, value)) {
        return JSValueToNumber(ctx, value, NULL);
    } else if (JSValueIsBoolean(ctx, value)) {
        return JSValueToBoolean(ctx, value);
    }
    
    return NULL;
}
//   ****** TO DO WRITE A FUNCTION THAT CHECKS IF WE SHOULD USE AN NSOBJECT OR PRIMITIVE TYPE
id toObject(JSContextRef ctx, JSValueRef value) {
    // WRITE THIS FUNCTION TO CHANGE JSVALUEREFS INTO CTYPES or NSOBJECTS
    
    if (JSValueIsObject(ctx, value)) {
        JSObjectRef object = (JSObjectRef)value;
        if (JSValueIsObjectOfClass(ctx, value, JSNRObjCClass())) {
            JSNRObjCObjectInfo *info = static_cast<JSNRObjCObjectInfo *>(JSObjectGetPrivate(object));
            id target = info->target;
            return target;
        } else {
            // handle other types like Arrays, Etc
        }
    } else if (JSValueIsNumber(ctx, value)) {
        return @(JSValueToNumber(ctx, value, NULL));  //wrong
    }
    else if (JSValueIsBoolean(ctx, value)) {
//        return JSValueToBoolean(ctx, value);
    } else if (JSValueIsString(ctx, value)) {
        // totally unsafe
        return JSNR::String(JSNR::Value(ctx, value)).NSString();
    }
    
    return @"LOLLLLLL WE ARE";
}

JSValueRef invokeFunction(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    
    JSNRObjCObjectInfo *info = static_cast<JSNRObjCObjectInfo *>(JSObjectGetPrivate(thisObject));
    id target = info->target;
    BOOL targetIsClass = class_isMetaClass(object_getClass(target));

//        JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback(ctx, NULL, invokeFunction);
    
    
    
        if (info->selector.length() > 0) {
            if (targetIsClass)
                cout << "invoke " << info->selector << " on class " << class_getName(target) << endl;
            else
                cout << "invoke " << info->selector << " on object of class " << object_getClassName(target) << endl;
            
//            if (argumentCount > 0) {
//                JSValueRef firstArg = arguments[0];
//                NSLog(@"argument: %@", toObject(ctx, firstArg));
//            }
            NSString *method = @(info->selector.c_str());
            NSUInteger numberOfArgs = [method componentsSeparatedByString:@":"].count;
            if ([method rangeOfString:@":"].location == NSNotFound) numberOfArgs = 0;
            if (numberOfArgs != argumentCount) {
                method = [method stringByReplacingOccurrencesOfString:@"$$" withString:@":"];
            }
//            NSLog(@"meth: %@,%@,%@", thisObject, method, arguments);
            NSLog(@"invokMethod: %@", method);
            NSMethodSignature *signature;
            if (targetIsClass) {
                
                if (![target respondsToSelector:NSSelectorFromString(method)]) return nil;
                
                signature = [target methodSignatureForSelector:NSSelectorFromString(method)];
            } else {
                
                if (![target respondsToSelector:NSSelectorFromString(method)]) return nil;
                
                signature = [[target class] instanceMethodSignatureForSelector:NSSelectorFromString(method)];
            }
            
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            [invocation setTarget:target];
            [invocation setSelector:NSSelectorFromString(method)];
            
            for (int i=0; i < argumentCount; i++) {
                JSValueRef valueOfArg = arguments[i];
                bool isPrimitive= JSValueRefShouldConvertToPrimitive(ctx, valueOfArg);
                
                if (isPrimitive) {
                    if (JSValueIsNumber(ctx, valueOfArg)) {
                        double anArg = JSValueRefToPrimitive<double>(ctx, valueOfArg);
                        [invocation setArgument:&anArg atIndex:i+2];
                    } else if (JSValueIsBoolean(ctx, valueOfArg)) {
                        bool anArg = JSValueRefToPrimitive<bool>(ctx, valueOfArg);
                        [invocation setArgument:&anArg atIndex:i+2];
                    }
                    
                }
                else {
                    id anArg = JSValueRefToObjCType(ctx, valueOfArg);
                    [invocation setArgument:&anArg atIndex:i+2];
                }
            }
            
            [invocation retainArguments];
            [invocation invoke];
            id result = nil;
            if (signature.methodReturnLength != 0)
                [invocation getReturnValue:&result];
            
    
//            argumentCount>0?toObject(ctx, arguments[0]):nil
//            id result = [target performSelector:NSSelectorFromString(@(info->selector.c_str())) withObject:arg1];
            
//            NSLog(@"RESULT: %@",result);
            
//            free(wrap);
            /* the way we used to use but doesnt work with self twice
            JSNRObjCObjectInfo *resultInfo = new JSNRObjCObjectInfo(result, "");
            JSObjectSetPrivate(thisObject, resultInfo);
             */
            JSObjectRef newResultObject = JSNRObjCClassObjectFromId(ctx, result);
        
            return newResultObject;
            
        }
    
    
    return JSValueMakeNull(ctx);
//    return thisObject;
    
}

JSValueRef JSNRObjCClass::JSNRObjCClassGet(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef *exception) {
    
    if (JSNR::String(propertyName).string() == "Symbol.toPrimitive") {
        return JSNR::String("string").value(ctx).valueRef;
    }
    if (JSNR::String(propertyName).string() == "toString") {
        return JSNR::String(propertyName).value(ctx).valueRef;
    }
    if (JSNR::String(propertyName).string() == "valueOf") {
        return JSNR::String(propertyName).value(ctx).valueRef;
    }
    if (JSNR::String(propertyName).string() == "toCString") {
        return JSNR::String(propertyName).value(ctx).valueRef;
    }
    string selectorstr = JSNR::String(propertyName).string();
    NSString *selectorNSString = [NSString stringWithCString:selectorstr.c_str() encoding:NSUTF8StringEncoding];
    selectorNSString = [selectorNSString stringByReplacingOccurrencesOfString:@"$" withString:@":"];
    selectorstr = string(selectorNSString.UTF8String);
    
    cout << "should invoke "+selectorstr<<endl;
    
    JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback(ctx, NULL, invokeFunction);
    
    
    JSNRObjCObjectInfo *info = static_cast<JSNRObjCObjectInfo *>(JSObjectGetPrivate(object));
    const char *sel = selectorstr.c_str();
    
    
    JSNRObjCObjectInfo *methodCallInfo = new JSNRObjCObjectInfo(info->target, sel);
    
//    free(wrap);
    
    JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
    JSObjectSetPrivate(object, methodCallInfo);
    
    return invokeFn;
}

bool JSNRObjCClassSet(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef *exception) {
    //    JSObjectSetProperty(ctx, object, propertyName, value, kJSPropertyAttributeNone, exception);
    
    string selectorstr = JSNR::String(propertyName).string();
    NSString *selectorNSString = [NSString stringWithCString:selectorstr.c_str() encoding:NSUTF8StringEncoding];
    NSString *firstLetter = [selectorNSString substringWithRange:NSMakeRange(0, 1)];
    firstLetter = [firstLetter uppercaseString];
    selectorNSString = [selectorNSString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLetter];
    selectorNSString = [NSString stringWithFormat:@"set%@:", selectorNSString];
//    selectorNSString = [selectorNSString stringByReplacingOccurrencesOfString:@"$$" withString:@":"];
    selectorstr = string(selectorNSString.UTF8String);
    
    cout << "should invoke from set "+selectorstr<<endl;
    
    JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback(ctx, NULL, invokeFunction);
    
    
    JSNRObjCObjectInfo *info = static_cast<JSNRObjCObjectInfo *>(JSObjectGetPrivate(object));
    const char *sel = selectorstr.c_str();
    
    
    JSNRObjCObjectInfo *methodCallInfo = new JSNRObjCObjectInfo(info->target, sel);
    
    //    free(wrap);
    
    JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
    JSObjectSetPrivate(object, methodCallInfo);
    JSValueRef setArguments[1]; // the set of args to be passed to the set method
    setArguments[0] = value;
    JSObjectCallAsFunction(ctx, invokeFn, object, 1, setArguments, NULL);
    
    
    return false;
}

JSValueRef JSNRObjCClassConvertToTypeCallback(JSContextRef ctx, JSObjectRef object, JSType type, JSValueRef *exception) {
    
    JSNRObjCObjectInfo *info = static_cast<JSNRObjCObjectInfo *>(JSObjectGetPrivate(object));
    
    id target = info->target;
    BOOL targetIsClass = class_isMetaClass(object_getClass(target));
    
    if (targetIsClass) {
        
        return JSNR::String(class_getName(target)).value(ctx).valueRef;
    } else {
        return JSNR::String([target description].UTF8String).value(ctx).valueRef;
        
    }
    
    return JSNR::String("unknown").value(ctx).valueRef;
}

JSObjectRef JSNRObjCClassConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception){
    
    cout << "returning class: " <<  JSNR::String(JSNR::Value(ctx, arguments[0])).string() << endl;
    
    string className = JSNR::String(JSNR::Value(ctx, arguments[0])).string();
    Class cls = objc_getClass(className.c_str());
    
    JSNRObjCObjectInfo *info = new JSNRObjCObjectInfo(cls, ""); // maybe set selector to alloc/init
    
    JSObjectSetPrivate(constructor, info);
    
    return constructor;
}

void JSNRObjCClassFinalize(JSObjectRef object) {
    JSNRObjCObjectInfo *info = static_cast<JSNRObjCObjectInfo *>(JSObjectGetPrivate(object));
    delete info;
}

JSClassRef JSNRObjCClass() {
    static JSClassRef objCClass;
    if (!objCClass) {
        JSClassDefinition definition = kJSClassDefinitionEmpty;
        definition.className = "ObjCClass";
        definition.attributes = kJSClassAttributeNone;
        definition.getProperty = JSNRObjCClass::JSNRObjCClassGet;
        definition.convertToType = JSNRObjCClassConvertToTypeCallback;
        definition.setProperty = JSNRObjCClassSet;
        definition.callAsConstructor = JSNRObjCClassConstructor;
        definition.callAsFunction = JSNRObjCClassFunction;
//        definition.initialize = JSNRObjectiveClassInitialize;
        definition.finalize = JSNRObjCClassFinalize;
        objCClass = JSClassCreate(&definition);
    }
    return objCClass;
}
