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
