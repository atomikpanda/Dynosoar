//
//  JSNRContextManager.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/29/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRContextManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#else
#import <AppKit/AppKit.h>
#endif
#import "JavaScriptNativeRuntime.h"
#import "JSNRClassMap.h"
#import "JSNRInstance.h"
#import "JSNRInvoke.h"
#import "JSNRSigType.hpp"
#import "JSNRDelegateClass.h"
#import "JSNRSuperClass.h"
#import "JSNRInstanceClass.h"
#import "JSNRObjCClassClass.h"
#import "JSNRInvokeInfo.h"

@implementation JSNRContextManager
@synthesize coreContext, scriptContents, allMaps, baseDirectoryPath;

+ (instancetype)sharedInstance
{
    static JSNRContextManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[JSNRContextManager alloc] init] autorelease];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}
+ (void)printy {
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
        
        JSGlobalContextRef ctx = self.coreContext.JSGlobalContextRef;
        JSObjectRef globalObject = JSContextGetGlobalObject(ctx);
        
//        JSObjectRef objCClass = JSObjectMake(ctx, JSNRObjCClass(), NULL);
//        JSObjectSetProperty(ctx, globalObject, JSStringCreateWithUTF8CString("ObjCClass"), objCClass, kJSPropertyAttributeNone, NULL);
        
//        JSClassRef base = JSNR::BaseClass::classRef();
//        
//        JSObjectRef baseCls = JSObjectMake(ctx, base, NULL);
//        JSObjectSetProperty(ctx, globalObject, JSStringCreateWithUTF8CString("Base"), baseCls, kJSPropertyAttributeNone, NULL);
        
//        JSClassRef ObjCClassRef = JSNR::ObjCClass::classRef();
//
//        JSObjectRef ObjCClassObject = JSObjectMake(ctx, ObjCClassRef, NULL);
//        JSObjectSetProperty(ctx, globalObject, JSStringCreateWithUTF8CString("ObjCClass"), ObjCClassObject, kJSPropertyAttributeNone, NULL);
        
//        JSClassRef InstanceClassRef = JSNR::Instance::classRef();
//
//        JSObjectRef InstanceClassObject = JSObjectMake(ctx, InstanceClassRef, NULL);
//        JSObjectSetProperty(ctx, globalObject, JSStringCreateWithUTF8CString("Instance"), InstanceClassObject, kJSPropertyAttributeNone, NULL);
        
        JSNRObjCClassClass *objcClassClass = [JSNRObjCClassClass sharedReference];
        [self insertJSClass:objcClassClass];
        
        JSNRInstanceClass *instanceClass = [JSNRInstanceClass sharedReference];
        [self insertJSClass:instanceClass];
        
        JSNRDelegateClass *delegateClass = [JSNRDelegateClass sharedReference];
        [self insertJSClass:delegateClass];
//        JSClassRef DelegateClassRef = JSNR::DelegateClass::classRef();
//
//        JSObjectRef DelegateClassObject = JSObjectMake(ctx, DelegateClassRef, NULL);
//        JSObjectSetProperty(ctx, globalObject, JSStringCreateWithUTF8CString("Delegate"), DelegateClassObject, kJSPropertyAttributeNone, NULL);
        
//        JSNRSuperClass *baseClass = [JSNRSuperClass sharedReference];
//        [self insertJSClass:baseClass];
    }
    
    return self;
}

- (void)insertJSClass:(JSNRSuperClass *)cls {
    JSValue *object = [JSNRSuperClass createEmptyObjectWithContext:self.coreContext classRef:cls];
    [self.coreContext.globalObject setValue:object forProperty:[[cls class] JSClassName]];
}

- (void *)one:(id)o1 two:(id)o2 three:(id)o3 four:(id)o4 five:(id)o5 six:(id)o6 seven:(id)o7 eight:(id)o8 nine:(id)o9 ten:(id)o10 {
    
    NSLog(@"JSNR is calling a javascript hooks new method");
    
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
    JSContextRef ctx = [JSNRContextManager sharedInstance].coreContext.JSGlobalContextRef;
    JSValue *selfObj = [JSNRSuperClass createEmptyObjectWithContext:[JSNRContextManager sharedInstance].coreContext classRef:[JSNRInstanceClass sharedReference]];
    JSNRContainer *container = selfObj.container;
    container.info = [JSNRInvokeInfo infoWithTarget:self selector:nil isClass:NO];
//    JSObjectRef selfObj = [[JSNRInstanceClass sharedReference] createObjectRefWithContext:ctx info:[JSNRInvokeInfo infoWithTarget:self selector:nil isClass:NO]]; //JSNR::Instance::instanceWithObject(ctx, self);
    // call the js function with self
    [actualArgs insertObject:selfObj atIndex:0];
    // call the js function with _cmd
    [actualArgs insertObject:selectorString atIndex:1];
    
    
    JSValue *returnVal = [newFn callWithArguments:actualArgs];
    if (!returnVal) return nil;
    
    JSNR::Value val = JSNR::Value(ctx, returnVal.JSValueRef);
    
    
    // return type info
    NSMethodSignature *signature = [self methodSignatureForSelector:_cmd];
    
    if (signature.methodReturnLength > 0) {
        const char *returnType = signature.methodReturnType;
        JSNR::SigType sigInfo = JSNR::SigType(returnType);
    
        return *reinterpret_cast<void **>(val.toSignatureTypePointer(sigInfo));
    }
    
    
    return nil;
}

