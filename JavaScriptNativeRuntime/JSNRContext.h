//
//  JSNRContext.h
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/29/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//
#import "JSNRInternal.h"

@class JSContext, JSNRClassMap;

@interface JSNRContext : NSObject

+ (instancetype)sharedInstance;
- (JSValue *)evaluateScript:(NSString *)contents baseDirectoryPath:(NSString *)baseDirectory;
- (JSNRClassMap *)mapForClass:(Class)cls;

@property (nonatomic, retain) JSContext *coreContext;
@property (nonatomic, copy) NSString *scriptContents;
@property (nonatomic, retain) NSMutableDictionary *allMaps;
@property (nonatomic, copy) NSString *baseDirectoryPath;

@end
