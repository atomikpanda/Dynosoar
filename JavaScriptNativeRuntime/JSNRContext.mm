//
//  JSNRContext.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/29/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRContext.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <AppKit/AppKit.h>
#import "JavaScriptNativeRuntime.h"
#import "JSNRObjectiveClass.h"
#import "JSNRClassMap.h"

@implementation JSNRContext
@synthesize coreContext, scriptContents, allMaps;

+ (instancetype)sharedInstance
{
    static JSNRContext *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[JSNRContext alloc] init] autorelease];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}
+(void)printy {
    NSLog(@"PRINTY has been called");
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.coreContext = [JSContext new];
        self.allMaps = [NSMutableDictionary dictionary];
        [self.coreContext setExceptionHandler:^(JSContext *ctx, JSValue  *exception){
            NSLog(@"exception: %@", exception);
        }];
        
        [self insertNativeBridge];
        [self createClassWithName:@"Filesystem"];
        [self createClassWithName:@"NSBundle"];
        [self createClassWithName:@"JSNRContext"];
        
        JSGlobalContextRef ctx = self.coreContext.JSGlobalContextRef;
        JSObjectRef globalObject = JSContextGetGlobalObject(ctx);
        
//        JSObjectRef objCClass = JSObjectMake(ctx, JSNRObjCClass(), NULL);
//        JSObjectSetProperty(ctx, globalObject, JSStringCreateWithUTF8CString("ObjCClass"), objCClass, kJSPropertyAttributeNone, NULL);
        
        JSClassRef base = JSNR::BaseClass::classRef();
        
        JSObjectRef baseCls = JSObjectMake(ctx, base, NULL);
        JSObjectSetProperty(ctx, globalObject, JSStringCreateWithUTF8CString("Base"), baseCls, kJSPropertyAttributeNone, NULL);
        
        JSClassRef subclass = JSNR::ObjCClass::classRef();
        
        JSObjectRef baseSubCls = JSObjectMake(ctx, subclass, NULL);
        JSObjectSetProperty(ctx, globalObject, JSStringCreateWithUTF8CString("ObjCClass"), baseSubCls, kJSPropertyAttributeNone, NULL);
        
    }
    
    return self;
}

- (void)createClassWithName:(NSString *)classNameNS {
    const char *className = [classNameNS UTF8String];
    
    JSGlobalContextRef ctx = self.coreContext.JSGlobalContextRef;
    JSObjectRef globalObject = JSContextGetGlobalObject(ctx);

    JSObjectRef filesystemObject = JSObjectMake(ctx, JSNRObjectiveClass(className), NULL);
    JSObjectSetProperty(ctx, globalObject, JSStringCreateWithUTF8CString(className), filesystemObject, kJSPropertyAttributeNone, NULL);
    JSValueRef internalClassName = JSValueMakeString(ctx, JSStringCreateWithUTF8CString(className));
    JSStringRef propertyName = JSStringCreateWithUTF8CString("internalClassName");
    JSStringRetain(propertyName);
    JSObjectSetProperty(ctx, filesystemObject, propertyName, internalClassName, kJSPropertyAttributeNone, NULL);
    
}

