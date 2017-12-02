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
