//
//  JSNRString.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 12/1/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#import "JavaScriptNativeRuntime.h"

namespace JSNR {
    JSStringRef String::JSStringRef() {
        return JSStringCreateWithUTF8CString(this->c_str());
    }

    std::string String::string() {
        return this->_string;
    }

    const char *String::c_str() {
        return this->_string.c_str();
    }

    NSString *String::NSString() {
        return @(this->c_str());
    }

    JSNR::Value String::value(JSContextRef ctx) {
        return JSNR::Value(ctx, JSValueMakeString(ctx, this->JSStringRef()));
    }

    String::String(std::string str) {
        this->_string = str;
    }
    
    String::String(::NSString *str) {
        this->_string = [str UTF8String];
    }
    
    String::String(Value value) {
        ::JSStringRef jsString = (::JSStringRef)JSValueToStringCopy(value.context, value.valueRef, NULL);
        
        size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(jsString);
        char* utf8Buffer = new char[maxBufferSize];
        size_t bytesWritten = JSStringGetUTF8CString(jsString, utf8Buffer, maxBufferSize);
        std::string utf_string = std::string(utf8Buffer, bytesWritten -1); // the last byte is a null \0 which std::string doesn't need.
        delete [] utf8Buffer;
        
        this->_string = utf_string;
    }

    String::String(::JSStringRef jsString) {
        size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(jsString);
        char* utf8Buffer = new char[maxBufferSize];
        size_t bytesWritten = JSStringGetUTF8CString(jsString, utf8Buffer, maxBufferSize);
        std::string utf_string = std::string(utf8Buffer, bytesWritten -1); // the last byte is a null \0 which std::string doesn't need.
        delete [] utf8Buffer;
        
        this->_string = utf_string;
    }
    
}
