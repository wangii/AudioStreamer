//
//  NSBufferSliderCell.m
//  MacStreamingPlayer
//
//  Created by Bo Anderson on 11/02/2015.
//

#import "NSBufferSliderCell.h"

@implementation NSBufferSliderCell

- (void)drawRoundedHalfBarInRect:(NSRect)rect parentRect:(NSRect)parentRect
{
    CGFloat widthDiff = parentRect.size.width - rect.size.width;
    CGFloat radius = 2.0;
    NSRect innerRect = NSInsetRect(rect, radius, radius);
    NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    [bezierPath moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y + radius)];
    [bezierPath appendBezierPathWithArcWithCenter:innerRect.origin radius:radius startAngle:180.0 endAngle:270.0];
    if (widthDiff < radius) {
        CGFloat widthDiffRadius = radius-widthDiff;
        NSRect endInnerRect = NSInsetRect(rect, widthDiffRadius, widthDiffRadius);
        [bezierPath relativeLineToPoint:NSMakePoint(NSWidth(innerRect) + widthDiff, 0.0)];
        [bezierPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(endInnerRect), NSMinY(endInnerRect)) radius:widthDiffRadius startAngle:270.0 endAngle:360.0];
        [bezierPath relativeLineToPoint:NSMakePoint(0.0, NSHeight(endInnerRect))];
        [bezierPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(endInnerRect), NSMaxY(endInnerRect)) radius:widthDiffRadius startAngle:0.0 endAngle:90.0];
        [bezierPath relativeLineToPoint:NSMakePoint(-NSWidth(innerRect) - widthDiff, 0.0)];
    } else {
        [bezierPath relativeLineToPoint:NSMakePoint(NSWidth(innerRect) + radius, 0.0)];
        [bezierPath relativeLineToPoint:NSMakePoint(0.0, NSHeight(rect))];
        [bezierPath relativeLineToPoint:NSMakePoint(-NSWidth(innerRect) - radius, 0.0)];
    }
    [bezierPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(innerRect), NSMaxY(innerRect)) radius:radius startAngle:90.0 endAngle:180.0];
    [bezierPath closePath];
    [bezierPath fill];
}

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    [super drawBarInside:aRect flipped:flipped];

    NSRect borderedRect = aRect;
    borderedRect.size.width -= 2;
    borderedRect.size.height -= 2;
    borderedRect.origin.x += 1;
    borderedRect.origin.y += 1;

    [[NSColor redColor] set];
    NSRect bufferRect = borderedRect;
    bufferRect.size.width *= [self bufferValue] / 100;
    [self drawRoundedHalfBarInRect:bufferRect parentRect:borderedRect];

    [[NSColor colorWithSRGBRed:29.0/255.0 green:98.0/255.0 blue:240.0/255.0 alpha:1.0] set];
    NSRect playedRect = borderedRect;
    playedRect.size.width *= [self doubleValue] / 100;
    [self drawRoundedHalfBarInRect:playedRect parentRect:borderedRect];
}

@end
