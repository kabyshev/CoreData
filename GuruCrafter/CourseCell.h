//
//  CourseCell.h
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 26.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;

- (void)changeBorderStyle:(BOOL)editing;

@end
