# uwsgi-swift
uWSGI plugin for Apple Swift integration

This is a super-experimental plugin aimed at embedding swift apps into uWSGI.

It currently works only on OSX

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


The plugin is 2.x friendly:

```sh
uwsgi --build-plugin https://github.com/unbit/uwsgi-swift
```

or (once the repository is cloned)

```sh
uwsgi --build-plugin uwsgi-swift
```


The plugin has hardcoded mangled entry point:

```c
char *symbol_name = "_TF7example11applicationFCSo12NSDictionaryCSo7NSArray";
```

it maps to example.application function. Feel free to change it and rebuild the plugin

To build example.swift as a shared library

```sh
xcrun -sdk macosx swiftc -emit-library example.swift 
```

this will result in libexample.dylib

You can run uWSGI in swift mode with:

```sh
uwsgi --dlopen libexample.dylib --plugin swift_plugin.so --swift-func application --http-socket :9090 --threads 50 -p 2 -M
```

this will run an http server on port 9090 with two processes with 50 threads each.

The memory model of the plugin is still unimplemented, so expect extreme leaks.
