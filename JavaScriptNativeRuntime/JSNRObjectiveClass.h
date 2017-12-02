//
//  JSNRClasses.hpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/30/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRClasses_hpp
#define JSNRClasses_hpp

#import "JSNRInternal.h"
// JSNRObjectiveClass
JSValueRef JSNRObjectiveClassGet(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef *exception);
JSClassRef JSNRObjectiveClass(const char *className);
#endif /* JSNRClasses_hpp */
