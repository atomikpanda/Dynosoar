include("@headers/Foundation.js")
include("@headers/UIKit.js")

interface("ViewController")
var viewControllerInstance = null;
// Delegate should create a object that forwards all method calls on it, to JSFunctions on the delegate JSObjectRef
var delegate = new Delegate("UIAlertViewDelegate")

delegate.alertView$clickedButtonAtIndex$ = function(self, cmd, alert, buttonIndex) {
  console.log("self::: "+self)
  if (buttonIndex == 0) {
    viewControllerInstance.view().backgroundColor = UIColor.greenColor()
  }
  console.log("clickedButtonAtIndex!!!!!!!!!!!!!!!!!!!")
}
delegate = delegate.create()

function alert() {

  var alert = UIAlertView.alloc().initWithTitle$message$delegate$cancelButtonTitle$otherButtonTitles$("ROFL","Dee dee doo doo.",delegate,"OK",null)
  alert.show()
  // console.log("desc is: "+alert.description())
  // alert.autorelease()
}

var buttonHandler = new Delegate()
buttonHandler.buttonWasPressed$ = function(self,cmd,sender){
  console.log("\nlooks like you touched the button!\n")
  console.log("sender:::: "+sender)
  console.log("cls:::: "+sender.class())
  sender.setTitle$forState$("Button Pressed",0)
}
buttonHandler = buttonHandler.create();

hook(ViewController,"viewDidLoad", function(self,cmd){
    viewControllerInstance = self;

     var button = UIButton()

     button.setTitle$forState$("Button",0)
     button.frame = [0,0,300,300];
     button.addTarget$action$forControlEvents$(buttonHandler, "buttonWasPressed:", (1<<6))
     self.view().addSubview$(button);
     self.view().backgroundColor = UIColor.redColor();
     alert();
});
