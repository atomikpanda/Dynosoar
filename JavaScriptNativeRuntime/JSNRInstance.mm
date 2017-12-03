//
//  JSNRExampleSubclass.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRInstance.h"
#import "JSNRInternal.h"
#import "JavaScriptNativeRuntime.h"
#import <iostream>
#import <objc/runtime.h>
using std::cout; using std::endl;

class Prim {
public:
    template<typename Type_, typename Type2_>
    static void* createPointer(Type2_ inVar) {
        Type_ *pointer = static_cast<Type_*>(malloc(sizeof(Type_)));
        
        *pointer = static_cast<Type_>(inVar);
        
        return reinterpret_cast<Type_ *>(pointer);
    }
    
    template<typename Type_>
    static Type_ pointerToNonPointerType(void *pointer) {
        Type_ d;
        assert(sizeof d == sizeof pointer); // <- a static assert would be even better
        memcpy(&d, &pointer, sizeof d);
        return d;
    }
    
    static void *numberToSig(double a, std::string sig) {
        void *Apointer = NULL;
        if (sig == "f")
            Apointer = Prim::createPointer<float>(a);
        else if (sig == "d")
            Apointer = createPointer<double>(a);
        else if (sig == "Q")
            Apointer = createPointer<unsigned long long>(a);
        
        return Apointer;
    }
    template<typename Type_>
    static double doubleFromPointer(void *pointer, unsigned long size) {
        void *result = malloc(size);
        result = pointer;
        
        return (double)reinterpret_cast<Type_ &>(result);
    }
    
    static void *boolToSig(bool a, std::string sig) {
        void *Apointer = NULL;
        
        if (sig == "B")
            Apointer = Prim::createPointer<bool>(a);
        
        return Apointer;
    }
    
    static void *stringToSig(JSNR::String str, std::string sig) {
        void *Apointer = NULL;
        
        if (sig == "r*"||sig=="*")
            Apointer = createPointer<char *>(const_cast<char *>(str.c_str()));
//            Apointer = const_cast<char *>(str.c_str());
        else if (sig == "c")
            Apointer = createPointer<char>([str.NSString() characterAtIndex:0]);
        
        return Apointer;
    }
};

template<typename Type_, typename Type2_>
void setArg(Type2_ expr, NSInvocation *invocation, int i) {
 Type_ anArg = static_cast<Type_>(expr);
 [invocation setArgument:&anArg atIndex:i+2];
}


template <typename Type_>
void *convert(Type_ toConvert, std::string sig) {
    if (sig == "*r") {
        return toConvert;
    } else {
        return Prim::createPointer<Type_>(toConvert);
    }
}

bool signatureTypeIsPrimitive(std::string type) {
    if (type == "@") return false;
    
    return true;
}

JSValueRef invokeFunction2(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    
    JSNR::ObjCInvokeInfo *info = static_cast<JSNR::ObjCInvokeInfo *>(JSObjectGetPrivate(thisObject));
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
            JSNR::Value val = JSNR::Value(ctx, valueOfArg);
            bool isPrimitive= JSValueRefShouldConvertToPrimitive(ctx, valueOfArg);
            std::string signatureType = [signature getArgumentTypeAtIndex:i+2];
            printf("arg at index %d is of type %s\n\n", i, [signature getArgumentTypeAtIndex:i+2]);
            printf("typeIsPrimitive:: %s\n", signatureTypeIsPrimitive([signature getArgumentTypeAtIndex:i+2]) ? "Y":"N");
//            const char a ='a';
//            [invocation setArgument:Prim::convert(a) atIndex:0];
            
            if (signatureType != "@") {
                
            #include "JSNRPrimitiveTypeHandler.mm"
                
            }
            else {
                id anArg = val.toObjCTypeObject(signatureType);
                
                [invocation setArgument:&anArg atIndex:i+2];
            }
        }
        
        NSLog(@"sig: %@", signature);
        
        [invocation retainArguments];
        [invocation invoke];
        
        if (signature.methodReturnLength != 0) {
            if (std::string(signature.methodReturnType) == "@") {
            void *result = nil;
            [invocation getReturnValue:&result];
            JSObjectRef newResultObject = JSNR::ObjCClass::instanceWithObject(ctx, (id)result);
            
            return newResultObject;
            } else {
//                result = malloc(signature.methodReturnLength);
//                unsigned long *result = (unsigned long *) malloc(sizeof(double));
//                void *result = malloc(signature.methodReturnLength);
//                [invocation getReturnValue:&result];
                
                void *result = NULL;
                [invocation getReturnValue:&result];
                
                return JSValueMakeNumber(ctx, Prim::doubleFromPointer<unsigned long>(result, signature.methodReturnLength));
            }
        }
        return JSValueMakeNull(ctx);
        
        //            argumentCount>0?toObject(ctx, arguments[0]):nil
        //            id result = [target performSelector:NSSelectorFromString(@(info->selector.c_str())) withObject:arg1];
        
        //            NSLog(@"RESULT: %@",result);
        
        //            free(wrap);
        /* the way we used to use but doesnt work with self twice
         JSNRObjCObjectInfo *resultInfo = new JSNRObjCObjectInfo(result, "");
         JSObjectSetPrivate(thisObject, resultInfo);
         */
        
        
    }
    
    
    return JSValueMakeNull(ctx);
    //    return thisObject;
    
}


