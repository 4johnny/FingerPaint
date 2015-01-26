//
//  ViewController.m
//  FingerPaint
//
//  Created by Johnny on 2015-01-25.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "ViewController.h"


#
# pragma mark - Constants
#

#define DEFAULT_FLATNESS	0.6

#define INIT_ERASE_MODE	NO

#define INIT_COLOR		redColor
#define INIT_WIDTH		5
#define INIT_CAP_STYLE	kCGLineCapRound
#define INIT_JOIN_STYLE	kCGLineJoinRound
#define INIT_FLATNESS	0.0001


#
# pragma mark - Interface
#

@interface ViewController ()

@end


#
# pragma mark - Implementation
#

@implementation ViewController


#
# pragma mark - UIViewController
#

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.paintView.eraseMode = INIT_ERASE_MODE;
	self.paintView.currentColor = [UIColor INIT_COLOR];
	MDLog(@"Color: %@", self.paintView.currentColor);
}


#
# pragma mark - UIResponder
#

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Began");
	
	if (!self.paintView.eraseMode) {
		
		// Create new bezier path & capture current color setting.
		UIBezierPath* path = [UIBezierPath bezierPath];
		path.lineWidth = INIT_WIDTH;
		path.lineCapStyle = INIT_CAP_STYLE;
		path.lineJoinStyle = INIT_JOIN_STYLE;
		path.flatness = INIT_FLATNESS;
		[path moveToPoint:[[touches anyObject] locationInView:self.paintView]];
		
		[self.paintView.pathSequence addObject:path];
		[self.paintView.colorSequence addObject:self.paintView.currentColor];
		
		[self.paintView setNeedsDisplay];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Moved");
	
	if (!self.paintView.eraseMode) {
		
		// Add current touch location to existing path.
		[self.paintView.pathSequence.lastObject addLineToPoint:[[touches anyObject] locationInView:self.paintView]];
		
		[self.paintView setNeedsDisplay];
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Ended");
	
	if (!self.paintView.eraseMode) {
		
		// Add current touch location to existing path.
		[self.paintView.pathSequence.lastObject addLineToPoint:[[touches anyObject] locationInView:self.paintView]];
		
		
	} else { // erase mode
		
		// Hit-test final touch location against sequence of paths.
		// Remove any paths that hit from the sequence.
		CGPoint touchLocation = [[touches anyObject] locationInView:self.paintView];
		UIGraphicsPushContext(self.paintView.graphicsContext);
	
		for (int i = 0; i < self.paintView.pathSequence.count; i++) {
			UIBezierPath* path = self.paintView.pathSequence[i];
			if ([self containsPoint:touchLocation onPath:path inFillArea:NO]) {
				MDLog(@"Erase hit");
				[self.paintView.pathSequence removeObject:path];
				[self.paintView.colorSequence removeObjectAtIndex:i];
			}
		}
			
		UIGraphicsPopContext();
	}
	
	[self.paintView setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Cancelled");
}


#
# pragma mark - Button Actions
#

- (IBAction)eraseButtonPressed {
	self.paintView.eraseMode = YES;
	MDLog(@"Eraser");
}

- (IBAction)redButtonPressed {
	
	self.paintView.currentColor = [UIColor redColor];
	self.paintView.eraseMode = NO;
	MDLog(@"Color: %@", self.paintView.currentColor);
}

- (IBAction)greenButtonPressed {
	
	self.paintView.currentColor = [UIColor greenColor];
	self.paintView.eraseMode = NO;
	MDLog(@"Color: %@", self.paintView.currentColor);
}

- (IBAction)blueButtonPressed {
	
	self.paintView.currentColor = [UIColor blueColor];
	self.paintView.eraseMode = NO;
	MDLog(@"Color: %@", self.paintView.currentColor);
}


#
# pragma mark - Helpers
#

//
// Source: Apple Dev Docs, "Doing Hit-Detection on a Path"
//
// https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/BezierPaths/BezierPaths.html#//apple_ref/doc/uid/TP40010156-CH11-SW15
//
- (BOOL)containsPoint:(CGPoint)point onPath:(UIBezierPath *)path inFillArea:(BOOL)inFill {

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPathRef cgPath = path.CGPath;
	BOOL    isHit = NO;
 
	// Determine the drawing mode to use. Default to
	// detecting hits on the stroked portion of the path.
	CGPathDrawingMode mode = kCGPathStroke;
	if (inFill)
	{
		// Look for hits in the fill area of the path instead.
		if (path.usesEvenOddFillRule)
			mode = kCGPathEOFill;
		else
			mode = kCGPathFill;
	}
 
	// Save the graphics state so that the path can be
	// removed later.
	CGContextSaveGState(context);
	CGContextAddPath(context, cgPath);
 
	// Do the hit detection.
	isHit = CGContextPathContainsPoint(context, point, mode);
 
	CGContextRestoreGState(context);
 
	return isHit;
}


@end
