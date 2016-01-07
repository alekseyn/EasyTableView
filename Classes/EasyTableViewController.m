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
#define SHOW_VERTICAL_TABLEVIEW		NO		// EasyTableView API works for both horizontal and vertical placement
#define SHOW_HORIZONTAL_TABLEVIEW	YES

#define HORIZONTAL_TABLEVIEW_HEIGHT	140
#define VERTICAL_TABLEVIEW_WIDTH	180
#define TABLE_BACKGROUND_COLOR		[UIColor clearColor]
#define CELL_BACKGROUND_COLOR		[[UIColor greenColor] colorWithAlphaComponent:0.15]

#define BORDER_VIEW_TAG				10

#ifdef SHOW_MULTIPLE_SECTIONS
	#define NUM_OF_CELLS			10
	#define NUM_OF_SECTIONS			2
#else
	#define NUM_OF_CELLS			21
#endif

@implementation EasyTableViewController {
    NSIndexPath *_selectedVerticalIndexPath;
    NSIndexPath *_selectedHorizontalIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (SHOW_HORIZONTAL_TABLEVIEW) {
		[self setupHorizontalView];
	}
	
	if (SHOW_VERTICAL_TABLEVIEW) {
		// Shows how the same EasyTableView can be used vertically as well
		[self setupVerticalView];
	}
	else {
		// Stretch the storyboard EasyTableView to full width since we have the full screen now
		
		CGRect easyTableViewFrame		= self.storyboardView.frame;
		easyTableViewFrame.size.width	= [UIScreen mainScreen].bounds.size.width;
		
		self.storyboardView.frame = easyTableViewFrame;
	}
	
	// This must be set because initWithFrame for EasyTableView cannot be called when loaded from a storyboard
    self.storyboardView.orientation = EasyTableViewOrientationHorizontal;
}

#pragma mark - EasyTableView Initialization

- (void)setupHorizontalView {
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	
	CGRect frameRect	= CGRectMake(0, screenSize.height - HORIZONTAL_TABLEVIEW_HEIGHT, screenSize.width, HORIZONTAL_TABLEVIEW_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect ofWidth:VERTICAL_TABLEVIEW_WIDTH];
	self.horizontalView = view;
	
	self.horizontalView.delegate					= self;
	self.horizontalView.tableView.backgroundColor	= TABLE_BACKGROUND_COLOR;
	self.horizontalView.tableView.allowsSelection	= YES;
	self.horizontalView.tableView.separatorColor	= [UIColor darkGrayColor];
	self.horizontalView.autoresizingMask			= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview:self.horizontalView];
}


- (void)setupVerticalView {
	CGSize screenSize = [UIScreen mainScreen].bounds.size;

	CGRect frameRect	= CGRectMake(screenSize.width - VERTICAL_TABLEVIEW_WIDTH, 0, VERTICAL_TABLEVIEW_WIDTH, screenSize.height);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect ofHeight:HORIZONTAL_TABLEVIEW_HEIGHT];
	self.verticalView	= view;
	
	self.verticalView.delegate					= self;
	self.verticalView.tableView.backgroundColor	= TABLE_BACKGROUND_COLOR;
	self.verticalView.tableView.allowsSelection	= YES;
	self.verticalView.tableView.separatorColor	= [[UIColor blackColor] colorWithAlphaComponent:0.1];
	self.verticalView.autoresizingMask			= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Allow verticalView to scroll up and completely clear the horizontalView
	self.verticalView.tableView.contentInset	= UIEdgeInsetsMake(0, 0, HORIZONTAL_TABLEVIEW_HEIGHT, 0);
	
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
		// Create a new table view cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		cell.contentView.backgroundColor = CELL_BACKGROUND_COLOR;
		cell.backgroundColor = TABLE_BACKGROUND_COLOR;
		
        CGRect labelRect		= CGRectMake(10, 10, cell.contentView.frame.size.width-20, cell.contentView.frame.size.height-20);
        label        			= [[UILabel alloc] initWithFrame:labelRect];
        label.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        label.textAlignment		= NSTextAlignmentCenter;
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
    
    // Populate the views with data from a data source
    label.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
	
	// selectedIndexPath can be nil so we need to test for that condition
	
    NSIndexPath * selectedIndexPath = (easyTableView == self.verticalView) ? _selectedVerticalIndexPath : _selectedHorizontalIndexPath;
	BOOL isSelected = selectedIndexPath ? ([selectedIndexPath compare:indexPath] == NSOrderedSame) : NO;
	[self borderIsSelected:isSelected forView:label];
    
    return cell;
}

// Optional delegate to track the selection of a particular cell

- (UIView *)viewForIndexPath:(NSIndexPath *)indexPath easyTableView:(EasyTableView *)tableView {
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
- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView {
    return NUM_OF_SECTIONS;
}

// Delivers the number of cells in each section, this must be implemented if numberOfSectionsInEasyTableView is implemented
- (NSInteger)easyTableView:(EasyTableView *)easyTableView numberOfRowsInSection:(NSInteger)section {
    return NUM_OF_CELLS;
}

// The height of the header section view MUST be the same as your HORIZONTAL_TABLEVIEW_HEIGHT (horizontal EasyTableView only)
- (UIView *)easyTableView:(EasyTableView*)easyTableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label		= [[UILabel alloc] init];
	label.text			= @"HEADER";
	label.textColor		= [UIColor whiteColor];
	label.textAlignment	= NSTextAlignmentCenter;
   
	if (easyTableView == self.verticalView) {
		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
	}
    else {
        label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
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
	label.text			= @"FOOTER";
	label.textColor		= [UIColor yellowColor];
	label.textAlignment	= NSTextAlignmentCenter;
	label.frame			= CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
    
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
