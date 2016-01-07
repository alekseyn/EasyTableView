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
#import "ImageViewCell.h"

@interface FlipsideViewController : UIViewController <EasyTableViewDelegate, ImageStoreDelegate>

@property (nonatomic, weak) IBOutlet EasyTableView *easyTableView;		// Demonstrates how to setup an EasyTableView in a storyboard
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet ImageViewCell *imageViewCell;
@property (nonatomic, strong) ImageStore *imageStore;

- (IBAction)done:(id)sender;

@end
