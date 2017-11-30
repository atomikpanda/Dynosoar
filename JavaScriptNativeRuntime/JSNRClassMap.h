//
//  JSNRHookedMap.h
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/29/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface JSNRClassMap : NSObject
+ (instancetype)classMap;
@property (nonatomic, retain) NSMutableDictionary *map;

@end

@interface NSObject (_JSNRClassMap)
+ (JSNRClassMap *)_JSNRClassMap;
@end
