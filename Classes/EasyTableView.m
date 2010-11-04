//
//  EasyTableView.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright 2010 Yodel Code LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableView.h"

#define ANIMATION_DURATION	0.30

@interface EasyTableView (PrivateMethods)
- (void)createTableWithOrienation:(EasyTableViewOrientation)orientation;
- (void)prepareRotatedView:(UIView *)rotatedView;
- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation EasyTableView

@synthesize delegate, cellBackgroundColor;
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize orientation = _orientation;
@synthesize numberOfCells = _numItems;

#pragma mark -
#pragma mark Initialization

- (void)dealloc {
	[cellBackgroundColor release];
	[_selectedIndexPath release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numCols ofWidth:(CGFloat)width {
    if (self = [super initWithFrame:frame]) {
		_numItems			= numCols;
		_cellWidthOrHeight	= width;

		[self createTableWithOrienation:EasyTableViewOrientationHorizontal];
	}
    return self;
}


- (id)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numRows ofHeight:(CGFloat)height {
    if (self = [super initWithFrame:frame]) {
		_numItems			= numRows;
		_cellWidthOrHeight	= height;
		
		[self createTableWithOrienation:EasyTableViewOrientationVertical];
    }
    return self;
}


- (void)createTableWithOrienation:(EasyTableViewOrientation)orientation {
	// Save the orientation so that the table view cell knows how to set itself up
	_orientation = orientation;
	
	UITableView *tableView;
	if (orientation == EasyTableViewOrientationHorizontal) {
		int xOrigin	= (self.bounds.size.width - self.bounds.size.height)/2;
		int yOrigin	= (self.bounds.size.height - self.bounds.size.width)/2;
		tableView	= [[UITableView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, self.bounds.size.height, self.bounds.size.width)];
	}
	else
		tableView	= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];

	tableView.tag				= TABLEVIEW_TAG;
	tableView.delegate			= self;
	tableView.dataSource		= self;
	tableView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Rotate the tableView 90 degrees so that it is horizontal
	if (orientation == EasyTableViewOrientationHorizontal)
		tableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
	
	tableView.showsVerticalScrollIndicator	 = NO;
	tableView.showsHorizontalScrollIndicator = NO;
	
	[self addSubview:tableView];
	[tableView release];
}


#pragma mark -
#pragma mark Properties

- (UITableView *)tableView {
	return (UITableView *)[self viewWithTag:TABLEVIEW_TAG];
}


- (NSArray *)visibleViews {
	NSArray *visibleCells = [self.tableView visibleCells];
	NSMutableArray *visibleViews = [NSMutableArray arrayWithCapacity:[visibleCells count]];
	
	for (UIView *aView in visibleCells) {
		[visibleViews addObject:[aView viewWithTag:CELL_CONTENT_TAG]];
	}
	return visibleViews;
}


- (CGPoint)contentOffset {
	CGPoint offset = self.tableView.contentOffset;

	if (_orientation == EasyTableViewOrientationHorizontal)
		offset = CGPointMake(offset.y, offset.x);

	return offset;
}


- (void)setContentOffset:(CGPoint)offset {
	if (_orientation == EasyTableViewOrientationHorizontal)
		self.tableView.contentOffset = CGPointMake(offset.y, offset.x);
	else
		self.tableView.contentOffset = offset;
}


- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
	CGPoint newOffset;
	
	if (_orientation == EasyTableViewOrientationHorizontal) {
		newOffset = CGPointMake(offset.y, offset.x);
	}
	else {
		newOffset = offset;
	}
	[self.tableView setContentOffset:newOffset animated:animated];
}


#pragma mark -
#pragma mark Selection

- (void)selectCellAtIndex:(NSUInteger)index animated:(BOOL)animated {
	self.selectedIndexPath	= [NSIndexPath indexPathForRow:index inSection:0];
	CGPoint defaultOffset	= CGPointMake(0, index  *_cellWidthOrHeight);
	
	[self.tableView setContentOffset:defaultOffset animated:animated];
}


- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
	if (![_selectedIndexPath isEqual:indexPath]) {
		NSIndexPath *oldIndexPath = [_selectedIndexPath copy];
		
		[_selectedIndexPath release];
		_selectedIndexPath = [indexPath retain];
		
		UITableViewCell *deselectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:oldIndexPath];
		UITableViewCell *selectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];

		if ([delegate respondsToSelector:@selector(easyTableView:selectedView:atIndex:deselectedView:)]) {
			UIView *selectedView = [selectedCell viewWithTag:CELL_CONTENT_TAG];
			UIView *deselectedView = [deselectedCell viewWithTag:CELL_CONTENT_TAG];
			
			[delegate easyTableView:self
					   selectedView:selectedView
							atIndex:_selectedIndexPath.row
					 deselectedView:deselectedView];
		}
		[oldIndexPath release];
	}
}


- (UIView *)viewAtIndex:(NSUInteger)index {
	NSIndexPath *indexPath	= [NSIndexPath indexPathForRow:index inSection:0];
	UIView *cell			= [self.tableView cellForRowAtIndexPath:indexPath];
	
	return [cell viewWithTag:CELL_CONTENT_TAG];
}


#pragma mark -
#pragma mark Location

- (CGPoint)offsetForView:(UIView *)cell {
	// Get the location of the cell
	CGPoint cellOrigin = [cell convertPoint:cell.frame.origin toView:self];
	
	// No need to compensate for orientation since all values are already adjusted for orientation
	return cellOrigin;
}


#pragma mark -
#pragma mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[self setSelectedIndexPath:indexPath];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return _cellWidthOrHeight;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Don't allow the currently selected cell to be selectable
	if ([_selectedIndexPath isEqual:indexPath]) {
		return nil;
	}
	return indexPath;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if ([delegate respondsToSelector:@selector(easyTableView:scrolledToOffset:)])
		 [delegate easyTableView:self scrolledToOffset:self.contentOffset];
}

		 
#pragma mark -
#pragma mark TableViewDataSource

- (void)setCell:(UITableViewCell *)cell boundsForOrientation:(EasyTableViewOrientation)theOrientation {
	if (theOrientation == EasyTableViewOrientationHorizontal) {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.height, _cellWidthOrHeight);
	}
	else {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.width, _cellWidthOrHeight);
	}
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EasyTableViewCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		[self setCell:cell boundsForOrientation:_orientation];
		
		cell.contentView.frame = cell.bounds;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// Add a view to the cell's content view that is rotated to compensate for the table view rotation
		CGRect viewRect;
		if (_orientation == EasyTableViewOrientationHorizontal)
			viewRect = CGRectMake(0, 0, cell.bounds.size.height, cell.bounds.size.width);
		else
			viewRect = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
		
		UIView *rotatedView				= [[UIView alloc] initWithFrame:viewRect];
		rotatedView.tag					= ROTATED_CELL_VIEW_TAG;
		rotatedView.center				= cell.contentView.center;
		rotatedView.backgroundColor		= self.cellBackgroundColor;
		
		if (_orientation == EasyTableViewOrientationHorizontal) {
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		}
		else 
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

		// We want to make sure any expanded content is not visible when the cell is deselected
		rotatedView.clipsToBounds = YES;
		
		// Prepare and add the custom subviews
		[self prepareRotatedView:rotatedView];
		
		[cell.contentView addSubview:rotatedView];
		[rotatedView release];
	}
	[self setCell:cell boundsForOrientation:_orientation];

	[self setDataForRotatedView:[cell.contentView viewWithTag:ROTATED_CELL_VIEW_TAG] forIndexPath:indexPath];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger numOfItems = _numItems;
	
	if ([delegate respondsToSelector:@selector(numberOfCellsForEasyTableView:)]) {
		numOfItems = [delegate numberOfCellsForEasyTableView:self];
		
		// Animate any changes in the number of items
		[tableView beginUpdates];
		[tableView endUpdates];
	}
	
    return numOfItems;
}

#pragma mark -
#pragma mark Rotation

- (void)prepareRotatedView:(UIView *)rotatedView {
	UIView *content = [delegate easyTableView:self viewForRect:rotatedView.bounds];
	
	// Add a default view if none is provided
	if (content == nil)
		content = [[[UIView alloc] initWithFrame:rotatedView.bounds] autorelease];

	content.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	content.tag = CELL_CONTENT_TAG;
	[rotatedView addSubview:content];
}


- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath {
	UIView *content = [rotatedView viewWithTag:CELL_CONTENT_TAG];
	[delegate easyTableView:self setDataForView:content forIndex:indexPath.row];
}


@end

