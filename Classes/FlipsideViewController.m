//
//  FlipsideViewController.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 1/30/12.
//  Copyright (c) 2012 Yodel Code LLC. All rights reserved.
//
// Demonstrates the use of EasyTableView with images loaded from a remote server.
// This example shows how to use EasyTableView from a storyboard.

#import "FlipsideViewController.h"


@implementation FlipsideViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

	[self.imageStore clearImageCache];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// This will initiate the request to get the list of Flickr images
	self.imageStore = [[ImageStore alloc] initWithDelegate:self];

	// Make sure the delegate and rowHeight table view properties are set accordingly in the storyboard.
	// The orientation property can only be set programmatically.
	self.easyTableView.orientation = EasyTableViewOrientationHorizontal;
}

#pragma mark - EasyTableViewDelegate

- (NSInteger)easyTableView:(EasyTableView *)easyTableView numberOfRowsInSection:(NSInteger)section {
	return self.imageStore.titles.count;
}

- (UITableViewCell *)easyTableView:(EasyTableView *)easyTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ImageViewCell";
	
    ImageViewCell *cell = [easyTableView.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (cell == nil) {
		UINib *nib = [UINib nibWithNibName:@"ImageViewCell" bundle:nil];
		[nib instantiateWithOwner:self options:nil];

		cell = _imageViewCell;
    }
    
    // Set the title and image for the given index
	cell.label.text				= self.imageStore.titles[indexPath.row];
	cell.flickrImageView.image	= [self.imageStore imageAtIndex:indexPath.row];
	
    return cell;
}

#pragma mark - ImageStoreDelegate

- (void)imageTitles:(NSArray *)titles {
	// Now that we know how many images we will get, we can reload the table view
	[self.easyTableView reload];
}

- (void)errorMessage:(NSString *)message {
	self.errorLabel.text = message;
}

- (void)image:(UIImage *)image loadedAtIndex:(NSUInteger)index {
	NSIndexPath *indexPath	= [NSIndexPath indexPathForRow:index inSection:0];
    ImageViewCell *cell	= [self.easyTableView.tableView cellForRowAtIndexPath:indexPath];
	UIView *view			= cell.contentView.subviews[0];
	
	// The view might be nil if the cell has scrolled offscreen while we were waiting for the image to load.
	// In that case, there is no need to set the image, nor is it even possible.
	if (view) {
		cell.flickrImageView.image = image;
	}
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