namespace JSNR {
    typedef Instance thisClass;
    
    JSValueRef thisClass::getCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef *exceptionRef)
    { JSNRGetCallbackCast
        if (propertyName.string() == "Symbol.toPrimitive") {
            return String("string").value(ctx).valueRef;
        }
        if (propertyName.string() == "toString") {
            return propertyName.value(ctx).valueRef;
        }
        if (propertyName.string() == "valueOf") {
            return propertyName.value(ctx).valueRef;
        }
        if (propertyName.string() == "toCString") {
            return propertyName.value(ctx).valueRef;
        }
        
        NSString *selectorNSString = propertyName.NSString();
        selectorNSString = [selectorNSString stringByReplacingOccurrencesOfString:@"$" withString:@":"];
        String selector = String(selectorNSString);
        
        cout << "should invoke "<< selector.string() <<endl;
        
        JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback(ctx, NULL, invokeFunction2);
        
        
        ObjCInvokeInfo *invokeInfo = static_cast<ObjCInvokeInfo *>(object.getPrivate());
        invokeInfo->selector = selector.string();
//        ObjCInvokeInfo *methodCallInfo = new ObjCInvokeInfo(invokeInfo->target, selector.string());
        
        //    free(wrap);
        
//        JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
        object.setPrivate(invokeInfo);
        
        return invokeFn;
    }
    
    bool thisClass::setCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef valueRef, JSValueRef *exceptionRef)
    { JSNRSetCallbackCast
        //    JSObjectSetProperty(ctx, object, propertyName, value, kJSPropertyAttributeNone, exception);
        
        NSString *firstLetter = [propertyName.NSString() substringWithRange:NSMakeRange(0, 1)];
        firstLetter = [firstLetter uppercaseString];
        NSString *selectorNSString = [propertyName.NSString() stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLetter];
        selectorNSString = [NSString stringWithFormat:@"set%@:", selectorNSString];
        //    selectorNSString = [selectorNSString stringByReplacingOccurrencesOfString:@"$$" withString:@":"];
        String selectorString = String(selectorNSString);
        
        cout << "should invoke from set "+selectorString.string()<<endl;
        
        JSObjectRef invokeFn = JSObjectMakeFunctionWithCallback(ctx, NULL, invokeFunction2);
        
        
        ObjCInvokeInfo *info = static_cast<ObjCInvokeInfo *>(object.getPrivate());
//        const char *sel = selectorString.c_str();
        info->selector = selectorString.string();
//        JSNRObjCObjectInfo *methodCallInfo = new JSNRObjCObjectInfo(info->target, sel);
        
        //    free(wrap);
        
//        JSObjectSetPrivate(invokeFn, methodCallInfo); // appears not nessicary
        object.setPrivate(info);
        JSValueRef setArguments[1]; // the set of args to be passed to the set method
        setArguments[0] = value.valueRef;
        JSObjectCallAsFunction(ctx, invokeFn, object.objectRef, 1, setArguments, NULL);
        
        return false;
    }
    
    JSValueRef thisClass::asFunction(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef)
    { JSNRFunctionCallbackCast
        cout << "ObjCClass called as function" << endl;
        
        ObjCInvokeInfo *allocInfo = static_cast<ObjCInvokeInfo *>(function.getPrivate());
        Class thisClass = allocInfo->target;
        cout << "looks like: " << class_getName(thisClass) << endl;
        
        //    free(wrap);
        id firstObject = [[thisClass alloc] init];
        ObjCInvokeInfo *invokeInfo = new ObjCInvokeInfo(firstObject, "");
        
        function.setPrivate(invokeInfo);
        
        return function.valueRef;
    }
    
    JSObjectRef thisClass::asConstructor(JSContextRef ctx, JSObjectRef constructorRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exception)
    { JSNRConstructorCallbackCast
        
        String className = String(Value(ctx, argumentRefs[0]));
        cout << "returning class: " <<  className.string() << endl;
        
        Class cls = objc_getClass(className.c_str());
        ObjCInvokeInfo *allocInfo = new ObjCInvokeInfo(cls, "", true);
        
//        JSNRObjCObjectInfo *info = new JSNRObjCObjectInfo(cls, ""); // maybe set selector to alloc/init
        constructor.setPrivate(allocInfo);
        
        return constructor.objectRef;
    }
    
    void thisClass::finalize(JSObjectRef objectRef)
    { JSNRFinalizeCallbackCast
        ObjCInvokeInfo *info = static_cast<ObjCInvokeInfo *>(object.getPrivate());
        delete info;
    }
    
    JSValueRef thisClass::convertToType(JSContextRef ctx, JSObjectRef objectRef, JSType type, JSValueRef *exceptionRef)
    { JSNRConvertToTypeCallbackCast
        
        ObjCInvokeInfo *info = static_cast<ObjCInvokeInfo *>(object.getPrivate());
        
        id target = info->target;
        BOOL targetIsClass = class_isMetaClass(object_getClass(target));
        
        if (targetIsClass) {
            
            return String(class_getName(target)).value(ctx).valueRef;
        } else {
            // need to store void *target not id target and access return
//            return JSValueMakeNumber(ctx, 100);
            return String([target description]).value(ctx).valueRef;
            
        }
        
        return String("unknown").value(ctx).valueRef;
    }
