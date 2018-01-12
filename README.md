[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Falekseyn%2FEasyTableView.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Falekseyn%2FEasyTableView?ref=badge_shield)
[![Language](https://img.shields.io/badge/language-Objective%20C-orange.svg)
[![CocoaPods](https://img.shields.io/badge/Cocoa%20Pods-✓-4BC51D.svg?style=flat)](https://cocoapods.org/pods/EasyTableView)
[![CocoaPodsDL](https://img.shields.io/cocoapods/dt/EasyTableView.svg)](https://cocoapods.org/pods/EasyTableView)

EasyTableView 2.1 - May 1, 2017

The API for `EasyTableView` has been extended. Swiping a table view cell in a perpendicular direction to the normal scrolling direction of an `EasyTableView`, drags the cell out of the `EasyTableView`. If touches end with the cell away from the `EasyTableView` it will be deleted. Otherwise it will animate back to it's normal position. See `EasyTableViewController` for an example.

-
EasyTableView 2.0 - January 7, 2016

__IMPORTANT NOTE__: The API for `EasyTableView` has changed of January 6, 2016. So if you have been a consumer of `EasyTableView` prior to this date, you may find that this update breaks your existing projects. 


###SUMMARY
---
This project demonstrates the use of the `EasyTableView` class. The demo is intended to be run on an iPad only, but there is no reason why `EasyTableView` could not be used on an iPhone.

To use `EasyTableView` in your own project, all you need to include are the following files:

```
EasyTableView.h
EasyTableView.m
```
This was written before `UICollectionView` became available, but developers may still prefer to use `EasyTableView` for it’s simplicity.
 

###DESCRIPTION
---
`EasyTableView` was created to address two concerns. The first is the ability to have a table view, horizontal or vertical, that only partially fills the screen. Normally one would use `UITableViewController` but as per Apple documentation, that requires table views that fill the whole screen. `EasyTableView` addresses this problem by acting as the controller for the embedded table view, and exposes a subset of table view functionality with it's own delegate methods.
 
The second concern addressed by `EasyTableView` is horizontal table views. Table views were initially designed to be vertical only. `EasyTableView` solves this problem by rotating the table view, and then reverse rotating table view cells. One could also provide horizontally scrolling table views by subclassing `UIScrollView`, but I wanted to create one simple, common interface for creating both vertical EasyTableViews and horizontal EasyTableViews.

So now you can create simple partial-screen table views, either vertically or horizontally, all with the same interface.


###USAGE
---

To understand how to use `EasyTableView`, study the code in `EasyTableViewController.m`. To create a new `EasyTableView` object, look at the methods:

```
- (void)setupHorizontalView;
- (void)setupVerticalView;
```

Create a vertical scrolling table view with:

`
- (id)initWithFrame:(CGRect)frame ofHeight:(CGFloat)cellHeight;
`

To create a new horizontal scrolling table view use:

`
- (id)initWithFrame:(CGRect)frame ofWidth:(CGFloat)cellWidth;
`

For even simpler setup, look to see how to use `EasyTableView` with a storyboard in `FlipsideViewController.m`

There are only two delegate methods that must be implemented as part of the `EasyTableViewDelegate` protocol:

```
- (NSInteger)easyTableView:(EasyTableView *)easyTableView numberOfRowsInSection:(NSInteger)section
- (UITableViewCell *)easyTableView:(EasyTableView *)easyTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
```
If you plan to setup an EasyTableView with multiple sections, you must implement the following delegate method:

```
- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView;
```

That's all there is to it. It is very easy to use. And yes, that is a picture of my tent!


###KNOWN LIMITATIONS
---
 
1. A horizontal `EasyTableView` will correctly auto-resize it's overall length. However a horizontal `EasyTableView` will NOT necessarily correctly auto-resize it's height. 

2. Loading the Flickr catalog will sometimes fail due to JSON parsing errors. 

3. Auto-layout is not supported.


###LICENSE
---
`EasyTableView` is released under the New BSD License.

Copyright (c) 2010-2017, Yodel Code LLC
All rights reserved.


[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Falekseyn%2FEasyTableView.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Falekseyn%2FEasyTableView?ref=badge_large)