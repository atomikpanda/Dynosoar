
var AppDelegate = cls("AppDelegate");
var __proxyBody;
__proxyBody = {
  get(target,name,receiver){
    if (name == "toString") {
      return function(){
        var returnValue = __invoke( target,"description", [])
        return returnValue;
      }
    }
     else {

        return function(){
          console.log("calling: "+name+" on "+target)
          var returnValue = __invoke(target, name, arguments)
          console.log("got "+returnValue)
          if (typeof returnValue === 'object' && returnValue !== null)
            return new Proxy(returnValue, __proxyBody);
          else
            return returnValue
        }
      }
    },
    set (target, name, value) {
         name = "set"+name.substr(0, 1).toUpperCase() + name.substr(1)+":";

        console.log("setting: "+name)
      __invoke(target, name, [value])
      return true
    }
}

Object.prototype.__defineGetter__("$",function(){
      var proxy = new Proxy(this, __proxyBody);
      return proxy;
})

var C = new Proxy(this, {
  get (target, name, receiver) {
    return cls(name).$
  }
})

hook(cls("NSWindow"),"backgroundColor",function(self,cmd){
    // self = self.$
    // var color = C.NSColor.colorWithRed$$green$$blue$$alpha$$(1,1,1,1)
    var color = C.NSColor.redColor();
    console.log(color.description())
    console.log(color.addr)
    // console.log("returning:::: "+color.description())
    return color
})

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
