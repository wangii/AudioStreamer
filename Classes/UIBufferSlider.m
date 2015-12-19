//
//  UIBufferSlider.m
//  AudioStreamer
//
//  Created by Bo Anderson on 12/02/2015.
//
//

#import "UIBufferSlider.h"

#define DEGREES_TO_RADIANS(angle) (CGFloat)((angle) / 180.0 * M_PI)

@implementation UIBufferSlider

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setContinuous:NO];
    }
    return self;
}

- (void)drawRoundedHalfBarInRect:(CGRect)rect parentRect:(CGRect)parentRect
{
    CGFloat widthDiff = parentRect.size.width - rect.size.width;
    CGFloat radius;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        radius = 1.0;
    } else {
        radius = 4.0;
    }
    CGRect innerRect = CGRectInset(rect, radius, radius);

    if (isinf(innerRect.origin.x) || isinf(innerRect.origin.y)) return;

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(rect.origin.x + radius, rect.origin.y)];
    [bezierPath addArcWithCenter:innerRect.origin radius:radius startAngle:DEGREES_TO_RADIANS(270.0) endAngle:DEGREES_TO_RADIANS(180.0) clockwise:NO];
    [bezierPath addLineToPoint:CGPointMake(rect.origin.x, innerRect.origin.y + innerRect.size.height)];
    [bezierPath addArcWithCenter:CGPointMake(innerRect.origin.x, innerRect.origin.y + innerRect.size.height) radius:radius startAngle:DEGREES_TO_RADIANS(180.0) endAngle:DEGREES_TO_RADIANS(90.0) clockwise:NO];

    if (widthDiff < radius) {
        CGFloat widthDiffRadius = radius-widthDiff;
        CGRect endInnerRect = CGRectInset(rect, widthDiffRadius, widthDiffRadius);
        [bezierPath addLineToPoint:CGPointMake(endInnerRect.origin.x + endInnerRect.size.width, rect.origin.y + rect.size.height)];
        [bezierPath addArcWithCenter:CGPointMake(endInnerRect.origin.x + endInnerRect.size.width, endInnerRect.origin.y + endInnerRect.size.height) radius:widthDiffRadius startAngle:DEGREES_TO_RADIANS(90.0) endAngle:DEGREES_TO_RADIANS(0.0) clockwise:NO];
        [bezierPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, endInnerRect.origin.y)];
        [bezierPath addArcWithCenter:CGPointMake(endInnerRect.origin.x + endInnerRect.size.width, endInnerRect.origin.y) radius:widthDiffRadius startAngle:DEGREES_TO_RADIANS(0.0) endAngle:DEGREES_TO_RADIANS(270.0) clockwise:NO];
    } else {
        [bezierPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
        [bezierPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    }

    [bezierPath addLineToPoint:CGPointMake(rect.origin.x + radius, rect.origin.y)];
    [bezierPath closePath];
    [bezierPath fill];
}

- (void)drawRect:(CGRect)outerRect {
    [super drawRect:outerRect];

    CGFloat dy, y;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        dy = 11.0;
        y = 0.0;
    } else {
        dy = 8.0;
        y = -1.0;
    }

    CGRect barRect = CGRectInset(outerRect, 2.0, dy);
    barRect.size.height += 1;
    barRect.origin.y += y;

    if (![self isEnabled]) {
        [[UIColor lightGrayColor] set];
    } else {
        [[UIColor grayColor] set];
    }
    [self drawRoundedHalfBarInRect:barRect parentRect:barRect];

    [[UIColor redColor] set];
    CGRect bufferRect = barRect;
    bufferRect.size.width *= [self bufferValue] / 100;
    [self drawRoundedHalfBarInRect:bufferRect parentRect:barRect];

    if ([self respondsToSelector:@selector(tintColor)]) {
        [[self tintColor] set];
    } else {
        [[UIColor colorWithRed:(CGFloat)(29.0/255.0) green:(CGFloat)(98.0/255.0) blue:(CGFloat)(240.0/255.0) alpha:1.0] set];
    }
    CGRect progressRect = barRect;
    progressRect.size.width *= [self value] / 100;
    [self drawRoundedHalfBarInRect:progressRect parentRect:barRect];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0), NO, 0.0);
    UIImage *transparent = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setMinimumTrackImage:transparent forState:UIControlStateNormal];
    [self setMaximumTrackImage:transparent forState:UIControlStateNormal];
}

- (void)setValue:(float)value
{
    [super setValue:value];
    [self setNeedsDisplay];
}

- (void)setBufferValue:(double)bufferValue
{
    _bufferValue = MIN(bufferValue, 100.0);
    [self setNeedsDisplay];
}

@end
