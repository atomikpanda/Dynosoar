//
//  JSNRInstanceClass.h
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/7/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JSNRSuperClass.h"

@interface JSNRObjCClassClass : JSNRSuperClass
- (JSObjectRef)createObjectRefWithContext:(JSContextRef)ctx object:(void *)obj;
@end
