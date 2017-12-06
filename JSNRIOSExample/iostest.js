include("@headers/Foundation.js")
include("@headers/UIKit.js")

interface("ViewController")

hook(ViewController,"viewDidLoad", function(self,cmd){
     var label = UILabel()
     label.text = "this is a sample label";
     label.frame = [0,0,300,300];
     self.view().addSubview$(label);
     self.view().backgroundColor = UIColor.redColor();
});

