//
//  JSNRInvoke.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/3/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#include "JSNRInvoke.h"
#import "JavaScriptNativeRuntime.h"
#import <string>
#import <objc/runtime.h>
#import <iostream>
#import "JSNRSigType.hpp"

using std::cout; using std::endl;





class Prim {
public:


    template<typename Type_>
    static Type_ pointerToNonPointerType(void *pointer) {
        Type_ d;
        assert(sizeof d == sizeof pointer); // <- a static assert would be even better
        memcpy(&d, &pointer, sizeof d);
        return d;
    }

    template<typename Type_>
    static double doubleFromPointer(void *pointer, unsigned long size) {
        void *result = malloc(size);
        result = pointer;

        return (double)reinterpret_cast<Type_ &>(result);
    }

    template<typename Type_>
    static bool boolFromPointer(void *pointer, unsigned long size) {
        void *result = malloc(size);
        result = pointer;

        return (bool)reinterpret_cast<Type_ &>(result);
    }


};
//
//template<typename Type_, typename Type2_>
//void setArg(Type2_ expr, NSInvocation *invocation, int i) {
//    Type_ anArg = static_cast<Type_>(expr);
//    [invocation setArgument:&anArg atIndex:i+2];
//}



namespace JSNR {
    
    void replaceAll(std::string& source, const std::string& from, const std::string& to) {
        std::string newString;
        newString.reserve(source.length());  // avoids a few memory allocations
        
        std::string::size_type lastPos = 0;
        std::string::size_type findPos;
        
        while(std::string::npos != (findPos = source.find(from, lastPos)))
        {
            newString.append(source, lastPos, findPos - lastPos);
            newString += to;
            lastPos = findPos + from.length();
        }
        
        // Care for the rest after last occurrence
        newString += source.substr(lastPos);
        
        source.swap(newString);
    }
    
    std::string Invoke::parseSetSelector(std::string propertyName) {
        using std::string;
        
        char firstLetter = propertyName.substr(0,1).c_str()[0];
        firstLetter = toupper(firstLetter);
        
        string selector = "set"+propertyName.replace(0, 1, string(1,firstLetter))+":";
        
        return selector;
    }
    
    std::string Invoke::parseGetSelector(std::string propertyName) {
        using std::string;
        
        string selector = propertyName;
        replaceAll(selector, "$", ":");
        
        return selector;
    }
    
    JSValueRef Invoke::invokeFunction(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef* exceptionRef)
    { JSNRFunctionCallbackCast
        
        InvokeInfo *info = static_cast<InvokeInfo *>(thisObject.getPrivate());
        id target = info->target;
        BOOL targetIsClass = info->targetIsClass;//class_isMetaClass(object_getClass(target));
        
        if (info->selector.length() > 0) {
            if (targetIsClass)
                cout << "invoke " << info->selector << " on class " << class_getName(target) << endl;
            else
                cout << "invoke " << info->selector << " on object of class " << object_getClassName(target) << endl;
            
                        if (argumentCount > 0) {
                            JSValueRef firstArg = argumentRefs[0];
                            id firstArgId = Value(ctx, firstArg).toObject();
                            NSLog(@"argument: %@", firstArgId);
                            
                        }
            NSString *method = @(info->selector.c_str());
            NSUInteger numberOfArgs = [method componentsSeparatedByString:@":"].count;
            if ([method rangeOfString:@":"].location == NSNotFound) numberOfArgs = 0;
            if (numberOfArgs != argumentCount) {
                method = [method stringByReplacingOccurrencesOfString:@"$" withString:@":"];
            }
            //            NSLog(@"meth: %@,%@,%@", thisObject, method, arguments);
            NSLog(@"invokMethod: %@", method);
            NSMethodSignature *signature;
            if (targetIsClass) {
                // get signature from class method
                if (![target respondsToSelector:NSSelectorFromString(method)]) return nil;
                
                signature = [target methodSignatureForSelector:NSSelectorFromString(method)];
            } else {
                // get signature from instance method
                if (![target respondsToSelector:NSSelectorFromString(method)]) return nil;
                
                signature = [[target class] instanceMethodSignatureForSelector:NSSelectorFromString(method)];
            }
            
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            [invocation setTarget:target];
            [invocation setSelector:NSSelectorFromString(method)];
            
            for (int i=0; i < argumentCount; i++) {
                JSValueRef valueOfArg = argumentRefs[i];
                Value val = Value(ctx, valueOfArg);
                
                std::string signatureType = [signature getArgumentTypeAtIndex:i+2];
                printf("arg at index %d is of type %s\n\n", i, [signature getArgumentTypeAtIndex:i+2]);
                

                SigType sigInfo = SigType(signatureType);
                void *ptr = val.toSignatureTypePointer(sigInfo);
                [invocation setArgument:ptr atIndex:i+2];

            }
            
            // good for debugging crashes in invoke due to types
//            if ([method isEqualToString:@"makePurple:"]) {
//                void *arg1 = NULL;
//                [invocation getArgument:&arg1 atIndex:0+2];
//                
//                [target makePurple:arg1];
//                return NULL;
//            }
            
            [invocation retainArguments];
            [invocation invoke];
            
            // *** NOTE THIS RETURN TYPE PARSING IS HACKED TOGETHER
            if (signature.methodReturnLength != 0) {
                cout << "method returns type "+std::string(signature.methodReturnType)<<endl;
                
                if (std::string(signature.methodReturnType) == "@") {
                    void *result = nil;
                    [invocation getReturnValue:&result];
                    JSObjectRef newResultObject = Instance::instanceWithObject(ctx, (id)result);
                    
                    return newResultObject;
                } else {
                    //                result = malloc(signature.methodReturnLength);
                    //                unsigned long *result = (unsigned long *) malloc(sizeof(double));
                    //                void *result = malloc(signature.methodReturnLength);
                    //                [invocation getReturnValue:&result];
                    if (std::string(signature.methodReturnType) == "B"||std::string(signature.methodReturnType) == "c") {
                        void *result = NULL;
                        [invocation getReturnValue:&result];
                        
                        
                        return JSValueMakeBoolean(ctx, Prim::boolFromPointer<char>(result, signature.methodReturnLength));
                    } else {
                        void *result = NULL;
                        [invocation getReturnValue:&result];
                        
                        return JSValueMakeNumber(ctx, Prim::doubleFromPointer<unsigned long>(result, signature.methodReturnLength));
                    }
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
    
    // InvokeInfo
    InvokeInfo::InvokeInfo(id target, std::string selector, bool targetIsClass) {
        this->target = target;
        this->selector = selector;
        this->targetIsClass = targetIsClass;
    }
}
