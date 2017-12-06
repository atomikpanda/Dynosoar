//include("/Users/atomikpanda/Documents/Personal Projects/Dynosoar/JSNRExample/Foundation.js")
interface("ViewController")
interface("JSNRContext")
interface("UIColor")


hook(ViewController,"viewDidLoad", function(self,cmd){

     self.view().backgroundColor = UIColor.redColor();
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
