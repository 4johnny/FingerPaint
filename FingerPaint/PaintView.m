//
//  PaintView.m
//  FingerPaint
//
//  Created by Johnny on 2015-01-25.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "PaintView.h"


#
# pragma mark - Implementation
#

@implementation PaintView


#
# pragma mark - UIView
#


-(instancetype)initWithCoder:(NSCoder *)decoder {
	
	self = [super initWithCoder:decoder];
	if (self) {
		
		_pathSequence = [NSMutableArray array];
		_colorSequence = [NSMutableArray array];
		
	}
	return self;
}


- (void)drawRect:(CGRect)rect {

	// MDLog(@"PaintView Draw Rect");

	// For each path, set color in graphics context, and stroke.
	for (int i = 0; i < self.pathSequence.count; i++) {
		
		[self.colorSequence[i] setStroke];
		[self.pathSequence[i] stroke];
	}
	
	self.graphicsContext = UIGraphicsGetCurrentContext();
}


@end
