//
//  JSNRUtility.cpp
//  JavaScriptNativeRuntime
//
//  Created by Bailey Seymour on 11/30/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

//#import "JSNRUtility.h"
//
//using namespace std;
//
//string JSStringToStdString(JSStringRef jsString) {
//    size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(jsString);
//    char* utf8Buffer = new char[maxBufferSize];
//    size_t bytesWritten = JSStringGetUTF8CString(jsString, utf8Buffer, maxBufferSize);
//    string utf_string = string (utf8Buffer, bytesWritten -1); // the last byte is a null \0 which std::string doesn't need.
//    delete [] utf8Buffer;
//    return utf_string;
//}
//JSStringRef JSStringFromStdString(string str) {
//    return JSStringCreateWithUTF8CString(str.c_str());
//}
//
//JSStringRef JSStringFromJSValueRef(JSContextRef ctx, JSValueRef value) {
//    return JSValueToStringCopy(ctx, value, NULL);
//}
//
//std::string stringFromJSValueRef(JSContextRef ctx, JSValueRef value) {
//    return JSStringToStdString(JSStringFromJSValueRef(ctx, value));
//}

