//
//  EasyTableView.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright 2010 Yodel Code. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableView.h"

@interface EasyTableViewCell : UITableViewCell

@end

@implementation EasyTableViewCell

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    UIView *content = [self viewWithTag:CELL_CONTENT_TAG];
    if ([content respondsToSelector:@selector(prepareForReuse)]) {
        [content performSelector:@selector(prepareForReuse)];
    }
}

@end


@implementation EasyTableView
{
	CGFloat		_cellWidthOrHeight;
	NSUInteger	_numItems;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numCols ofWidth:(CGFloat)width {
    if (self = [super initWithFrame:frame]) {
		_numItems			= numCols;
		_cellWidthOrHeight	= width;
		self.orientation = EasyTableViewOrientationHorizontal;
        self.tableView = [UITableView new];
	}
    return self;
}


- (id)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numRows ofHeight:(CGFloat)height {
    if (self = [super initWithFrame:frame]) {
		_numItems			= numRows;
		_cellWidthOrHeight	= height;
		self.orientation = EasyTableViewOrientationVertical;
        self.tableView = [UITableView new];
    }
    return self;
}

#pragma mark - Properties

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    
    self.orientation = _orientation;
    
    _tableView.delegate			= self;
    _tableView.dataSource		= self;
    _tableView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_tableView];
}

- (void)setOrientation:(EasyTableViewOrientation)orientation
{
    _orientation = orientation;
    
    if (_orientation == EasyTableViewOrientationHorizontal) {
        int xOrigin	= (self.bounds.size.width - self.bounds.size.height)/2;
        int yOrigin	= (self.bounds.size.height - self.bounds.size.width)/2;
        self.tableView.frame = CGRectMake(xOrigin, yOrigin, self.bounds.size.height, self.bounds.size.width);
        self.tableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
    }
    else
    {
        self.tableView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
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
	[self setContentOffset:offset animated:NO];
}

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
	CGPoint newOffset = (self.orientation == EasyTableViewOrientationHorizontal) ? CGPointMake(offset.y, offset.x) : offset;
	[self.tableView setContentOffset:newOffset animated:animated];
}


- (CGSize)contentSize {
	CGSize size = self.tableView.contentSize;
	
	if (_orientation == EasyTableViewOrientationHorizontal)
		size = CGSizeMake(size.height, size.width);
	
	return size;
}

#pragma mark - Selection

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	self.selectedIndexPath	= indexPath;
	CGPoint defaultOffset	= CGPointMake(0, indexPath.row  *_cellWidthOrHeight);
	
	[self.tableView setContentOffset:defaultOffset animated:animated];
}


- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
	if (![_selectedIndexPath isEqual:indexPath]) {
		NSIndexPath *oldIndexPath = [_selectedIndexPath copy];
		
		_selectedIndexPath = indexPath;
		
		UITableViewCell *deselectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:oldIndexPath];
		UITableViewCell *selectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
		
		if ([self.delegate respondsToSelector:@selector(easyTableView:selectedView:atIndexPath:deselectedView:)]) {
			UIView *selectedView = [selectedCell viewWithTag:CELL_CONTENT_TAG];
			UIView *deselectedView = [deselectedCell viewWithTag:CELL_CONTENT_TAG];
			
			[self.delegate easyTableView:self
                            selectedView:selectedView
                             atIndexPath:_selectedIndexPath
                          deselectedView:deselectedView];
		}
	}
}

#pragma mark - Multiple Sections

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
        UIView *headerView = [self.delegate easyTableView:self viewForHeaderInSection:section];
		if (_orientation == EasyTableViewOrientationHorizontal)
			return headerView.frame.size.width;
		else 
			return headerView.frame.size.height;
    }
    return 0.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
        UIView *footerView = [self.delegate easyTableView:self viewForFooterInSection:section];
		if (_orientation == EasyTableViewOrientationHorizontal)
			return footerView.frame.size.width;
		else 
			return footerView.frame.size.height;
    }
    return 0.0;
}

