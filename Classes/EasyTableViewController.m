//
//  EasyTableViewController.m
//  EasyTableViewController
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright Yodel Code LLC 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableViewController.h"
#import "EasyTableView.h"

#define PORTRAIT_WIDTH				768
#define LANDSCAPE_HEIGHT			(1024-20)
#define NUM_OF_CELLS				21
#define HORIZONTAL_TABLEVIEW_HEIGHT	140
#define VERTICAL_TABLEVIEW_WIDTH	180
#define TABLE_BACKGROUND_COLOR		[UIColor clearColor]

#define BORDER_VIEW_TAG				10

@interface EasyTableViewController (MyPrivateMethods)
- (void)setupHorizontalView;
- (void)setupVerticalView;
@end

@implementation EasyTableViewController

@synthesize bigLabel, verticalView, horizontalView;

- (void)dealloc {
	[bigLabel release];
	[horizontalView release];
	[verticalView release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupVerticalView];
	[self setupHorizontalView];
}


- (void)viewDidUnload {
	[super viewDidUnload];	
	self.bigLabel = nil;
}


-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark EasyTableView Initialization

- (void)setupHorizontalView {
	CGRect frameRect	= CGRectMake(0, LANDSCAPE_HEIGHT - HORIZONTAL_TABLEVIEW_HEIGHT, PORTRAIT_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect numberOfColumns:NUM_OF_CELLS ofWidth:VERTICAL_TABLEVIEW_WIDTH];
	self.horizontalView = view;
	
	horizontalView.delegate						= self;
	horizontalView.tableView.backgroundColor	= TABLE_BACKGROUND_COLOR;
	horizontalView.tableView.allowsSelection	= YES;
	horizontalView.tableView.separatorColor		= [UIColor darkGrayColor];
	horizontalView.cellBackgroundColor			= [UIColor darkGrayColor];
	horizontalView.autoresizingMask				= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview:horizontalView];
	[view release];
}


- (void)setupVerticalView {
	CGRect frameRect	= CGRectMake(PORTRAIT_WIDTH - VERTICAL_TABLEVIEW_WIDTH, 0, VERTICAL_TABLEVIEW_WIDTH, LANDSCAPE_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect numberOfRows:NUM_OF_CELLS ofHeight:HORIZONTAL_TABLEVIEW_HEIGHT];
	self.verticalView	= view;
	
	verticalView.delegate					= self;
	verticalView.tableView.backgroundColor	= TABLE_BACKGROUND_COLOR;
	verticalView.tableView.allowsSelection	= YES;
	verticalView.tableView.separatorColor	= [[UIColor blackColor] colorWithAlphaComponent:0.1];
	verticalView.cellBackgroundColor		= [[UIColor blackColor] colorWithAlphaComponent:0.1];
	verticalView.autoresizingMask			= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Allow verticalView to scroll up and completely clear the horizontalView
	verticalView.tableView.contentInset		= UIEdgeInsetsMake(0, 0, HORIZONTAL_TABLEVIEW_HEIGHT, 0);
	
	[self.view addSubview:verticalView];
	[view release];
}


#pragma mark -
#pragma mark Utility Methods

- (void)borderIsSelected:(BOOL)selected forView:(UIView *)view {
	UIImageView *borderView		= (UIImageView *)[view viewWithTag:BORDER_VIEW_TAG];
	NSString *borderImageName	= (selected) ? @"selected_border.png" : @"image_border.png";
	borderView.image			= [UIImage imageNamed:borderImageName];
}


#pragma mark -
#pragma mark EasyTableViewDelegate

// These delegate methods support both example views - first delegate method creates the necessary views

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {
	CGRect labelRect		= CGRectMake(10, 10, rect.size.width-20, rect.size.height-20);
	UILabel *label			= [[[UILabel alloc] initWithFrame:labelRect] autorelease];
	label.textAlignment		= UITextAlignmentCenter;
	label.textColor			= [UIColor whiteColor];
	label.font				= [UIFont boldSystemFontOfSize:60];
	
	// Use a different color for the two different examples
	if (easyTableView == horizontalView)
		label.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
	else
		label.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
	
	UIImageView *borderView		= [[UIImageView alloc] initWithFrame:label.bounds];
	borderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	borderView.tag				= BORDER_VIEW_TAG;
	
	[label addSubview:borderView];
	[borderView release];
		 
	return label;
}

// Second delegate populates the views with data from a data source

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndex:(NSUInteger)index {
	UILabel *label	= (UILabel *)view;
	label.text		= [NSString stringWithFormat:@"%i", index];
	
	// selectedIndexPath can be nil so we need to test for that condition
	BOOL isSelected = (easyTableView.selectedIndexPath) ? (easyTableView.selectedIndexPath.row == index) : NO;
	[self borderIsSelected:isSelected forView:view];		
}

// Optional - Tracks the selection of a particular cell

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndex:(NSUInteger)index deselectedView:(UIView *)deselectedView {
	[self borderIsSelected:YES forView:selectedView];		
	
	if (deselectedView) 
		[self borderIsSelected:NO forView:deselectedView];
	
	UILabel *label	= (UILabel *)selectedView;
	bigLabel.text	= label.text;
}

// Optional - Delivers the number of Sections in the TableView
- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView{
    return 2;
}

//Optional - Delivers the number of cells in each section, this must be implemented if numberOfSectionsInEasyTableView is implementd
-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section{
    return 2;
}

//Optional - Delivers the header view
- (UIView*)easyTableView:(EasyTableView*)easyTableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    switch (section) {
        case 0:
            view.backgroundColor = [UIColor redColor];
            break;
        default:
            view.backgroundColor = [UIColor blueColor];
            break;
    }
    
    return view;
}

- (UIView*)easyTableView:(EasyTableView*)easyTableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    switch (section) {
        case 0:
            view.backgroundColor = [UIColor greenColor];
            break;
        default:
            view.backgroundColor = [UIColor yellowColor];
            break;
    }
    
    return view;
}

//Optional - Dynamic heights!
- (CGFloat)easyTableView:(EasyTableView *)easyTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return (1+0.1*indexPath.row)*VERTICAL_TABLEVIEW_WIDTH;
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
        [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender {
	FlipsideViewController *controller = [[[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil] autorelease];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
}

@end
