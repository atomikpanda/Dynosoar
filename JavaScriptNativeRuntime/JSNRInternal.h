//
//  JSNRInternal.h
//  Dynosoar
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRInternal_h
#define JSNRInternal_h
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#endif /* JSNRInternal_h */
