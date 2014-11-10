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

#define SHOW_MULTIPLE_SECTIONS		1		// If commented out, multiple sections with header and footer views are not shown

#define PORTRAIT_WIDTH				768
#define LANDSCAPE_HEIGHT			(1024-20)
#define HORIZONTAL_TABLEVIEW_HEIGHT	140
#define VERTICAL_TABLEVIEW_WIDTH	180
#define TABLE_BACKGROUND_COLOR		[UIColor clearColor]

#define BORDER_VIEW_TAG				10

#ifdef SHOW_MULTIPLE_SECTIONS
	#define NUM_OF_CELLS			10
	#define NUM_OF_SECTIONS			2
#else
	#define NUM_OF_CELLS			21
#endif

@implementation EasyTableViewController
{
    NSIndexPath * _selectedVerticalIndexPath;
    NSIndexPath * _selectedHorizontalIndexPath;
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


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - EasyTableView Initialization

- (void)setupHorizontalView {
	CGRect frameRect	= CGRectMake(0, LANDSCAPE_HEIGHT - HORIZONTAL_TABLEVIEW_HEIGHT, PORTRAIT_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect ofWidth:VERTICAL_TABLEVIEW_WIDTH];
	self.horizontalView = view;
	
	self.horizontalView.delegate						= self;
	self.horizontalView.tableView.backgroundColor	= TABLE_BACKGROUND_COLOR;
	self.horizontalView.tableView.allowsSelection	= YES;
	self.horizontalView.tableView.separatorColor		= [UIColor darkGrayColor];
	self.horizontalView.cellBackgroundColor			= [UIColor darkGrayColor];
	self.horizontalView.autoresizingMask				= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview:self.horizontalView];
}


- (void)setupVerticalView {
	CGRect frameRect	= CGRectMake(PORTRAIT_WIDTH - VERTICAL_TABLEVIEW_WIDTH, 0, VERTICAL_TABLEVIEW_WIDTH, LANDSCAPE_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect ofHeight:HORIZONTAL_TABLEVIEW_HEIGHT];
	self.verticalView	= view;
	
	self.verticalView.delegate					= self;
	self.verticalView.tableView.backgroundColor	= TABLE_BACKGROUND_COLOR;
	self.verticalView.tableView.allowsSelection	= YES;
	self.verticalView.tableView.separatorColor	= [[UIColor blackColor] colorWithAlphaComponent:0.1];
	self.verticalView.cellBackgroundColor		= [[UIColor blackColor] colorWithAlphaComponent:0.1];
	self.verticalView.autoresizingMask			= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Allow verticalView to scroll up and completely clear the horizontalView
	self.verticalView.tableView.contentInset		= UIEdgeInsetsMake(0, 0, HORIZONTAL_TABLEVIEW_HEIGHT, 0);
	
	[self.view addSubview:self.verticalView];
}


#pragma mark - Utility Methods

- (void)borderIsSelected:(BOOL)selected forView:(UIView *)view {
	UIImageView *borderView		= (UIImageView *)[view viewWithTag:BORDER_VIEW_TAG];
	NSString *borderImageName	= (selected) ? @"selected_border.png" : @"image_border.png";
	borderView.image			= [UIImage imageNamed:borderImageName];
}


#pragma mark - EasyTableViewDelegate

