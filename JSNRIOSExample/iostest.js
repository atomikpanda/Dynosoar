//include("/Users/atomikpanda/Documents/Personal Projects/Dynosoar/JSNRExample/Foundation.js")
interface("ViewController")
interface("JSNRContext")
interface("UIColor")
interface("UILabel")

hook(ViewController,"viewDidLoad", function(self,cmd){
     var label = UILabel()
     label.text = "this is a sample label";
     label.frame = [0,0,300,300];
     self.view().addSubview$(label);
     self.view().backgroundColor = UIColor.redColor();
});

