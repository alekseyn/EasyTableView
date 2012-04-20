//
//  ImageStore.h
//  EasyTableView
//
//  Created by Aleksey Novicov on 1/30/12.
//  Copyright (c) 2012 Yodel Code LLC. All rights reserved.
//
// This class loads the most recently added public Flickr images.

#import <Foundation/Foundation.h>

@protocol ImageStoreDelegate <NSObject>
- (void)imageTitles:(NSArray *)titles;
- (void)image:(UIImage *)image loadedAtIndex:(NSUInteger)index;
@optional
- (void)errorMessage:(NSString *)message;
@end

@interface ImageStore : NSObject

@property (nonatomic, unsafe_unretained) id<ImageStoreDelegate> delegate;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) NSArray *titles;
@property (nonatomic) NSArray *urls;
@property (nonatomic) NSMutableDictionary *imageCache;

- (id)initWithDelegate:(id<ImageStoreDelegate>)delegate;
- (UIImage *)imageAtIndex:(NSUInteger)index;
- (void)clearImageCache;

@end
