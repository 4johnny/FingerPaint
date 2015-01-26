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
	
	self.paintView.currentColor = [UIColor INIT_COLOR];
	MDLog(@"Color: %@", self.paintView.currentColor);
}


#
# pragma mark - UIResponder
#

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Began");
	
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

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Moved");
	
	// Add current touch location to existing path.
	[self.paintView.pathSequence.lastObject addLineToPoint:[[touches anyObject] locationInView:self.paintView]];
	[self.paintView setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Ended");

	// Add current touch location to existing path.
	[self.paintView.pathSequence.lastObject addLineToPoint:[[touches anyObject] locationInView:self.paintView]];
	[self.paintView setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	MDLog(@"Touches Cancelled");
}


#
# pragma mark - Button Actions
#

- (IBAction)redButtonPressed {
	self.paintView.currentColor = [UIColor redColor];
	MDLog(@"Color: %@", self.paintView.currentColor);
}

- (IBAction)greenButtonPressed {
	self.paintView.currentColor = [UIColor greenColor];
	MDLog(@"Color: %@", self.paintView.currentColor);
}

- (IBAction)blueButtonPressed {
	self.paintView.currentColor = [UIColor blueColor];
	MDLog(@"Color: %@", self.paintView.currentColor);
}


@end