// These delegate methods support both example views - first delegate method creates the necessary views
- (UITableViewCell *)easyTableView:(EasyTableView *)easyTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EasyTableViewCell";
    UITableViewCell *cell = [easyTableView.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel *label;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect labelRect		= CGRectMake(10, 10, cell.contentView.frame.size.width-20, cell.contentView.frame.size.height-20);
        label        			= [[UILabel alloc] initWithFrame:labelRect];
        label.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
        label.textAlignment		= UITextAlignmentCenter;
#else
        label.textAlignment		= NSTextAlignmentCenter;
#endif
        label.textColor			= [UIColor whiteColor];
        label.font				= [UIFont boldSystemFontOfSize:60];
        
        // Use a different color for the two different examples
        if (easyTableView == self.horizontalView)
            label.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
        else
            label.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
        
        UIImageView *borderView		= [[UIImageView alloc] initWithFrame:label.bounds];
        borderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        borderView.tag				= BORDER_VIEW_TAG;
        
        [label addSubview:borderView];

        [cell.contentView addSubview:label];
    }
    else {
        label = cell.contentView.subviews[0];
    }
    
    // Second delegate populates the views with data from a data source
    label.text		= [NSString stringWithFormat:@"%@", @(indexPath.row)];
	
	// selectedIndexPath can be nil so we need to test for that condition
    NSIndexPath * selectedIndexPath = (easyTableView == self.verticalView) ? _selectedVerticalIndexPath : _selectedHorizontalIndexPath;
	BOOL isSelected = selectedIndexPath ? ([selectedIndexPath compare:indexPath] == NSOrderedSame) : NO;
	[self borderIsSelected:isSelected forView:label];
    
    return cell;
}

// Optional delegate to track the selection of a particular cell

- (UIView *)viewForIndexPath:(NSIndexPath *)indexPath easyTableView:(EasyTableView *)tableView
{
    UITableViewCell * cell	= [tableView.tableView cellForRowAtIndexPath:indexPath];
    return cell.contentView.subviews[0];
}

- (void)easyTableView:(EasyTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *__strong* selectedIndexPath = (tableView == self.verticalView) ? &_selectedVerticalIndexPath : &_selectedHorizontalIndexPath;
    
    if (selectedIndexPath)
		[self borderIsSelected:NO forView:[self viewForIndexPath:*selectedIndexPath easyTableView:tableView]];
    
    *selectedIndexPath = indexPath;
    UILabel * label	= (UILabel *)[self viewForIndexPath:*selectedIndexPath easyTableView:tableView];
    [self borderIsSelected:YES forView:label];
	
	self.bigLabel.text	= label.text;
}

#pragma mark - Optional EasyTableView delegate methods for section headers and footers

#ifdef SHOW_MULTIPLE_SECTIONS

// Delivers the number of sections in the TableView
- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView{
    return NUM_OF_SECTIONS;
}

// Delivers the number of cells in each section, this must be implemented if numberOfSectionsInEasyTableView is implemented
- (NSInteger)easyTableView:(EasyTableView *)easyTableView numberOfRowsInSection:(NSInteger)section {
    return NUM_OF_CELLS;
}

// The height of the header section view MUST be the same as your HORIZONTAL_TABLEVIEW_HEIGHT (horizontal EasyTableView only)
- (UIView *)easyTableView:(EasyTableView*)easyTableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
	label.text = @"HEADER";
	label.textColor = [UIColor whiteColor];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
	label.textAlignment		= UITextAlignmentCenter;
#else
	label.textAlignment		= NSTextAlignmentCenter;
#endif
   
	if (easyTableView == self.horizontalView) {
		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
	}
	if (easyTableView == self.verticalView) {
		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
	}

    switch (section) {
        case 0:
            label.backgroundColor = [UIColor redColor];
            break;
        default:
            label.backgroundColor = [UIColor blueColor];
            break;
    }
    return label;
}

// The height of the footer section view MUST be the same as your HORIZONTAL_TABLEVIEW_HEIGHT (horizontal EasyTableView only)
- (UIView *)easyTableView:(EasyTableView*)easyTableView viewForFooterInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
	label.text = @"FOOTER";
	label.textColor = [UIColor yellowColor];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
	label.textAlignment		= UITextAlignmentCenter;
#else
	label.textAlignment		= NSTextAlignmentCenter;
#endif
	label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
    
	if (easyTableView == self.horizontalView) {
		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
	}
	if (easyTableView == self.verticalView) {
		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
	}
	
    switch (section) {
        case 0:
            label.backgroundColor = [UIColor purpleColor];
            break;
        default:
            label.backgroundColor = [UIColor brownColor];
            break;
    }
    
    return label;
}

#endif

@end
