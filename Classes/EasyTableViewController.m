//
//  EasyTableViewController.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableViewController.h"
#import "EasyTableView.h"

//#define SHOW_MULTIPLE_SECTIONS		1		// If commented out, multiple sections with header and footer views are NOT shown

#define HORIZONTAL_TABLEVIEW_HEIGHT	140
#define VERTICAL_TABLEVIEW_WIDTH	180
#define CELL_BACKGROUND_COLOR		[[UIColor greenColor] colorWithAlphaComponent:0.15]

#define BORDER_VIEW_TAG				10

#ifdef SHOW_MULTIPLE_SECTIONS
	#define NUM_OF_CELLS			10
	#define NUM_OF_SECTIONS			2
#else
	#define NUM_OF_CELLS			21
	#define NUM_OF_SECTIONS			1
#endif

@implementation EasyTableViewController {
    NSIndexPath *selectedVerticalIndexPath;
    NSIndexPath *selectedHorizontalIndexPath;
	NSMutableArray *horizontalDataStore;
	NSMutableArray *verticalDataStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupVerticalDataStore];
	[self setupHorizontalDataStore];
	
	[self setupVerticalView];
	[self setupHorizontalView];
}

#pragma mark - Data Stores

- (void)setupVerticalDataStore {
	verticalDataStore = [[NSMutableArray alloc] initWithCapacity:NUM_OF_CELLS];
	
	for (int i = 0; i < NUM_OF_CELLS; i++) {
		// Sample data is just a sequence of NSNumber objects
		[verticalDataStore addObject:@(i)];
	}
}

- (void)setupHorizontalDataStore {
	horizontalDataStore = [[NSMutableArray alloc] initWithCapacity:NUM_OF_CELLS];

	for (int i = 0; i < NUM_OF_CELLS; i++) {
		// Sample data is just a sequence of NSNumber objects
		[horizontalDataStore addObject:@(i)];
	}
}

#pragma mark - EasyTableView Initialization

- (void)setupHorizontalView {
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	
	CGRect frameRect	= CGRectMake(0, screenSize.height - HORIZONTAL_TABLEVIEW_HEIGHT, screenSize.width, HORIZONTAL_TABLEVIEW_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect ofWidth:VERTICAL_TABLEVIEW_WIDTH];
	self.horizontalView = view;
	
	self.horizontalView.delegate					= self;
	self.horizontalView.tableView.backgroundColor	= [UIColor clearColor];
	self.horizontalView.tableView.allowsSelection	= YES;
	self.horizontalView.tableView.separatorColor	= [UIColor darkGrayColor];
	self.horizontalView.autoresizingMask			= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview:self.horizontalView];
}


- (void)setupVerticalView {
	CGSize screenSize = [UIScreen mainScreen].bounds.size;

	CGRect frameRect	= CGRectMake(screenSize.width - VERTICAL_TABLEVIEW_WIDTH, 0, VERTICAL_TABLEVIEW_WIDTH, screenSize.height - HORIZONTAL_TABLEVIEW_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect ofHeight:HORIZONTAL_TABLEVIEW_HEIGHT];
	self.verticalView	= view;
	
	self.verticalView.delegate					= self;
	self.verticalView.tableView.backgroundColor	= [UIColor clearColor];
	self.verticalView.tableView.allowsSelection	= YES;
	self.verticalView.tableView.separatorColor	= [[UIColor blackColor] colorWithAlphaComponent:0.1];
	self.verticalView.autoresizingMask			= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
	
	[self.view addSubview:self.verticalView];
}


#pragma mark - Utility Methods

- (void)borderIsSelected:(BOOL)selected forView:(UIView *)view {
	UIImageView *borderView		= (UIImageView *)[view viewWithTag:BORDER_VIEW_TAG];
	NSString *borderImageName	= (selected) ? @"selected_border.png" : @"image_border.png";
	borderView.image			= [UIImage imageNamed:borderImageName];
}

