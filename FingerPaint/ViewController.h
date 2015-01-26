//
//  ViewController.h
//  FingerPaint
//
//  Created by Johnny on 2015-01-25.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintView.h"

#
# pragma mark - Interface
#

@interface ViewController : UIViewController

# pragma mark Properties

@property (weak, nonatomic) IBOutlet PaintView *paintView;
@property (weak, nonatomic) IBOutlet UIButton *eraseButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;
@property (weak, nonatomic) IBOutlet UIButton *blueButton;

@end
