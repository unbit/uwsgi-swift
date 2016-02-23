# uwsgi-swift
uWSGI plugin for Apple Swift integration

This is a super-experimental plugin aimed at embedding swift apps into uWSGI.

The plugin includes a swift module from which you can start building better integration:

```swift
import Foundation

public func application(s : NSDictionary) -> NSArray {
        print("Hello World")
        print(s["REQUEST_METHOD"])
        print(s)
        print("ready for response")
        let chunk0 : NSData! = "Hello ".dataUsingEncoding(NSUTF8StringEncoding)
        let chunk1 : NSData! = "World".dataUsingEncoding(NSUTF8StringEncoding)
        return ["200 OK", ["Foo": ["Bar", "Ops"]], [chunk0, chunk1]] as NSArray
}
```

as you can see, Objective-C native types are expected at the lower level, consider making some kind of wrapping to Swift native types
