//
//  PaintView.h
//  FingerPaint
//
//  Created by Johnny on 2015-01-25.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>


#
# pragma mark - Interface
#

@interface PaintView : UIView

# pragma mark Properties

@property (nonatomic) BOOL eraseMode;
@property (nonatomic) UIColor* currentColor;
@property (nonatomic, readonly) NSMutableArray* pathSequence;
@property (nonatomic, readonly) NSMutableArray* colorSequence;

@end
