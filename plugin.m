#include <uwsgi.h>
#import "Foundation/NSString.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSData.h"
#import "Foundation/NSAutoReleasePool.h"

struct uwsgi_swift {
	// function to call in the current address space
	char *func;

	NSArray *(*func_ptr)(NSDictionary *);

	NSAutoreleasePool *pool;
} uswift;


static struct uwsgi_option swift_options[] = {
	{"swift-func", required_argument, 0, "swift function to call at every request", uwsgi_opt_set_str, &uswift.func, 0},
	UWSGI_END_OF_OPTIONS
};

static void swift_apps() {
	if (!uswift.func)
		return;

	// TODO build the mangled name dynamically
	char *symbol_name = "_TF7example11applicationFCSo12NSDictionaryCSo7NSArray";

	uswift.func_ptr = (NSArray *(*)(NSDictionary *)) dlsym(RTLD_DEFAULT, symbol_name);

	if (!uswift.func_ptr) {
		uwsgi_log("unable to find swift entry point\n");
		exit(1);
	}
}

// TODO manage memory
static int swift_request(struct wsgi_request *wsgi_req) {

	if (!uswift.func)
		return -1;
	

	if (uwsgi_parse_vars(wsgi_req))
		return -1;


	NSMutableDictionary *env = [[NSMutableDictionary alloc] init];

	int i;
	for(i = 0; i < wsgi_req->var_cnt; i+=2) {
		NSString *ekey = [[NSString alloc] initWithBytes:wsgi_req->hvec[i].iov_base length:wsgi_req->hvec[i].iov_len encoding:NSUTF8StringEncoding];
		NSString *evalue = [[NSString alloc] initWithBytes:wsgi_req->hvec[i+1].iov_base length:wsgi_req->hvec[i+1].iov_len encoding:NSUTF8StringEncoding];
		[env setObject:evalue forKey:ekey];
	}

	NSArray *ret = uswift.func_ptr(env);
	if (!ret) goto end;

	NSString *status = [ret objectAtIndex:0];

	if (uwsgi_response_prepare_headers(wsgi_req, (char *)[status UTF8String], [status lengthOfBytesUsingEncoding:NSUTF8StringEncoding]))
		goto end;

	NSDictionary *headers = [ret objectAtIndex:1];

	for(NSString *key in headers) {
		NSArray *values = [headers objectForKey:key];
		for(NSString *value in values) {
			uwsgi_response_add_header(wsgi_req, (char *)[key UTF8String], [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
				(char *) [value UTF8String], [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
		}
	}

	NSArray *chunks = [ret objectAtIndex:2];
	for(NSData *chunk in chunks) {
		uwsgi_response_write_body_do(wsgi_req, (char *) [chunk bytes], [chunk length]);
	}

end:
	return UWSGI_OK;

}

static void swift_autorelease_pool() {
	// TODO choose the appropriate memory management model
	//uswift.pool = [[NSAutoreleasePool alloc] init];
}

struct uwsgi_plugin swift_plugin = {
	.name = "swift",
	.modifier1 = 0,
	.options = swift_options,
	.init_apps = swift_apps,
	.request = swift_request,
	.after_request = log_request,
	.post_fork = swift_autorelease_pool,
};
