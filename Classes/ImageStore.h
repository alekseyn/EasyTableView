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
- (void)errorMessage:(NSString *)message;
- (void)image:(UIImage *)image loadedAtIndex:(NSUInteger)index;
@end

@interface ImageStore : NSObject

@property (assign, nonatomic) id<ImageStoreDelegate> delegate;
@property (retain, nonatomic) NSOperationQueue *operationQueue;
@property (retain, nonatomic) NSArray *titles;
@property (retain, nonatomic) NSArray *urls;
@property (retain, nonatomic) NSMutableDictionary *imageCache;

- (id)initWithDelegate:(id<ImageStoreDelegate>)delegate;
- (UIImage *)imageAtIndex:(NSUInteger)index;
- (void)clearImageCache;

@end
