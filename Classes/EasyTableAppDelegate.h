//
//  EasyTableAppDelegate.h
//  EasyTable
//
//  Created by Aleksey Novicov on 6/5/10.
//  Copyright Yodel Code LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EasyTableViewController;

@interface EasyTableAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EasyTableViewController *viewController;
}

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet EasyTableViewController *viewController;

@end

