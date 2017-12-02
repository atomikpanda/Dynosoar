//
//  JSNRClasses.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/30/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRObjectiveClass.h"
#import "JavaScriptNativeRuntime.h"
#import <map>
#import <string>
#import <iostream>

typedef std::map<std::string,JSValueRef> propertyMap_t;

JSValueRef PropertyMapGetValue(propertyMap_t *map, std::string str) {
    auto pos = map->find(str);
    if (pos == map->end()) {
        //handle the error
        return NULL;
    } else {
        JSValueRef value = pos->second;
        return value;
    }
}

//JSValueRef JSNRInvokeMethod(JSContextRef ctx, JSValueRef onThis, JSValueRef method, std::vector<JSValueRef> args) {
//
//}

void JSValuePrint(
                  JSContextRef ctx,
                  JSValueRef value,
                  JSValueRef *exception)
{
    JSStringRef string = JSValueToStringCopy(ctx, value, exception);
    size_t length = JSStringGetLength(string);
    
    char *buffer = (char *)malloc(length+1);
    JSStringGetUTF8CString(string, buffer, length+1);
    if (string)
    JSStringRelease(string);
    
    puts(buffer);
    
    free(buffer);
}

NSDictionary *dictionaryForJSHash(JSObjectRef hashValue, JSContextRef ctx) {
    JSPropertyNameArrayRef names = JSObjectCopyPropertyNames(ctx, hashValue);
    NSUInteger length = JSPropertyNameArrayGetCount(names);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:length];
    JSValueRef exception = NULL;
    
    for (NSUInteger i=0; i<length; i++) {
        id obj = nil;
        JSStringRef name = JSPropertyNameArrayGetNameAtIndex(names, i);
        JSValueRef jsValue = JSObjectGetProperty(ctx, hashValue, name, &exception);
        
        if (exception != NULL) {
            return nil;
        }
        
        NSString *key = (NSString *)CFBridgingRelease(JSStringCopyCFString(kCFAllocatorDefault, name));
        [dictionary setObject:[JSValue valueWithJSValueRef:jsValue inContext:[JSNRContext sharedInstance].coreContext] forKey:key];
    }
    
    JSPropertyNameArrayRelease(names);
    
    return [dictionary copy];
}


JSValueRef JSNRObjectiveClassGet(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef *exception) {
    
    propertyMap_t *map = static_cast<propertyMap_t *>(JSObjectGetPrivate(object));
    
    JSValueRef value = PropertyMapGetValue(map, JSNR::String(propertyName).string());
    if (value)
        return value;
    
    return JSValueMakeString(ctx, propertyName);
}

bool JSNRObjectiveClassSet(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef *exception) {
//    JSObjectSetProperty(ctx, object, propertyName, value, kJSPropertyAttributeNone, exception);

    propertyMap_t *map = static_cast<propertyMap_t *>(JSObjectGetPrivate(object));
    
    map->insert(std::make_pair(JSNR::String(propertyName).string(), value));

    
    return false;
}

void JSNRObjectiveClassInitialize(JSContextRef ctx, JSObjectRef object) {
    propertyMap_t *map = new propertyMap_t();
    JSObjectSetPrivate(object, map);
}

void JSNRObjectiveClassFinalize(JSObjectRef object){
    propertyMap_t *map = static_cast<propertyMap_t *>(JSObjectGetPrivate(object));
    delete map;
}

JSObjectRef JSNRObjectiveClassConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception){
    
    return NULL;
}

JSValueRef JSNRObjectiveClassFunction(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    // this method should invoke init on the objc class
    
    for (size_t i=0; i<argumentCount; i++) {
        JSStringRef pathString = JSValueToStringCopy(ctx, arguments[i], NULL);
    }
 
    
//    JSValueRef internalClassName = JSObjectGetProperty(ctx, thisObject, JSStringCreateWithUTF8CString("internalClassName"), NULL);
//    JSValuePrint(ctx, internalClassName, NULL);
    
    propertyMap_t *map = static_cast<propertyMap_t *>(JSObjectGetPrivate(function));
    
    JSValueRef value = PropertyMapGetValue(map, "internalClassName");
    
    std::string className = JSNR::String(JSNR::Value(ctx,value)).string();
    std::cout<<"okay: "<<className <<std::endl;
    NSLog(@"dict: %@", dictionaryForJSHash(function, ctx));
    
    if (className == "JSNRContext") {
        
        JSObjectRef globalObject = JSContextGetGlobalObject(ctx);
        JSObjectRef __invoke = (JSObjectRef)JSObjectGetProperty(ctx, globalObject, JSStringCreateWithUTF8CString("__invoke"), NULL);
        JSValueRef invokeArgs[3];
        invokeArgs[0] = JSObjectMake(ctx, NULL, NSClassFromString(@(className.c_str())));
        invokeArgs[1] = JSValueMakeString(ctx, JSStringCreateWithUTF8CString("printy"));
        invokeArgs[2] = JSObjectMakeArray(ctx, argumentCount, arguments, exception);
        JSValueRef ret = JSObjectCallAsFunction(ctx, __invoke, thisObject, 3, invokeArgs, exception);
        return ret;
    }
    
    return function;
}

JSClassRef JSNRObjectiveClass(const char *className) {
    static JSClassRef objectiveClass;
    if (!objectiveClass) {
        JSClassDefinition definition = kJSClassDefinitionEmpty;
        definition.className = className;
        definition.attributes = kJSClassAttributeNone;
        definition.getProperty = JSNRObjectiveClassGet;
        definition.setProperty = JSNRObjectiveClassSet;
        definition.callAsConstructor = JSNRObjectiveClassConstructor;
        definition.callAsFunction = JSNRObjectiveClassFunction;
        definition.initialize = JSNRObjectiveClassInitialize;
        objectiveClass = JSClassCreate(&definition);
    }
    return objectiveClass;
}
