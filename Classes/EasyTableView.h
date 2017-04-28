//
//  EasyTableView.h
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//
//
/* ===========================================================================
 
 NOTES:	EasyTableView addresses two concerns. The first is the ability to have
 a table view that only partially fills the screen. Normally one would use
 UITableViewController but that requires table views that fill the whole
 screen. EasyTableView addresses this problem by acting as the controller
 for the embedded table view, and exposing table view functionality
 with it's own delegate methods.
 
 The second concern addressed by EasyTableView is horizontal table views.
 Table views were initially designed to be vertical only. EasyTableView
 solves this problem by rotating the table view, and provides the same
 interface as creating a vertical EasyTableView.
 
 Now you can create simple partial screen table views, either vertically
 or horizontally, with the same interface!
 
 KNOWN LIMITATIONS:
 
 A horizontal EasyTableView will correctly auto-resize it's overall length only.
 A horizontal EasyTableView will NOT necessarily correctly auto-resize it's height.
 
 NEW FEATURES:
 
 4/25/2017 - Swiping a table view cell in a perpendicular direction to the normal
 scrolling direction of an EasyTableView, drags the cell out of the EasyTableView.
 If touches end with the cell away from the EasyTableView it will be deleted.
 Otherwise it will animate back to it's normal position. This feature is invoked by
 returning YES to the easyTableViewAllowsCellDeletion: delegate method. If this
 feature is used, the easyTableView:didDeleteCellAtIndexPath: delegate method must
 be implemented and must update the data store backing the table view accordingly.
 
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EasyTableViewOrientation) {
	EasyTableViewOrientationVertical,
	EasyTableViewOrientationHorizontal
};

@class EasyTableView;

@protocol EasyTableViewDelegate <NSObject>
- (NSInteger)easyTableView:(EasyTableView *)easyTableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)easyTableView:(EasyTableView *)easyTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView;
- (void)easyTableView:(EasyTableView *)easyTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)easyTableView:(EasyTableView*)easyTableView viewForHeaderInSection:(NSInteger)section;
- (UIView *)easyTableView:(EasyTableView*)easyTableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)easyTableView:(EasyTableView *)easyTableView heightOrWidthForCellAtIndexPath:(NSIndexPath *)indexPath;

// Implement at least the first two of these methods for the cell deletion feature
- (BOOL)easyTableViewAllowsCellDeletion:(EasyTableView *)easyTableView;
- (void)easyTableView:(EasyTableView *)easyTableView didDeleteCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)easyTableViewHasPendingCellDeletion:(EasyTableView *)easyTableView;
- (void)easyTableView:(EasyTableView *)easyTableView cell:(UITableViewCell *)cell deletionIsEminent:(BOOL)eminent;

// ScrollViewDelegate pass-through methods
- (void)easyTableViewWillBeginDragging:(EasyTableView *)easyTableView;
- (void)easyTableViewDidEndDragging:(EasyTableView *)easyTableView willDecelerate:(BOOL)decelerate;
- (void)easyTableViewWillBeginDecelerating:(EasyTableView *)easyTableView;
- (void)easyTableViewDidEndDecelerating:(EasyTableView *)easyTableView;
@end


@interface EasyTableView : UIView <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet id<EasyTableViewDelegate> delegate;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) EasyTableViewOrientation orientation;
@property (nonatomic, assign) CGPoint contentOffset;

- (instancetype)initWithFrame:(CGRect)frame ofWidth:(CGFloat)cellWidth;
- (instancetype)initWithFrame:(CGRect)frame ofHeight:(CGFloat)cellHeight;
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;
- (void)reload;

@end
