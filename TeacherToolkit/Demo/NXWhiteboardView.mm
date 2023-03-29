//
//  NXWhiteboardView.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/23.
//

#import "NXWhiteboardView.h"
#import "NXGeometryToolBoxHelper.h"
#include <vector>

@interface NXWhiteboardView ()
{
    std::vector<CGPoint> _points;
    CGPoint _arcCenter;
}
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;


@end

@implementation NXWhiteboardView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self _setup];
    }
    return self;
}


- (void)_setup {
    self.backgroundColor = UIColor.whiteColor;
}


- (void)gestureBeganWithPoint:(CGPoint)point {
    self.startPoint = point;
}
- (void)gestureMovedToPoint:(CGPoint)point {
    self.endPoint = point;
}
- (void)gestureEndedWithPoint:(CGPoint)point {
    self.endPoint = point;
}

- (void)arcGestureBeganWithPoint:(CGPoint)point center:(CGPoint)center{
    _arcCenter = center;
    _points.clear();
    [self setNeedsDisplay];
    _points.push_back(point);
}

- (void)arcGestureMovedToPoint:(CGPoint)point {
    
    _points.push_back(point);
    
    [self setNeedsDisplay];
}

- (void)arcGestureEndedWithPoint:(CGPoint)point {
    
    _points.push_back(point);
    
    [self setNeedsDisplay];
}




- (void)setEndPoint:(CGPoint)endPoint {
    _endPoint = endPoint;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {

    
    if (_points.size() >= 2) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, self.drawLineWidth);
        CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
        for (int i = 1; i< _points.size(); i++) {
            CGPoint pre = _points[i-1];
            CGPoint cur = _points[i];
            const CGFloat dx = pre.x - _arcCenter.x;
            const CGFloat dy = pre.y - _arcCenter.y;
            CGFloat radius = sqrt(dx * dx + dy * dy);            
            CGFloat angleDiff = [NXGeometryToolBoxHelper rotationAngleWithCenter:_arcCenter startPoint:pre endPoint:cur];
            //是否是顺时针
            BOOL clockwise = angleDiff >= 0;
            CGFloat startAngle = [NXGeometryToolBoxHelper bezierPathAngleOfPoint:pre center:_arcCenter];
            CGFloat endAngle = startAngle + angleDiff;
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:_arcCenter radius:radius startAngle:startAngle endAngle:endAngle clockwise: clockwise];
            CGContextAddPath(context, path.CGPath);
        }
        CGContextStrokePath(context);
    }
    
    
    if (CGPointEqualToPoint(self.startPoint, CGPointZero) &&
        CGPointEqualToPoint(self.endPoint, CGPointZero)) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, self.drawLineWidth);
    CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
    CGContextMoveToPoint(context, _startPoint.x, _startPoint.y);
    CGContextAddLineToPoint(context, _endPoint.x, _endPoint.y);
    CGContextStrokePath(context);
}

@end