//    static bool setCallback(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef valueRef, JSValueRef *exceptionRef);
    
    JSClassRef ObjCClass::classRef() {
        static JSClassRef ref;
        
        if (!ref) {
            JSClassDefinition classDef = kJSClassDefinitionEmpty;
            
            classDef.className = "Instance";
            classDef.attributes = kJSClassAttributeNone;
            classDef.parentClass = BaseClass::classRef();
            
            classDef.getProperty = thisClass::getCallback;
            classDef.setProperty = thisClass::setCallback;
            classDef.convertToType = thisClass::convertToType;
            classDef.callAsFunction = thisClass::asFunction;
            classDef.callAsConstructor = thisClass::asConstructor;
            classDef.finalize = thisClass::finalize;
            
            ref = JSClassCreate(&classDef);
        }
        
        return ref;
    }
    
    JSObjectRef thisClass::instanceWithObject( JSContextRef ctx, id objcObject) {
        JSClassRef cls = JSNR::ObjCClass::classRef();
        JSNR::Value selfObj = JSNR::Value(ctx, JSObjectMake(ctx, cls, NULL));
        JSNR::ObjCInvokeInfo *invokeInfo = new JSNR::ObjCInvokeInfo(objcObject, "");
        selfObj.setPrivate(invokeInfo);
        return selfObj.objectRef;
    }
  
    // Invoke
    ObjCInvokeInfo::ObjCInvokeInfo(id target, std::string selector, bool targetIsClass) {
        this->target = target;
        this->selector = selector;
        this->targetIsClass = targetIsClass;
    }
    
}
