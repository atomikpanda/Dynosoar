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
    JSNRContainer *container = (id)[thisObject privateData];
    
    JSValue *result = [container.JSNRClass calledAsFunction:function thisObject:thisObject argumentCount:argumentCount argumentRefs:argumentRefs inContext:context];
    
    return result.JSValueRef;
}

JSObjectRef JSNRObjectCallAsConstructorCallbackWrap(JSContextRef ctx, JSObjectRef constructorRef, size_t argumentCount, const JSValueRef argumentRefs[], JSValueRef *exception)
{
    JSContext *context = [JSContext contextWithJSGlobalContextRef:JSContextGetGlobalContext(ctx)];
    JSValue *constructor = [JSValue valueWithJSValueRef:constructorRef inContext:context];
    
    JSNRContainer *container = (id)[constructor privateData];
    if (![container.JSNRClass respondsToSelector:@selector(calledAsConstructor:argumentCount:argumentRefs:inContext:)])
        return (JSObjectRef)[JSValue valueWithNullInContext:context].JSValueRef;
    
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
@synthesize JSNRClass=_JSNRClass, data=_data;

- (id)initWithJSNRClass:(id)cls data:(void *)data {
    self = [super init];
    if (self) {
        self.JSNRClass = cls;
        self.data = data;
    }
    return self;
}

- (void)dealloc {
    self.JSNRClass = nil;
    self.data = NULL;
    
    [super dealloc];
}

@end

@interface JSNRSuperClass ()
@property (nonatomic, assign) JSClassDefinition classDefinition;
@end

@implementation JSNRSuperClass
@synthesize classReference=_classReference, classDefinition=_classDefinition;

+ (NSString *)JSClassName {
    return @"BaseClass2";
}

- (id)init {
    self = [super init];
    
    if (self) {
        
        JSClassDefinition classDef = kJSClassDefinitionEmpty;
        classDef.className = [[self class] JSClassName].UTF8String;
        classDef.attributes = kJSClassAttributeNone;
        
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
        
        
        self.classDefinition = classDef;
        [self _createReferenceFromDefinition];
    }
    
    return self;
}

- (void)_createReferenceFromDefinition {
    _classReference = JSClassCreate(&_classDefinition);
}

- (JSNRContainer *)_createContainer {
    JSNRContainer *container = [[JSNRContainer alloc] initWithJSNRClass:self data:NULL];
    // set any extra props on container here
    return container;
}

- (JSObjectRef)createObjectRefWithContext:(JSContextRef)ctx {
    JSObjectRef classObject = JSObjectMake(ctx, self.classReference, NULL);
    return classObject;
}

- (JSValue *)addClassObjectInContext:(JSContext *)context {
    JSContextRef ctx = (JSContextRef)context.JSGlobalContextRef;
    
    JSObjectRef classObject = [self createObjectRefWithContext:ctx];
    
    JSValue *val =  [JSValue valueWithJSValueRef:classObject inContext:context];
    JSNRContainer *container = [self _createContainer];
    [val setPrivateData:container];
    NSLog(@"** INSERTING: %@", [self class].JSClassName);
    [context.globalObject setValue:val forProperty:[[self class] JSClassName]];
    
    return val;
}

- (JSValue *)getPropertyWithName:(NSString *)propertyName fromObject:(JSValue *)object inContext:(JSContext *)context {
    return [propertyName valueInContext:context];
}

- (void)dealloc {
    
    [super dealloc];
}

@end
