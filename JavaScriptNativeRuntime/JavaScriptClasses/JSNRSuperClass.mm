//
//  JSNRSuperClass.m
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/7/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRSuperClass.h"
#import "JSNRValue.h"

void JSNRObjectInitializeCallbackWrap(JSContextRef ctx, JSObjectRef objectRef) {
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *object = [JSValue valueWithJSValueRef:objectRef inContext:context];
    JSNRContainer *container = (id)[object privateData];
    
    [container.JSNRClass initializeWithObject:object inContext:context];
}

void JSNRObjectFinalizeCallbackWrap(JSObjectRef objectRef) {
    JSValue *object = [JSValue valueWithJSValueRef:objectRef inContext:nil];
    JSNRContainer *container = (id)[object privateData];
    [container.JSNRClass finalizeWithObject:object];
}

bool JSNRObjectHasPropertyCallbackWrap(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef) {
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *object = [JSValue valueWithJSValueRef:objectRef inContext:context];
    NSString *propertyName = [NSString stringWithJSStringRef:propertyNameRef];
    JSNRContainer *container = (id)[object privateData];
    
    BOOL result = [container.JSNRClass object:object hasPropertyWithName:propertyName inContext:context];
    
    return (bool)result;
}

JSValueRef JSNRObjectGetPropertyCallbackWrap(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef *exceptionRef) {
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *object = [JSValue valueWithJSValueRef:objectRef inContext:context];
    NSString *propertyName = [NSString stringWithJSStringRef:propertyNameRef];
    JSNRContainer *container = (id)[object privateData];
    
    JSValue *val = [container.JSNRClass getPropertyWithName:propertyName fromObject:object inContext:context];
    
    return val.JSValueRef;
}

bool JSNRObjectSetPropertyCallbackWrap(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef valueRef, JSValueRef *exception) {
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *object = [JSValue valueWithJSValueRef:objectRef inContext:context];
    NSString *propertyName = [NSString stringWithJSStringRef:propertyNameRef];
    JSValue *value = [JSValue valueWithJSValueRef:valueRef inContext:context];
    JSNRContainer *container = (id)[object privateData];
    
    BOOL result = [container.JSNRClass setPropertyWithName:propertyName onObject:object value:value inContext:context];
    return (bool)result;
}

bool JSNRObjectDeletePropertyCallbackWrap(JSContextRef ctx, JSObjectRef objectRef, JSStringRef propertyNameRef, JSValueRef *exception) {
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *object = [JSValue valueWithJSValueRef:objectRef inContext:context];
    NSString *propertyName = [NSString stringWithJSStringRef:propertyNameRef];
    JSNRContainer *container = (id)[object privateData];
    
    BOOL result = [container.JSNRClass deletePropertyWithName:propertyName onObject:object inContext:context];
    return (bool)result;
}

JSValueRef JSNRObjectCallAsFunctionCallbackWrap(JSContextRef ctx, JSObjectRef functionRef, JSObjectRef thisObjectRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef *exception)
{
    
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *function = [JSValue valueWithJSValueRef:functionRef inContext:context];
    JSValue *thisObject = [JSValue valueWithJSValueRef:thisObjectRef inContext:context];
    JSNRContainer *container = (id)[function container];
    
    JSValue *result = [container.JSNRClass calledAsFunction:function thisObject:thisObject argumentCount:argumentCount argumentRefs:argumentRefs inContext:context];
    
    return result.JSValueRef;
}

JSObjectRef JSNRObjectCallAsConstructorCallbackWrap(JSContextRef ctx, JSObjectRef constructorRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef *exception)
{
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *constructor = [JSValue valueWithJSValueRef:constructorRef inContext:context];
    
    JSNRContainer *container = constructor.container;
    
//    if (![container.JSNRClass respondsToSelector:@selector(calledAsConstructor:argumentCount:argumentRefs:inContext:)])
//        return (JSObjectRef)[JSValue valueWithNullInContext:context].JSValueRef;
    
    JSValue *result = [container.JSNRClass calledAsConstructor:constructor argumentCount:argumentCount argumentRefs:argumentRefs inContext:context];
    
    return (JSObjectRef)result.JSValueRef;
}

