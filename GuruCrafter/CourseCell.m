//
//  CourseCell.m
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 26.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "CourseCell.h"

@implementation CourseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)changeBorderStyle:(BOOL)editing {
    if (editing)
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
    else
        self.textField.borderStyle = UITextBorderStyleNone;
}

@end
