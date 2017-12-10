//
//  JSNRInvokeInfo.h
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/10/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSNRInvokeInfo : NSObject

- (id)initWithTarget:(id)target selectorString:(NSString *)selectorStr isClass:(BOOL)targetIsClass;

+ (instancetype)infoWithTarget:(id)target selector:(NSString *)selStr isClass:(BOOL)targetIsClass;
+ (instancetype)info;

@property (nonatomic, retain) id target;
@property (nonatomic, copy) NSString *selectorString;
@property (assign) BOOL targetIsClass;

- (SEL)selector;

@end