JSValueRef JSNRConvertToTypeWrap(JSContextRef ctx, JSObjectRef objectRef, JSType type, JSValueRef *exception) {
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *object = [JSValue valueWithJSValueRef:objectRef inContext:context];
    JSNRContainer *container = (id)[object privateData];
    
    JSValue *result = [container.JSNRClass convertObject:object toType:type inContext:context];
    
    return result.JSValueRef;
}

@implementation JSNRContainer
@synthesize JSNRClass=_JSNRClass, info=_info;

- (id)initWithJSNRClass:(id)cls info:(NSObject *)info {
    self = [super init];
    if (self) {
        self.JSNRClass = cls;
        self.info  = info;
        
    }
    return self;
}

+ (instancetype)containerForClass:(id)cls info:(NSObject *)info {
    return [[[self alloc] initWithJSNRClass:cls info:info] autorelease];
}

- (void)dealloc {
    self.JSNRClass = nil;
    self.info = nil;
    
    [super dealloc];
}

@end

@interface JSNRSuperClass ()
@property (nonatomic, assign) JSClassDefinition classDefinition;
@end

@implementation JSNRSuperClass
@synthesize classReference=_classReference, classDefinition=_classDefinition;

+ (instancetype)sharedReference
{
    static NSObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self alloc] init] autorelease];
        // Do any other initialisation stuff here
    });
    return (id)sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        
        JSClassDefinition classDef = kJSClassDefinitionEmpty;
        classDef.className = [[self class] JSClassName].UTF8String;
        classDef.attributes = kJSClassAttributeNone;
        
        if ([self conformsToProtocol:@protocol(JSNRClass)]) {
            
            if ([self respondsToSelector:@selector(initializeWithObject:inContext:)])
                classDef.initialize = JSNRObjectInitializeCallbackWrap;
            
            if ([self respondsToSelector:@selector(finalizeWithObject:)])
                classDef.finalize = JSNRObjectFinalizeCallbackWrap;
            
            if ([self respondsToSelector:@selector(object:hasPropertyWithName:inContext:)])
                classDef.hasProperty = JSNRObjectHasPropertyCallbackWrap;
            
            if ([self respondsToSelector:@selector(getPropertyWithName:fromObject:inContext:)])
                classDef.getProperty = JSNRObjectGetPropertyCallbackWrap;
            
            if ([self respondsToSelector:@selector(setPropertyWithName:onObject:value:inContext:)])
                classDef.setProperty = JSNRObjectSetPropertyCallbackWrap;
            
            if ([self respondsToSelector:@selector(deletePropertyWithName:onObject:inContext:)])
                classDef.deleteProperty = JSNRObjectDeletePropertyCallbackWrap;
            
            if ([self respondsToSelector:@selector(calledAsFunction:thisObject:argumentCount:argumentRefs:inContext:)])
                classDef.callAsFunction = JSNRObjectCallAsFunctionCallbackWrap;
            
            if ([self respondsToSelector:@selector(calledAsConstructor:argumentCount:argumentRefs:inContext:)])
                classDef.callAsConstructor = JSNRObjectCallAsConstructorCallbackWrap;
            
            if ([self respondsToSelector:@selector(convertObject:toType:inContext:)])
                classDef.convertToType = JSNRConvertToTypeWrap;
        }
        
        self.classDefinition = classDef;
        [self _createReferenceFromDefinition];
    }
    
    return self;
}

- (void)_createReferenceFromDefinition {
    _classReference = JSClassCreate(&_classDefinition);
}

+ (JSObjectRef)createEmptyObjectRefWithContext:(JSContextRef)ctx classRef:(JSNRSuperClass *)jsnrclass {
    JSObjectRef classObject = JSObjectMake(ctx, jsnrclass.classReference, [JSNRContainer containerForClass:jsnrclass info:nil]);
    
    return classObject;
}

+ (JSValue *)createEmptyObjectWithContext:(JSContext *)context classRef:(JSNRSuperClass *)jsnrclass {
    return [JSValue valueWithJSValueRef:[JSNRSuperClass createEmptyObjectRefWithContext:context.JSGlobalContextRef classRef:jsnrclass] inContext:context];
}

- (void)dealloc {
    
    [super dealloc];
}

@end
