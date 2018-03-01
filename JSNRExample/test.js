include("@headers/Foundation.js")
include("@headers/AppKit.js")
interface("AppDelegate")
interface("JSNRContextManager")

hook(AppDelegate, "someMethodThatHasNSString", function(self, cmd){
  return "This is the new APPNAME!!!";
});

// var somethin2 = BaseSub.getSth
// console.log("subsub: "+somethin2);

// var arr = NSArray.arrayWithObject$$("hui")
// console.log(arr.objectAtIndex$$(0))

var bundleCls = new ObjCClass("NSBundle")
var initedVersion = bundleCls()
console.log("somethjing: "+initedVersion)
var mainBundle = new ObjCClass("NSBundle").mainBundle();
var bundleIdentifier = mainBundle.bundleIdentifier()
console.log("bid: "+bundleIdentifier)
/*
var f = Filesystem("ytt")
var hello = Filesystem.helloWorld
var bundle = JSNRContextManager().mainBundle;
console.log("it is: "+hello)
console.log("fromJS "+Filesystem().internalClassName)
*/
// hook(cls("NSWindow"),"backgroundColor",function(self,cmd){
//     return NSColor.blueColor()
// })
function showAlert() {

  var alert = NSAlert()
  // console.log("ISKOFK: "+alert.isKindOfClass$(NSAlert))
  console.log("ALERT: "+NSAlert+" then "+alert + "  "+new ObjCClass("NSAlert"))
  alert.addButtonWithTitle$("OK")
  alert.addButtonWithTitle$("Cancel")
  alert.messageText = "Delete the record?"
  alert.informativeText = "Deleted records cannot be restored."

  alert.alertStyle = NSAlertStyleWarning;
  var re = alert.runModal()
  if (re==1000) {
    //ok pressed
    console.log("ok!!!!!!!!!!!!!!!!!!");
  }
  alert.release()
}

hook(AppDelegate,"applicationDidFinishLaunching:", function(self,cmd,notification){

  showAlert()
  self.number$(25);
  console.log("myselfA: "+self);
  self.makePurple$("ello wolrd");
  console.log("myselfZ: "+self);
  self.makeRed()

  var win = self.window();
  console.log("win is: "+win);
  // var color = NSColor.yellowColor();
  // console.log("color: "+color);
  // win.setBackgroundColor$(color)

  self.window().alphaValue = 0.76
  self.twoArgMethod$arg2$("me","notme")
  // self.window().setBackgroundColor$(NSColor.orangeColor())
  // self.window().backgroundColor = NSColor.orangeColor();
  self.window().setFrame$display$([700,700,700,700], true);
  // self.aMethodThatTakePrimitiveArray$([300,400,100,900]); // this doesnt work

  // self.window().title = NSString.alloc().initWithString$("qwerty/yuoip").autorelease().lastPathComponent()
  console.log("cmd == "+cmd)
  // self.boolSet$(true);

  // self.window().title = self.someMethodThatHasNSString();
});

// hook(AppDelegate,"applicationDidFinishLaunching:", function(self,cmd,notification){
//
//      self.$.makeRed();
//      var bundle = C.NSBundle.mainBundle();
//      console.log("bundle: "+bundle.toString());
//      var bid = bundle.bundleIdentifier()
//      console.log("WE DID IT! "+bid);
//      self = self.$
//      self.makePurple$$(bid)
//      // self.window.setBackgroundColor$$(cls("NSColor").$.orangeColor())
//      self.window().title = "This calls to objc"
//      // self.title = "lololool"
//      // var window = self.window()
//      self.window().center()
// //     console.log(__self.$.allMaps)
//     orig(self,"orig_"+cmd,notification);
//
// });