- (void)insertNativeBridge {
    [self.coreContext.globalObject setValue:self forProperty:@"__self__"];
    #define __self ((JSNRContextManager *)([[JSContext currentContext][@"__self__"] toObject]))
    
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
        NSString *headersFolderInFramework = [[NSBundle bundleForClass:[JSNRContextManager class]].resourcePath stringByAppendingString:@"/JSHeaders/"];
        
        file = [file stringByReplacingOccurrencesOfString:@"@JSHeaders/" withString:headersFolderInFramework];
        
        if (self.baseDirectoryPath) {
        if (file.pathComponents.count == 1 || [file containsString:@"./"]) {
            file = [file stringByReplacingOccurrencesOfString:@"./" withString:self.baseDirectoryPath];
            if (file.pathComponents.count == 1 && ![file hasPrefix:@"/"]) {
                file = [self.baseDirectoryPath stringByAppendingPathComponent:file];
            }
        }
        }
        
        
        NSString *scriptContents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
        if (error) NSLog(@"include() script contents err: %@", error);
        if (scriptContents)
            return [[JSContext currentContext] evaluateScript:scriptContents];
        else
            return [JSValue valueWithNullInContext:[JSContext currentContext]];
    };
    
    self.coreContext[@"interface"] = ^JSValue *(NSString *className, NSString *aliasName) {
        // here we pass the className string to the ObjCClass constructor
//        JSContextRef ctx = [JSContext currentContext].JSGlobalContextRef;
//        JSObjectRef globalObject = (JSObjectRef)[JSContext currentContext].globalObject.JSValueRef;
        JSNRObjCClassClass *classClass = [JSNRObjCClassClass sharedReference];
        JSValue *classObject = [JSNRSuperClass createEmptyObjectWithContext:[JSContext currentContext] classRef:classClass];// JSNR::ObjCClass::instanceWithObjCClass(ctx, nil);
     
        
        BOOL usesAliasName = NO;
        if (aliasName != nil && ![aliasName isEqualToString:@"undefined"]) {
            usesAliasName = YES;
        }
        
        
        NSString *classNameAsCanBeReferencedInJS = usesAliasName ? aliasName : className;
        
        JSValue *objcClassObject = [classObject constructWithArguments:@[classNameAsCanBeReferencedInJS]];
        // this should now be equivilent to new ObjCClass("className")
        
        [[JSContext currentContext].globalObject setValue:objcClassObject forProperty:classNameAsCanBeReferencedInJS];
        
        return objcClassObject;
    };
    
    self.coreContext[@"hook"] = ^(JSValue *classObjCObject, NSString *selectorString, JSValue *newFn) {
//        JSObjectRef objCObjectRef = (JSObjectRef)classObjCObject.JSValueRef;
        JSNRContainer *container = (id)classObjCObject.privateData;
        
        JSNRInvokeInfo *info = container.info;
        Class classToBeHooked = info.target;
        
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
    
    self.coreContext[@"orig"] = ^JSValue *() {
        NSArray *arguments = [JSContext currentArguments];
        JSValue *invoke = [JSContext currentContext][@"__invoke"];
        NSMutableArray *justArgs = [NSMutableArray arrayWithArray:arguments];
        [justArgs removeObjectAtIndex:0];
        [justArgs removeObjectAtIndex:0];
        
        return [invoke callWithArguments:@[arguments[0],arguments[1],justArgs]];
    };
}

- (JSValue *)evaluateScript:(NSString *)contents baseDirectoryPath:(NSString *)baseDirectory {
    self.scriptContents = contents;
    self.baseDirectoryPath = baseDirectory;
    return [self.coreContext evaluateScript:self.scriptContents];
}

- (JSNRClassMap *)mapForClass:(Class)cls {
    
    return [self.allMaps objectForKey:NSStringFromClass(cls)];
}

- (void)dealloc {
    self.coreContext = nil;
    self.scriptContents = nil;
    self.allMaps = nil;
    self.baseDirectoryPath = nil;
    
    [super dealloc];
}

@end
