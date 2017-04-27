//
//  EasyTableAppDelegate.h
//  EasyTableView
//
//  Created by Aleksey Novicov on 6/5/10.
//

#import <UIKit/UIKit.h>

@class EasyTableViewController;

@interface EasyTableAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet EasyTableViewController *viewController;

@end