- (NSObject *)one:(id)o1 two:(id)o2 three:(id)o3 four:(id)o4 five:(id)o5 six:(id)o6 seven:(id)o7 eight:(id)o8 nine:(id)o9 ten:(id)o10 {
    NSLog(@"WAS CALLED@!!!");
    
//    [[self window] setBackgroundColor:[NSColor greenColor]];
    JSNRClassMap *map = [self.class _JSNRClassMap];
    NSString *selectorString = NSStringFromSelector(_cmd);
    NSUInteger numberOfArgs = [selectorString componentsSeparatedByString:@":"].count;
    if ([selectorString rangeOfString:@":"].location == NSNotFound) numberOfArgs = 0;
    
    JSValue *newFn = [map.map objectForKey:selectorString];
    NSMutableArray *actualArgs = [NSMutableArray array];
    if (numberOfArgs > 0) {
        if (o1 && numberOfArgs >= 1) [actualArgs addObject:o1];
        if (o2 && numberOfArgs >= 2) [actualArgs addObject:o2];
        if (o3 && numberOfArgs >= 3) [actualArgs addObject:o3];
        if (o4 && numberOfArgs >= 4) [actualArgs addObject:o4];
        if (o5 && numberOfArgs >= 5) [actualArgs addObject:o5];
        if (o6 && numberOfArgs >= 6) [actualArgs addObject:o6];
        if (o7 && numberOfArgs >= 7) [actualArgs addObject:o7];
        if (o8 && numberOfArgs >= 8) [actualArgs addObject:o8];
        if (o9 && numberOfArgs >= 9) [actualArgs addObject:o9];
        if (o10 && numberOfArgs >= 10) [actualArgs addObject:o10];
    }
    JSContextRef ctx = [JSNRContext sharedInstance].coreContext.JSGlobalContextRef;
    
//    JSObjectRef selfObj; //= JSNRObjCClassObjectFromId(ctx, self);
    JSObjectRef selfObj = JSNR::ObjCClass::instanceWithObject(ctx, self);
//    JSNRObjCObjectInfo *selfInfo = new JSNRObjCObjectInfo(self, "");
//    JSObjectSetPrivate(selfObj, selfInfo);
//    JSValueRef objConstArgs[1];
//    objConstArgs[0] =
//    JSObjectCallAsConstructor(ctx, obj, 1, <#const JSValueRef *arguments#>, <#JSValueRef *exception#>)
    [actualArgs insertObject:[JSValue valueWithJSValueRef:selfObj inContext:[JSNRContext sharedInstance].coreContext] atIndex:0];
//    [actualArgs insertObject:self atIndex:0];
    [actualArgs insertObject:selectorString atIndex:1];
    
    
    
    JSValue *returnVal = [newFn callWithArguments:actualArgs];
    if (returnVal && !returnVal.isUndefined && !returnVal.isNull) {
        JSObjectRef obj;
        void *ptr = NULL;
        NSString *strstr = [returnVal[@"addr"] toString];
        const char *str = strstr.UTF8String;
    
        scanf(str,"%p",&ptr);
        
//        return ptr;
//        void *nscolor = JSObjectGetPrivate(returnVal.JSValueRef);
        
//        return (NSColor *)nscolor;
        
//        JSPropertyNameArrayRef arr = JSObjectCopyPropertyNames([JSNRContext sharedInstance].coreContext.JSGlobalContextRef, returnVal.JSValueRef);
//        NSUInteger length = JSPropertyNameArrayGetCount(arr);
//        for (NSUInteger i=0; i<length; i++) {
//            JSStringRef name = JSPropertyNameArrayGetNameAtIndex(arr, i);
//            NSString *nsname = (NSString *)CFBridgingRelease(JSStringCopyCFString(kCFAllocatorDefault, name));
//            NSLog(@"%@", nsname);
//
//        }
        
        return returnVal.toObject;
    }
    
    return nil;
}

