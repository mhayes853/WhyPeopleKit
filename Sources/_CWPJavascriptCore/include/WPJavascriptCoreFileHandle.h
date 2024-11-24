#import <Foundation/Foundation.h>

@interface WPJavascriptCoreFileHandle: NSObject

- (instancetype) initWithURL:(NSURL *) url error:(NSError **) error;

- (NSData *) readFromOffset:(uint64_t) offset upTo:(uint64_t) count error:(NSError **)error;

@end
