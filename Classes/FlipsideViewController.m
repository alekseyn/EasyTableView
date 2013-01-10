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

@synthesize delegate = _delegate;
@synthesize imageStore = _imageStore;
@synthesize easyTableView = _easyTableView;
@synthesize errorLabel = _errorLabel;


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

- (void)viewDidUnload {
    [super viewDidUnload];
    
	self.errorLabel = nil;
	self.easyTableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark -
#pragma mark EasyTableView Initialization

- (void)setupEasyTableViewWithNumCells:(NSUInteger)count {
	CGRect frameRect	= CGRectMake(0, 44, self.view.bounds.size.width, TABLEVIEW_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect numberOfColumns:count ofWidth:TABLECELL_WIDTH];
	self.easyTableView	= view;
	
	self.easyTableView.delegate						= self;
	self.easyTableView.tableView.backgroundColor	= [UIColor clearColor];
	self.easyTableView.tableView.separatorColor		= [UIColor blackColor];
	self.easyTableView.cellBackgroundColor			= [UIColor blackColor];
	self.easyTableView.autoresizingMask				= UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview:self.easyTableView];
}

#pragma mark - EasyTableViewDelegate

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {
	// Create a container view for an EasyTableView cell
	UIView *container = [[UIView alloc] initWithFrame:rect];;
	
	// Setup an image view to display an image
	UIImageView *imageView	= [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, rect.size.width-2, rect.size.height)];
	imageView.tag			= IMAGE_TAG;
	imageView.contentMode	= UIViewContentModeScaleAspectFill;
	
	[container addSubview:imageView];
	
	// Setup a label to display the image title
	CGRect labelRect		= CGRectMake(10, rect.size.height-20, rect.size.width-20, 20);
	UILabel *label			= [[UILabel alloc] initWithFrame:labelRect];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
	label.textAlignment		= UITextAlignmentCenter;
#else
	label.textAlignment		= NSTextAlignmentCenter;
#endif
	label.textColor			= [UIColor colorWithWhite:1.0 alpha:0.5];
	label.backgroundColor	= [UIColor clearColor];
	label.font				= [UIFont boldSystemFontOfSize:14];
	label.tag				= LABEL_TAG;
	
	[container addSubview:label];
	
	return container;
}

// Second delegate populates the views with data from a data source

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath {
	// Set the image title for the given index
	UILabel *label = (UILabel *)[view viewWithTag:LABEL_TAG];
	label.text = [self.imageStore.titles objectAtIndex:indexPath.row];
	
	// Set the image for the given index
	UIImageView *imageView = (UIImageView *)[view viewWithTag:IMAGE_TAG];
	imageView.image = [self.imageStore imageAtIndex:indexPath.row];
}

#pragma mark - ImageStoreDelegate

- (void)imageTitles:(NSArray *)titles {
	// Now that we know how many images we will get, we can create our EasyTableView
	[self setupEasyTableViewWithNumCells:[titles count]];
}

- (void)errorMessage:(NSString *)message {
	self.errorLabel.text = message;
}

- (void)image:(UIImage *)image loadedAtIndex:(NSUInteger)index {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
	UIView *view = [self.easyTableView viewAtIndexPath:indexPath];
	
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
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
