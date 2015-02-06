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

#define TOUCH_OFFSET	7 // Points

#define INIT_ERASE_MODE	NO

#define INIT_WIDTH		5 // Points
#define INIT_COLOR		redColor
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
		[path moveToPoint:[self touchPointWithTouches:touches]];
		
		[self.paintView.pathSequence addObject:path];
		[self.paintView.colorSequence addObject:self.paintView.currentColor];
		
		[self.paintView setNeedsDisplay];
	}
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Moved");
	
	CGPoint touchPoint = [self touchPointWithTouches:touches];

	if (!self.paintView.eraseMode) {
		
		// Add current touch location to existing path.
		MDLog(@"Draw: %.f,%.f", touchPoint.x, touchPoint.y);
		[self.paintView.pathSequence.lastObject addLineToPoint:touchPoint];
		[self.paintView setNeedsDisplay];
	}
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Ended");

	CGPoint touchPoint = [self touchPointWithTouches:touches];
	
	if (!self.paintView.eraseMode) {
		
		// Add current touch point to existing path.
		MDLog(@"Draw: %.f,%.f", touchPoint.x, touchPoint.y);
		[self.paintView.pathSequence.lastObject addLineToPoint:touchPoint];

	} else { // erase mode

		// Erase most recent path close to touch point
		[self erasePathWithTouchPoint:touchPoint];
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


- (CGPoint)touchPointWithTouches:(NSSet*)touches {
	
	return [[touches anyObject] locationInView:self.paintView];
}


- (void)erasePathWithTouchPoint:(CGPoint)touchPoint {
	
	// Hit-test touch point against sequence of paths.
	// Remove most-recent path that hits from the sequence.
	UIGraphicsPushContext(self.paintView.graphicsContext);
	for (int i = (int)self.paintView.pathSequence.count - 1; i >= 0; i--) {
		
		UIBezierPath* path = self.paintView.pathSequence[i];
		if ([ViewController containsTouch:touchPoint onPath:path inFillArea:NO]) {
			
			MDLog(@"Erase hit");
			[self.paintView.pathSequence removeObject:path];
			[self.paintView.colorSequence removeObjectAtIndex:i];
			break;
		}
	}
	UIGraphicsPopContext();
}


+ (BOOL)containsTouch:(CGPoint)point onPath:(UIBezierPath*)path inFillArea:(BOOL)inFill {
	
	// Check if touch point is within threshold distance of current point
	// NOTE: Handles case where Bezier path contains only a single point
	MDLog(@"Hit test: %.f,%.f", point.x, point.y);
	if (sqrt(pow(path.currentPoint.x - point.x, 2) + pow(path.currentPoint.y - point.y, 2)) < TOUCH_OFFSET) return YES;
	
	// Try all points in multi-point square centered on given point (since points are small)
	
	int touchWidth = TOUCH_OFFSET * 2 + 1;
	int pointsCount = pow(touchWidth, 2);
	CGPoint points[pointsCount];
	
	int i = 0;
	for (int y = point.y - TOUCH_OFFSET; y <= point.y + TOUCH_OFFSET; y++) {
		for (int x = point.x - TOUCH_OFFSET; x <= point.x + TOUCH_OFFSET; x++) {
			points[i++] = CGPointMake(x, y);
		}
	}
	
	return [ViewController containsPoints:points ofCount:pointsCount onPath:path inFillArea:inFill];
}


//
// Source: Apple Dev Docs, "Doing Hit-Detection on a Path"
//
// https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/BezierPaths/BezierPaths.html#//apple_ref/doc/uid/TP40010156-CH11-SW15
//
+ (BOOL)containsPoints:(CGPoint[])points ofCount:(int)pointsCount onPath:(UIBezierPath *)path inFillArea:(BOOL)inFill {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPathRef cgPath = path.CGPath;
	
	BOOL isHit = NO;
 
	// Determine the drawing mode to use. Default to
	// detecting hits on the stroked portion of the path.
	CGPathDrawingMode mode = kCGPathStroke;
	if (inFill) {
		
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
	for (int i = 0; i < pointsCount; i++) {
		MDLog(@"Hit test: %.f,%.f", points[i].x, points[i].y);
		
		if (CGContextPathContainsPoint(context, points[i], mode)) {
			isHit = TRUE;
			break;
		}
	}
 
	CGContextRestoreGState(context);
 
	return isHit;
}


@end