- (void)insertNativeBridge {
    [self.coreContext.globalObject setValue:self forProperty:@"__self"];
    #define __self ((JSNRContext *)([[JSContext currentContext][@"__self"] toObject]))
    
    self.coreContext[@"console"][@"log"] = ^(JSValue *str){
        if (str.isNumber) {
            printf("%s\n", str.toString.UTF8String); return;
        }
        if (str.isString)
            printf("%s\n", str.toString.UTF8String);
        else if (str.isObject)
            printf("%s\n", [((NSObject *)[str toObject]) description].UTF8String);
    };
    
    self.coreContext[@"cls"] = ^JSValue *(NSString *name) {
        if (!name) return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
        
        return [JSValue valueWithObject:objc_getClass(name.UTF8String) inContext:[JSContext currentContext]];
    };
    
    self.coreContext[@"include"] = ^JSValue *(NSString *file) {
        NSError *error = nil;
        
        NSString *scriptContents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
        if (error) NSLog(@"include() script contents err: %@", error);
        if (scriptContents)
            return [[JSContext currentContext] evaluateScript:scriptContents];
        else
            return [JSValue valueWithNullInContext:[JSContext currentContext]];
    };
    
    self.coreContext[@"interface"] = ^JSValue *(NSString *className, NSString *aliasName) {
        JSContextRef ctx = [JSContext currentContext].JSGlobalContextRef;
        JSObjectRef globalObject = (JSObjectRef)[JSContext currentContext].globalObject.JSValueRef;
        JSObjectRef classObject = JSNR::ObjCClass::instanceWithObject(ctx, nil);
        JSValueRef arguments[1];
        
        JSStringRef classNameJSString = JSNR::String(className.UTF8String).JSStringRef();
        JSStringRef aliasNameJSString = nullptr;
        BOOL usesAliasName = NO;
        if (aliasName != nil && ![aliasName isEqualToString:@"undefined"]) {
            usesAliasName = YES;
            aliasNameJSString = JSNR::String(aliasName.UTF8String).JSStringRef();
        }
        
        arguments[0] = JSValueMakeString(ctx, classNameJSString);
        // this should now be equivilent to new ObjCClass("className")
        JSStringRef classNameAsCanBeReferencedInJS = usesAliasName ? aliasNameJSString : classNameJSString;
        JSObjectRef classObjectInJS = JSObjectCallAsConstructor(ctx, classObject, 1, arguments, NULL);
        JSObjectSetProperty(ctx, globalObject, classNameAsCanBeReferencedInJS, classObjectInJS, kJSPropertyAttributeNone, NULL);
        
        return [JSValue valueWithJSValueRef:classObjectInJS inContext:[JSContext currentContext]];
    };
    
    self.coreContext[@"hook"] = ^(JSValue *classObjCObject, NSString *selectorString, JSValue *newFn) {
        JSObjectRef objCObjectRef = (JSObjectRef)classObjCObject.JSValueRef;
        JSNR::ObjCInvokeInfo *info = static_cast<JSNR::ObjCInvokeInfo *>(JSObjectGetPrivate(objCObjectRef));
        Class classToBeHooked = info->target;
        
        SEL selector = NSSelectorFromString(selectorString);
        Method method = class_getInstanceMethod(classToBeHooked, selector);
        Method methodWow = class_getInstanceMethod(__self.class, NSSelectorFromString(@"one:two:three:four:five:six:seven:eight:nine:ten:"));
        
        IMP origIMP = method_getImplementation(method);
//        [JSContext currentContext][@"origIMP"] = [JSValue valueWithObject:(id)origIMP inContext:[JSContext currentContext]];
        
        IMP wowIMP = method_getImplementation(methodWow);
        method_setImplementation(method, wowIMP);
        
        if ([__self.allMaps.allKeys indexOfObject:NSStringFromClass(classToBeHooked)] == NSNotFound)
            [__self.allMaps setObject:[JSNRClassMap classMap] forKey:NSStringFromClass(classToBeHooked)];
        
        JSNRClassMap *clsMap = [__self.allMaps objectForKey:NSStringFromClass(classToBeHooked)];
        [clsMap.map setObject:newFn forKey:selectorString];
    };
    
    self.coreContext[@"__invoke"] = ^NSObject *( JSValue *onThis, NSString *method, NSArray *args){
        NSUInteger numberOfArgs = [method componentsSeparatedByString:@":"].count;
        if ([method rangeOfString:@":"].location == NSNotFound) numberOfArgs = 0;
        if (numberOfArgs != args.count) {
            method = [method stringByReplacingOccurrencesOfString:@"$$" withString:@":"];
        }
        NSLog(@"meth: %@,%@,%@", onThis, method, args);
        
        NSMethodSignature *signature;
//        if (isClassMethod) {
        id target = nil;
        if (onThis.isNull || onThis.isUndefined || !onThis.isObject) {
            target = nil;
        } else {
            target = [onThis toObject];
        }
        if (!target) return nil;
        
        if (![[target class] instancesRespondToSelector:NSSelectorFromString(method)]) {
            signature = [target methodSignatureForSelector:NSSelectorFromString(method)];
            target = [target class];
        }else
//        if () {
//
//        }
        
//        } else {
        {
            if (![target respondsToSelector:NSSelectorFromString(method)]) return nil;
            
            signature = [[target class] instanceMethodSignatureForSelector:NSSelectorFromString(method)];
            
        }
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        [invocation setTarget:target];
        [invocation setSelector:NSSelectorFromString(method)];
        for (int i=0; i < args.count; i++) {
            NSObject *anArg = [args objectAtIndex:i];
            
            [invocation setArgument:&anArg atIndex:i+2];
        }
        [invocation retainArguments];
        [invocation invoke];
//        NSLog(@"args: %@",args);
        
        id ret = nil;
        if (signature.methodReturnLength != 0)
            [invocation getReturnValue:&ret];
        JSValue *val = [JSValue valueWithObject:ret inContext:[JSContext currentContext]];
        if (val.isObject) {
            JSObjectRef obj = (JSObjectRef)val.JSValueRef;
            char str[16+1];
            sprintf(str,"%p",ret);
            val[@"addr"] = @(str);
        }
        return val;
    };
    
    self.coreContext[@"orig"] = ^JSValue *() {
        NSArray *arguments = [JSContext currentArguments];
        JSValue *invoke = [JSContext currentContext][@"__invoke"];
        NSMutableArray *justArgs = [NSMutableArray arrayWithArray:arguments];
        [justArgs removeObjectAtIndex:0];
        [justArgs removeObjectAtIndex:0];
        
        return [invoke callWithArguments:@[arguments[0],arguments[1],justArgs]];
    };
}

- (JSValue *)evaluateScript:(NSString *)contents {
    self.scriptContents = contents;
    return [self.coreContext evaluateScript:self.scriptContents];
}

- (JSNRClassMap *)mapForClass:(Class)cls {
    
    return [self.allMaps objectForKey:NSStringFromClass(cls)];
}

- (void)dealloc {
    self.coreContext = nil;
    self.scriptContents = nil;
    self.allMaps = nil;
    
    [super dealloc];
}

@end
