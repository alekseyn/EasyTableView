//
//  FlipsideViewController.h
//  EasyTableView
//
//  Created by Aleksey Novicov on 1/30/12.
//  Copyright (c) 2012 Yodel Code LLC. All rights reserved.
//
// Demonstrates the use of EasyTableView with images loaded from a remote server

#import <UIKit/UIKit.h>
#import "EasyTableView.h"
#import "ImageStore.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController <EasyTableViewDelegate, ImageStoreDelegate>

@property (assign, nonatomic) IBOutlet id<FlipsideViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UILabel *errorLabel;
@property (retain, nonatomic) ImageStore *imageStore;
@property (retain, nonatomic) EasyTableView *easyTableView;

- (IBAction)done:(id)sender;

@end
