interface("AppDelegate")
interface("NSColor")
interface("NSAlert")

function showAlert() {

  var alert = NSAlert()

  alert.addButtonWithTitle$("OK")
  alert.addButtonWithTitle$("Cancel")
  alert.messageText = "We've hooked into the method!"
  alert.informativeText = ";p"
  alert.alertStyle = 0;

  if (alert.runModal() == 1000) {
    //ok pressed
    console.log("ok!!!!!!!!!!!!!!!!!!");
  }
  alert.release()
}

hook(AppDelegate,"applicationDidFinishLaunching:", function(self,cmd,notification){
  self.window().backgroundColor = NSColor.greenColor()
  showAlert()
});
