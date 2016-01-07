//
//  FlipsideViewController.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 1/30/12.
//  Copyright (c) 2012 Yodel Code LLC. All rights reserved.
//
// Demonstrates the use of EasyTableView with images loaded from a remote server

#import "FlipsideViewController.h"

#define TABLEVIEW_HEIGHT			140
#define TABLECELL_WIDTH				180

#define LABEL_TAG					100
#define IMAGE_TAG					101

@implementation FlipsideViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

	[self.imageStore clearImageCache];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// This will initiate the request to get the list of Flickr images
	ImageStore *store = [[ImageStore alloc] initWithDelegate:self];
	
	self.imageStore = store;
}

#pragma mark - EasyTableView Initialization

- (void)setupEasyTableView {
	CGRect frameRect	= CGRectMake(0, 44, self.view.bounds.size.width, TABLEVIEW_HEIGHT);
	self.easyTableView	= [[EasyTableView alloc] initWithFrame:frameRect ofWidth:TABLECELL_WIDTH];
	
	self.easyTableView.delegate						= self;
	self.easyTableView.tableView.backgroundColor	= [UIColor clearColor];
	self.easyTableView.tableView.separatorColor		= [UIColor blackColor];
	self.easyTableView.autoresizingMask				= UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
	self.easyTableView.tableView.separatorStyle		= UITableViewCellSeparatorStyleNone;
	
	[self.view addSubview:self.easyTableView];
}

#pragma mark - EasyTableViewDelegate

- (UITableViewCell *)easyTableView:(EasyTableView *)easyTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EasyTableViewCell";
    UITableViewCell *cell = [easyTableView.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.clipsToBounds = YES;
		cell.contentView.backgroundColor = [UIColor blackColor];
        
        // Setup an image view to display an image
		CGRect imageViewFrame		= cell.contentView.bounds;
		
        UIImageView *imageView		= [[UIImageView alloc] initWithFrame:CGRectInset(imageViewFrame, 1, 0)];
        imageView.tag				= IMAGE_TAG;
        imageView.contentMode		= UIViewContentModeScaleAspectFill;
		imageView.autoresizingMask	= UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
        [cell.contentView addSubview:imageView];
        
        // Setup a label to display the image title
        CGRect labelRect		= CGRectMake(10, cell.bounds.size.height-20, cell.bounds.size.width-20, 20);
        UILabel *label			= [[UILabel alloc] initWithFrame:labelRect];
        label.textAlignment		= NSTextAlignmentCenter;
        label.textColor			= [UIColor colorWithWhite:1.0 alpha:0.5];
        label.backgroundColor	= [UIColor clearColor];
        label.font				= [UIFont boldSystemFontOfSize:14];
        label.tag				= LABEL_TAG;
        label.autoresizingMask  = UIViewAutoresizingFlexibleTopMargin;
        
        [cell.contentView addSubview:label];
    }
    
    // Set the image title for the given index
	UILabel *label	= (UILabel *)[cell viewWithTag:LABEL_TAG];
	label.text		= self.imageStore.titles[indexPath.row];
	
	// Set the image for the given index
	UIImageView *imageView	= (UIImageView *)[cell viewWithTag:IMAGE_TAG];
	imageView.image			= [self.imageStore imageAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - ImageStoreDelegate

- (void)imageTitles:(NSArray *)titles {
	// Now that we know how many images we will get, we can create our EasyTableView
	[self setupEasyTableView];
}

- (NSInteger)easyTableView:(EasyTableView *)easyTableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageStore.titles.count;
}

- (void)errorMessage:(NSString *)message {
	self.errorLabel.text = message;
}

- (void)image:(UIImage *)image loadedAtIndex:(NSUInteger)index {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.easyTableView.tableView cellForRowAtIndexPath:indexPath];
	UIView *view = cell.contentView.subviews[0];
	
	// The view might be nil if the cell has scrolled offscreen while we were waiting for the image to load.
	// In that case, there is no need to set the image, nor is it even possible.
	if (view) {
		// Set the image for the view (cell)
		UIImageView *imageView = (UIImageView *)[view viewWithTag:IMAGE_TAG];
		imageView.image = image;
	}
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
