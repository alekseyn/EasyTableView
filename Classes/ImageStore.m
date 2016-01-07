//
//  ImageStore.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 1/30/12.
//  Copyright (c) 2012 Yodel Code LLC. All rights reserved.
//

#import "ImageStore.h"

@implementation ImageStore

- (id)initWithDelegate:(id<ImageStoreDelegate>)aDelegate {
    self = [super init];
    if (self) {
		self.delegate = aDelegate;
		
		// We need a separate queue for all of our network transactions
		NSOperationQueue *queue = [[NSOperationQueue alloc] init];
		
		[queue addOperationWithBlock:^{
			NSDictionary *json = nil;
			NSError *error;
			
			// Due to the high frequency of JSON deserialization errors, loop until there is no error
			do {
				error = nil;
				
				// Retrieve list of public images from Flickr
				NSURL *url = [NSURL URLWithString:@"http://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"];
				NSData *listData = [NSData dataWithContentsOfURL:url];
			
				// If there is no network connection, listData will be nil
				if (listData) {
					json = [NSJSONSerialization JSONObjectWithData:listData options:NSJSONReadingAllowFragments error:&error];
					
					// Make sure to call delegate on main queue
					[[NSOperationQueue mainQueue] addOperationWithBlock:^{
						if ([aDelegate respondsToSelector:@selector(errorMessage:)]) {
							if (error)
								[aDelegate errorMessage:[NSString stringWithFormat:@"%@ Retrying.", [error localizedDescription]]];
							else
								[aDelegate errorMessage:nil];
						}
					}];
				}
				else {
					if ([aDelegate respondsToSelector:@selector(errorMessage:)])
						[aDelegate errorMessage:@"Internet is not available. Please try again later."];
				}
			}
			while (error);

			// If there is no network connection, json will be nil
			if (json) {
				self.titles = [json valueForKeyPath:@"items.title"];
				self.urls = [json valueForKeyPath:@"items.media.m"];
				
				// Setup image cache
				NSMutableDictionary *cache = [[NSMutableDictionary alloc] initWithCapacity:[self.titles count]];
				self.imageCache = cache;
				
				// Make sure to call delegate on main queue
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					if ([aDelegate respondsToSelector:@selector(imageTitles:)]) {
						[aDelegate imageTitles:self.titles];
					}
				}];
			}
		}];
		
		self.operationQueue = queue;
    }
    return self;
}

- (UIImage *)imageAtIndex:(NSUInteger)index {
	NSString *urlString = self.urls[index];
	UIImage *image = self.imageCache[urlString];
	
	if (!image) {
		NSURL *url = [NSURL URLWithString:urlString];
		
		[self.operationQueue addOperationWithBlock:^{
			NSData *imageData = [NSData dataWithContentsOfURL:url];
			UIImage *newImage = [UIImage imageWithData:imageData];
			
			// Save the image in the image cache
			if (newImage) {
				self.imageCache[urlString] = newImage;
				
				// Make sure to call delegate on main queue
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					if ([self.delegate respondsToSelector:@selector(image:loadedAtIndex:)]) {
						[self.delegate image:newImage loadedAtIndex:index];
					}
				}];
			}
		}];
	}
	return image;
}

- (void)clearImageCache {
	[self.imageCache removeAllObjects];
}

@end
