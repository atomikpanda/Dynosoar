// function interface(name, aliasName) {
//   var global = (1,eval)('this');
//   var cls = new ObjCClass(name);
//   if (aliasName == null || aliasName == undefined || aliasName.length() == 0)
//     global[name] = cls;
//   else
//     global[aliasName] = cls;
//
//   return cls;
// }
interface("NSObject");
interface("NSArray");
interface("NSMutableArray");
interface("NSDictionary");
interface("NSMutableDictionary");
interface("NSNumber");
interface("NSBundle");
interface("NSFileManager");