- (UIView *)viewToHoldSectionView:(UIView *)sectionView {
	// Enforce proper section header/footer view height abd origin. This is required because
	// of the way UITableView resizes section views on orientation changes.
	if (_orientation == EasyTableViewOrientationHorizontal)
		sectionView.frame = CGRectMake(0, 0, sectionView.frame.size.width, self.frame.size.height);
	
	UIView *rotatedView = [[UIView alloc] initWithFrame:sectionView.frame];
	
	if (_orientation == EasyTableViewOrientationHorizontal) {
		rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	}
	else {
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	[rotatedView addSubview:sectionView];
	return rotatedView;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
		UIView *sectionView = [self.delegate easyTableView:self viewForHeaderInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
		UIView *sectionView = [self.delegate easyTableView:self viewForFooterInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInEasyTableView:)]) {
        return [self.delegate numberOfSectionsInEasyTableView:self];
    }
    return 1;
}

#pragma mark - Location and Paths

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath {
	UIView *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	return [cell viewWithTag:CELL_CONTENT_TAG];
}

- (NSIndexPath *)indexPathForView:(UIView *)view {
	NSArray *visibleCells = [self.tableView visibleCells];
	
	__block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UITableViewCell *cell = obj;
        
		if ([cell viewWithTag:CELL_CONTENT_TAG] == view) {
            indexPath = [self.tableView indexPathForCell:cell];
			*stop = YES;
		}
	}];
	return indexPath;
}

- (CGPoint)offsetForView:(UIView *)view {
	// Get the location of the cell
	CGPoint cellOrigin = [view convertPoint:view.frame.origin toView:self];
	
	// No need to compensate for orientation since all values are already adjusted for orientation
	return cellOrigin;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[self setSelectedIndexPath:indexPath];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(easyTableView:heightOrWidthForCellAtIndexPath:)]) {
        return [self.delegate easyTableView:self heightOrWidthForCellAtIndexPath:indexPath];
    }
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
	if ([self.delegate respondsToSelector:@selector(easyTableView:scrolledToOffset:)])
		[self.delegate easyTableView:self scrolledToOffset:self.contentOffset];
	
	CGFloat amountScrolled	= self.contentOffset.x;
	CGFloat maxScrollAmount = [self contentSize].width - self.bounds.size.width;
	
	if (amountScrolled > maxScrollAmount) amountScrolled = maxScrollAmount;
	if (amountScrolled < 0) amountScrolled = 0;
	
	if ([self.delegate respondsToSelector:@selector(easyTableView:scrolledToFraction:)])
		[self.delegate easyTableView:self scrolledToFraction:amountScrolled/maxScrollAmount];
}


#pragma mark - TableViewDataSource

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
        cell = [[EasyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
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
	}
	[self setCell:cell boundsForOrientation:_orientation];
	
	[self setDataForRotatedView:[cell.contentView viewWithTag:ROTATED_CELL_VIEW_TAG] forIndexPath:indexPath];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger numOfItems = _numItems;
	
	if ([self.delegate respondsToSelector:@selector(numberOfCellsForEasyTableView:inSection:)]) {
		numOfItems = [self.delegate numberOfCellsForEasyTableView:self inSection:section];
		
		// Animate any changes in the number of items
		[tableView beginUpdates];
		[tableView endUpdates];
	}
	
    return numOfItems;
}

#pragma mark - Rotation

- (void)prepareRotatedView:(UIView *)rotatedView {
	UIView *content = [self.delegate easyTableView:self viewForRect:rotatedView.bounds];
	
	// Add a default view if none is provided
	if (content == nil)
		content = [[UIView alloc] initWithFrame:rotatedView.bounds];
	
	content.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	content.tag = CELL_CONTENT_TAG;
	[rotatedView addSubview:content];
}


- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath {
	UIView *content = [rotatedView viewWithTag:CELL_CONTENT_TAG];
	
   [self.delegate easyTableView:self setDataForView:content forIndexPath:indexPath];
}

-(void)reloadData{
    [self.tableView reloadData];
}

@end

