//
//  EasyTableView.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright 2010 Yodel Code. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableView.h"


@implementation EasyTableView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame ofWidth:(CGFloat)width {
    if (self = [super initWithFrame:frame]) {
		self.orientation			= EasyTableViewOrientationHorizontal;
        self.tableView				= [UITableView new];
        self.tableView.rowHeight	= width;
	}
    return self;
}


- (id)initWithFrame:(CGRect)frame ofHeight:(CGFloat)height {
    if (self = [super initWithFrame:frame]) {
		self.orientation			= EasyTableViewOrientationVertical;
        self.tableView				= [UITableView new];
        self.tableView.rowHeight	= height;
    }
    return self;
}

#pragma mark - Properties

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    
    self.orientation = _orientation;
    
    _tableView.delegate			= self;
    _tableView.dataSource		= self;
    _tableView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    [self addSubview:_tableView];
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    
    self.orientation = _orientation;
}

- (void)setOrientation:(EasyTableViewOrientation)orientation {
    _orientation = orientation;
    
    if (!self.tableView)
        return;
    
    self.tableView.transform	= CGAffineTransformIdentity;
    self.tableView.frame		= CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    if (_orientation == EasyTableViewOrientationHorizontal) {
        int xOrigin	= (self.bounds.size.width - self.bounds.size.height) / 2.0;
        int yOrigin	= (self.bounds.size.height - self.bounds.size.width) / 2.0;
		
        self.tableView.frame		= CGRectMake(xOrigin, yOrigin, self.bounds.size.height, self.bounds.size.width);
        self.tableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
		
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.bounds.size.height - 7.0);
    }
}

- (CGPoint)contentOffset {
	CGPoint offset = self.tableView.contentOffset;
	
	if (self.orientation == EasyTableViewOrientationHorizontal)
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
	
	if (self.orientation == EasyTableViewOrientationHorizontal)
		size = CGSizeMake(size.height, size.width);
	
	return size;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInEasyTableView:)]) {
        return [self.delegate numberOfSectionsInEasyTableView:self];
    }
    return 1;
}

- (void)reload {
	[self.tableView reloadData];
}

#pragma mark - Footers and Headers

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
        UIView *headerView = [self.delegate easyTableView:self viewForHeaderInSection:section];
		
		if (self.orientation == EasyTableViewOrientationHorizontal)
			return headerView.frame.size.width;
		else 
			return headerView.frame.size.height;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
        UIView *footerView = [self.delegate easyTableView:self viewForFooterInSection:section];
		
		if (self.orientation == EasyTableViewOrientationHorizontal)
			return footerView.frame.size.width;
		else 
			return footerView.frame.size.height;
    }
    return 0.0;
}

- (UIView *)viewToHoldSectionView:(UIView *)sectionView {
	// Enforce proper section header/footer view height abd origin. This is required because
	// of the way UITableView resizes section views on orientation changes.
	if (self.orientation == EasyTableViewOrientationHorizontal)
		sectionView.frame = CGRectMake(0, 0, sectionView.frame.size.width, self.frame.size.height);
	
	UIView *rotatedView = [[UIView alloc] initWithFrame:sectionView.frame];
	
	if (self.orientation == EasyTableViewOrientationHorizontal) {
		rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	}
	else {
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	[rotatedView addSubview:sectionView];
	return rotatedView;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
		UIView *sectionView = [self.delegate easyTableView:self viewForHeaderInSection:section];
		
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
		UIView *sectionView = [self.delegate easyTableView:self viewForFooterInSection:section];
		
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(easyTableView:didSelectRowAtIndexPath:)]) {
        [self.delegate easyTableView:self didSelectRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(easyTableView:heightOrWidthForCellAtIndexPath:)]) {
        return [self.delegate easyTableView:self heightOrWidthForCellAtIndexPath:indexPath];
    }
    return tableView.rowHeight;
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.delegate easyTableView:self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [self.delegate easyTableView:self cellForRowAtIndexPath:indexPath];
    
    // Rotate if needed
    if ((self.orientation == EasyTableViewOrientationHorizontal) &&
        CGAffineTransformEqualToTransform(cell.contentView.transform, CGAffineTransformIdentity)) {
        int xOrigin	= (cell.bounds.size.width - cell.bounds.size.height) / 2.0;
        int yOrigin	= (cell.bounds.size.height - cell.bounds.size.width) / 2.0;
		
        cell.contentView.frame		= CGRectMake(xOrigin, yOrigin, cell.bounds.size.height, cell.bounds.size.width);
        cell.contentView.transform	= CGAffineTransformMakeRotation(M_PI/2.0);
    }
    return cell;
}

@end

