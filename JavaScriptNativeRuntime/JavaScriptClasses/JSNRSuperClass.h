//
//  JSNRSuperClass.h
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/7/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSNRContextManager.h"

@class JSNRSuperClass;
@interface JSNRContainer : NSObject

- (id)initWithJSNRClass:(id)cls data:(void *)data;

@property (nonatomic, retain) JSNRSuperClass *JSNRClass;
@property (nonatomic, assign) void *data;

@end

@interface JSNRSuperClass : NSObject

@property (nonatomic, assign) JSClassRef classReference;

+ (NSString *)JSClassName;
- (id)init;
- (JSObjectRef)createObjectRefWithContext:(JSContextRef)ctx;
- (JSValue *)addClassObjectInContext:(JSContext *)context;
- (JSNRContainer *)_createContainer;

- (void)initializeWithObject:(JSValue *)object inContext:(JSContext *)context;
- (void)finalizeWithObject:(JSValue *)object;
- (BOOL)object:(JSValue *)object hasPropertyWithName:(NSString *)propertyName inContext:(JSContext *)context;
- (JSValue *)getPropertyWithName:(NSString *)propertyName fromObject:(JSValue *)object inContext:(JSContext *)context;
- (BOOL)setPropertyWithName:(NSString *)propertyName onObject:(JSValue *)object value:(JSValue *)value inContext:(JSContext *)context;
- (BOOL)deletePropertyWithName:(NSString *)propertyName onObject:(JSValue *)object inContext:(JSContext *)context;
- (JSValue *)calledAsFunction:(JSValue *)function thisObject:(JSValue *)thisObject argumentCount:(size_t)argumentCount argumentRefs:(const JSValueRef[])argumentRefs inContext:(JSContext *)context;
- (JSValue *)calledAsConstructor:(JSValue *)constructor argumentCount:(size_t)argumentCount argumentRefs:(const JSValueRef[])argumentRefs inContext:(JSContext *)context;
- (JSValue *)convertObject:(JSValue *)object toType:(JSType)type inContext:(JSContext *)context;

@end
