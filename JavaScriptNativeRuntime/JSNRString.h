//
//  JSNRString.hpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRString_hpp
#define JSNRString_hpp
#import "JSNRInternal.h"
//#include <cstdio>
//#include <cstring>
#include <string>
//#import "Value.h"

namespace JSNR {
    class Value;
    class String {
        
        std::string _string;
    public:
        JSStringRef JSStringRef();
        std::string string();
        Value value(JSContextRef ctx);
        const char *c_str();
        NSString *NSString();
        
        String(std::string string);
        String(::NSString *str);
        String(::JSStringRef string);
        String(Value value);
    };
}

#endif /* JSNRString_hpp */