- (void)indicateView:(UIView *)view pendingDeletion:(BOOL)pendingDeletion {
	if (pendingDeletion) {
		view.layer.borderColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5].CGColor;
		view.layer.borderWidth = 8.0;
	}
	else {
		view.layer.borderColor = nil;
		view.layer.borderWidth = 0.0;
	}
}

- (UIView *)viewForIndexPath:(NSIndexPath *)indexPath easyTableView:(EasyTableView *)tableView {
	UITableViewCell * cell	= [tableView.tableView cellForRowAtIndexPath:indexPath];
	return cell.contentView.subviews[0];
}

#pragma mark - EasyTableViewDelegate

// Required delegate method
- (NSInteger)easyTableView:(EasyTableView *)easyTableView numberOfRowsInSection:(NSInteger)section {
	if (easyTableView == self.horizontalView) {
		return horizontalDataStore.count;
	}
	else {
		return verticalDataStore.count;
	}
}

// This required delegate method supports both example views
- (UITableViewCell *)easyTableView:(EasyTableView *)easyTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EasyTableViewCell";
	
    UITableViewCell *cell = [easyTableView.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel *label;
	
    if (cell == nil) {
		// Create a new table view cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		cell.contentView.backgroundColor = CELL_BACKGROUND_COLOR;
		cell.backgroundColor = [UIColor clearColor];
		
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
	if (easyTableView == _horizontalView) {
		label.text = [[horizontalDataStore objectAtIndex:indexPath.row] stringValue];
	}
	else {
		label.text = [[verticalDataStore objectAtIndex:indexPath.row] stringValue];
	}
	
	// selectedIndexPath can be nil so we need to test for that condition
	
    NSIndexPath * selectedIndexPath = (easyTableView == self.verticalView) ? selectedVerticalIndexPath : selectedHorizontalIndexPath;
	BOOL isSelected = selectedIndexPath ? ([selectedIndexPath compare:indexPath] == NSOrderedSame) : NO;
	[self borderIsSelected:isSelected forView:label];
    
    return cell;
}

// Optional delegate to track the selection of a particular cell

- (void)easyTableView:(EasyTableView *)easyTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *__strong *selectedIndexPath = (easyTableView == self.verticalView) ? &selectedVerticalIndexPath : &selectedHorizontalIndexPath;
    
    if (selectedIndexPath)
		[self borderIsSelected:NO forView:[self viewForIndexPath:*selectedIndexPath easyTableView:easyTableView]];
    
    *selectedIndexPath = indexPath;
    UILabel * label	= (UILabel *)[self viewForIndexPath:*selectedIndexPath easyTableView:easyTableView];
    [self borderIsSelected:YES forView:label];
	
	self.bigLabel.text	= label.text;
}

#pragma mark - Deletion methods

- (BOOL)easyTableViewAllowsCellDeletion:(EasyTableView *)easyTableView {
	// The only reason cell deletion is not used in this example with multiple sections,
	// is because the data store is not set up to support multiple sections.
	return (NUM_OF_SECTIONS == 1);
}

- (void)easyTableView:(EasyTableView *)easyTableView didDeleteCellAtIndexPath:(NSIndexPath *)indexPath {
	if (easyTableView == self.horizontalView) {
		[horizontalDataStore removeObjectAtIndex:indexPath.row];
	}
	else {
		[verticalDataStore removeObjectAtIndex:indexPath.row];
	}
}

- (void)easyTableView:(EasyTableView *)easyTableView cell:(UITableViewCell *)cell deletionIsEminent:(BOOL)eminent {
	[self indicateView:cell pendingDeletion:eminent];
}

#pragma mark - Optional EasyTableView delegate methods for section headers and footers

#ifdef SHOW_MULTIPLE_SECTIONS

// Delivers the number of sections in the TableView
- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView {
    return NUM_OF_SECTIONS;
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
