//
//  JSNRCCallback.h
//  Dynosoar
//
//  Created by Bailey Seymour on 12/2/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRCCallback_h
#define JSNRCCallback_h

#define JSNRGetCallbackCast Value object = Value(ctx, objectRef); String propertyName = String(propertyNameRef); \
(void)object;(void)propertyName;

#define JSNRSetCallbackCast Value object = Value(ctx, objectRef); String propertyName = String(propertyNameRef); Value value = Value(ctx, valueRef); \
(void)object;(void)propertyName;(void)value;

#define JSNRFunctionCallbackCast Value function = Value(ctx, functionRef); Value thisObject = Value(ctx, thisObjectRef);\
(void)function;(void)thisObject;

#define JSNRConstructorCallbackCast Value constructor = Value(ctx, constructorRef);\
(void)constructor;

#define JSNRFinalizeCallbackCast Value object = Value(NULL, objectRef);\
(void)object;

#define JSNRConvertToTypeCallbackCast Value object = Value(ctx, objectRef);(void)object;

#endif /* JSNRCCallback_h */
