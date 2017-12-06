# Dynosoar
Dynosoar (Dynamic loading) and JSNR (JavaScriptNativeRuntime). Make tweaks using JavaScript.

Basically I'm gonna try to explain what some of the classes do:

JSNRContext:
a manager that contains the context of the JavaScriptEngine as well as some basic JS utility functions.
JSNRInstance:
A JSClass wrapper that holds a reference to an object that is allocated in ObjC.
ExampleClass (I really should rename this):
A JSClass wrapper that holds a reference to a Class object in Objective-C.
(can be accessed directly from JS using `var someClass = new ObjCClass("UIView")`
that will return something like [UIView class]

JSNRInvoke:
A c++ class that has functions related to calling the methods in Objective-C using NSInvocation.

JSNRSigType:
A c++ class that attemps to parse NSMethodSignatures and converts JSValueRefs to actual ctypes or Objective-C objects.

JSNRPrimitiveTypeHandler:
handles the logic to convert JavaScript objects to whatever a Objective-C method wants.
in js `obj.someMethod$("this is a string in JS")`
and in objc
if -someMethod:(const char*)arg1

it will convert the JSValueRef "this is a string" to a const char *

in js `obj.anotherMethod$("this is a string in JS")`
if -anotherMethod:(NSString *)arg1

it will convert the JSValueRef "this is a string" to a NSString

Value:
String:
These classes make it easier to handle the JSC C API's JSValueRefs and JSStringRefs
