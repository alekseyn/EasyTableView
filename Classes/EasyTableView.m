//
//  EasyTableView.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableView.h"

#define DELETE_THRESHOLD 4.0

@implementation EasyTableView {
	CGPoint centerLocation;
	CGPoint cellLocation;
	UIView *cellSuperview;
}

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

#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if ([self.delegate respondsToSelector:@selector(easyTableViewWillBeginDragging:)])
		[self.delegate easyTableViewWillBeginDragging:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if ([self.delegate respondsToSelector:@selector(easyTableViewDidEndDragging:willDecelerate:)])
		[self.delegate easyTableViewDidEndDragging:self willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	if ([self.delegate respondsToSelector:@selector(easyTableViewWillBeginDecelerating:)])
		[self.delegate easyTableViewWillBeginDecelerating:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if ([self.delegate respondsToSelector:@selector(easyTableViewDidEndDecelerating:)])
		[self.delegate easyTableViewDidEndDecelerating:self];
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(easyTableView:didSelectRowAtIndexPath:)]) {
		[self.delegate easyTableView:self didSelectRowAtIndexPath:indexPath];
	}
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	
	// Cell deletion must be enabled by the EasyTableView owner
	BOOL allowCellDeletion = NO;
	
	if ([self.delegate respondsToSelector:@selector(easyTableViewAllowsCellDeletion:)]) {
		allowCellDeletion = [self.delegate easyTableViewAllowsCellDeletion:self];
	}
	
	if (allowCellDeletion && cell.gestureRecognizers.count == 0) {
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
		panGesture.delegate = self;
		
		[cell addGestureRecognizer:panGesture];
	}
	
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

#pragma mark - Pan gesture recognizer (for cell deletion)

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture {
	
	if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
		UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
		
		CGPoint velocity = [panGesture velocityInView:self.tableView];
		return fabs(velocity.x) > fabs(velocity.y);
	}
	return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
	CGPoint translation = [gesture translationInView:self.superview];
	
	CGRect oversizedRect = CGRectInset(gesture.view.frame, -DELETE_THRESHOLD, -DELETE_THRESHOLD);
	BOOL doesIntersect = CGRectIntersectsRect(oversizedRect, self.frame);
	
	// Notify delegate that cell deletion is in process. It's helpful
	// to know what's going on in cases where an EasyTableView may be
	// hidden from sight if there is no user activity.
	[self informDelegateOfPendingCellDeletion];
	
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan: {
			
			// Save current state in case a cell deletion does not materialize
			cellLocation = CGPointMake(gesture.view.center.x, gesture.view.center.y);
			cellSuperview = gesture.view.superview;
			
			// Move the cell view to EasyTableView's superview
			centerLocation = [cellSuperview convertPoint:cellLocation toView:self.superview];
			[self.superview addSubview:gesture.view];
			
			if (self.orientation == EasyTableViewOrientationHorizontal) {
				gesture.view.transform = CGAffineTransformRotate(gesture.view.transform, -M_PI/2);
			}
			gesture.view.center = centerLocation;
			break;
		}
			
		case UIGestureRecognizerStateChanged: {
			gesture.view.center = CGPointMake(centerLocation.x + translation.x, centerLocation.y + translation.y);
			
			// Provide an opportunity for any UI updates
			[self informDelegateCell:(UITableViewCell *)gesture.view deletionIsEminent:!doesIntersect];
			break;
		}
			
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded: {
			gesture.view.center = CGPointMake(centerLocation.x + translation.x, centerLocation.y + translation.y);
			
			// Check to see if the translated cell view still intersects with the EasyTableView.
			// If it does, return it to it's original position. If it doesn't, delete that cell
			// from the table view, and call the deletion delegate method.
			
			if (doesIntersect) {
				// Return to original position
				
				[UIView animateWithDuration: 0.3
									  delay: 0.0
					 usingSpringWithDamping: 0.5
					  initialSpringVelocity: 0.5
									options: UIViewAnimationOptionCurveEaseInOut
								 animations: ^{
					gesture.view.center = centerLocation;
					
				} completion:^(BOOL finished) {
					
					// Restore proper orientation
					if (self.orientation == EasyTableViewOrientationHorizontal) {
						gesture.view.transform = CGAffineTransformRotate(gesture.view.transform, M_PI/2);
					}
					// Provide an opportunity for any UI updates
					[self informDelegateCell:(UITableViewCell *)gesture.view deletionIsEminent:NO];
					
					// Reinsert into orginal layer of view hierarchy
					[cellSuperview addSubview:gesture.view];
					gesture.view.center = cellLocation;
				}];
			}
			else {
				// Delete the cell by animating the deletion, removing it from the tableview,
				// and sending a message to the delegate method to update it's data store
				NSIndexPath *deletedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)gesture.view];
				
				[UIView animateWithDuration:0.3 animations:^{
					
					CGFloat scaleFactor		= 0.1;
					gesture.view.transform	= CGAffineTransformMakeScale(scaleFactor, scaleFactor);
					gesture.view.alpha		= 0.0;
					
					if ([self.delegate respondsToSelector:@selector(easyTableView:didDeleteCellAtIndexPath:)]) {
						[self.delegate easyTableView:self didDeleteCellAtIndexPath:deletedIndexPath];
					}
					
				} completion:^(BOOL finished) {
					// Restore the cell for reuse
					gesture.view.transform = CGAffineTransformIdentity;
					
					// Provide an opportunity for any UI updates
					[self informDelegateCell:(UITableViewCell *)gesture.view deletionIsEminent:NO];
					
					// Delete the cell only after animation has completed.
					// Otherwise cell could disappear prematurely.
					
					[self.tableView beginUpdates];
					[self.tableView deleteRowsAtIndexPaths:@[deletedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
					[self.tableView endUpdates];
				}];
			}
			break;
		}
			
		default:
			break;
	}
}

- (void)informDelegateOfPendingCellDeletion {
	if ([self.delegate respondsToSelector:@selector(easyTableViewHasPendingCellDeletion:)]) {
		[self.delegate easyTableViewHasPendingCellDeletion:self];
	}
}

- (void)informDelegateCell:(UITableViewCell *)cell deletionIsEminent:(BOOL)eminent {
	if ([self.delegate respondsToSelector:@selector(easyTableView:cell:deletionIsEminent:)]) {
		[self.delegate easyTableView:self cell:cell deletionIsEminent:eminent];
	}
}

@end

