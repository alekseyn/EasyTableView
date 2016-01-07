//
//  ImageViewCell.h
//  EasyTableView
//
//  Created by Aleksey Novicov on 1/7/16.
//
//

#import <UIKit/UIKit.h>

@interface ImageViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *flickrImageView;

@end
