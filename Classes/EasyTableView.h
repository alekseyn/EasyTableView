//
//  EasyTableView.h
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright 2010 Yodel Code. All rights reserved.
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
 
 This implementation currently only supports one section. The view relies
 on three reserved view tags, 800 - 802.
 
 A horizontal EasyTableView will correctly auto-resize it's overall length only.
 A horizontal EasyTableView will NOT necessarily correctly auto-resize it's height.
 */

#import <UIKit/UIKit.h>

#define TABLEVIEW_TAG			800
#define ROTATED_CELL_VIEW_TAG	801
#define CELL_CONTENT_TAG		802

typedef enum {
	EasyTableViewOrientationVertical,
	EasyTableViewOrientationHorizontal
} EasyTableViewOrientation;

@class EasyTableView;

@protocol EasyTableViewDelegate <NSObject>
- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect;
- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath*)indexPath;
@optional
- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView;
- (void)easyTableView:(EasyTableView *)easyTableView scrolledToOffset:(CGPoint)contentOffset;
- (void)easyTableView:(EasyTableView *)easyTableView scrolledToFraction:(CGFloat)fraction;
- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView;
- (NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section;
- (UIView*)easyTableView:(EasyTableView*)easyTableView viewForHeaderInSection:(NSInteger)section;
- (UIView*)easyTableView:(EasyTableView*)easyTableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)easyTableView:(EasyTableView *)easyTableView heightOrWidthForCellAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface EasyTableView : UIView <UITableViewDelegate, UITableViewDataSource> {
@private
	CGFloat		_cellWidthOrHeight;
	NSUInteger	_numItems;
}

@property (nonatomic, unsafe_unretained) id<EasyTableViewDelegate> delegate;
@property (nonatomic, readonly, unsafe_unretained) UITableView *tableView;
@property (nonatomic, readonly, unsafe_unretained) NSArray *visibleViews;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) UIColor *cellBackgroundColor;
@property (nonatomic, readonly) EasyTableViewOrientation orientation;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, assign) NSUInteger numberOfCells;

- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numCells ofWidth:(CGFloat)cellWidth;
- (id)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numCells ofHeight:(CGFloat)cellHeight;
- (CGPoint)offsetForView:(UIView *)cell;
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;
- (void)setScrollFraction:(CGFloat)fraction animated:(BOOL)animated;
- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath*)indexPathForView:(UIView *)cell;
- (void)reloadData;

@end
