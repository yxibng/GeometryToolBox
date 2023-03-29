//
//  NXGeometryToolBoxHelper.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/20.
//

#import "NXGeometryToolBoxHelper.h"

#define UIColorFromARGB(rgbValue) [UIColor colorWithRed:((rgbValue >> 16) & 0xFF)/255.0 \
green:((rgbValue >>  8) & 0xFF)/255.0 \
blue:((rgbValue >>  0) & 0xFF)/255.0 \
alpha:((rgbValue >> 24) & 0xFF)/255.0]


@implementation NXGeometryToolBoxHelper

+ (CGRect)textRectWithString:(NSString *)string font:(UIFont *)font {
    CGSize constraint = CGSizeMake(300,NSUIntegerMax);
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [string boundingRectWithSize:constraint
                                       options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                    attributes:attributes
                                       context:nil];
    return rect;
}

+ (CGFloat)rotationAngleWithCenter:(CGPoint)center startPoint:(CGPoint)start endPoint:(CGPoint)end {
    
    /*
     参考： https://ost.51cto.com/posts/89
     
     返回大于0 正向旋转
     返回小于0 反向旋转
     
     向量p=(x1,y1), q=(x2,y2)
     则 pxq=x1.y2-x2.y1
     ∣c∣=∣a∣∣b∣⋅sinθ
     */
    
    CGVector v1 = CGVectorMake(start.x - center.x, start.y - center.y);
    CGVector v2 = CGVectorMake(end.x - center.x, end.y - center.y);
    CGFloat lenV1 = sqrt(v1.dx * v1.dx + v1.dy * v1.dy);
    CGFloat lenV2 = sqrt(v2.dx * v2.dx + v2.dy * v2.dy);
    CGFloat sin = (v1.dx * v2.dy - v1.dy * v2.dx) / (lenV1 * lenV2);
    CGFloat angle = asin(sin);
    return angle;
}

+ (CGFloat)bezierPathAngleOfPoint:(CGPoint)point center:(CGPoint)center {
    
    CGFloat dx = point.x - center.x;
    CGFloat dy = point.y - center.y;
    
    CGFloat angle;
    if (dx >= 0 && dy >= 0) {
        angle = atan(dy / dx);
    } else if (dx <= 0 && dy >= 0) {
        angle = M_PI - atan(-dy / dx);
    } else if (dx <=0 && dy <= 0) {
        angle = M_PI + atan(dy / dx);
    } else {
        angle = 2 * M_PI - atan(-dy / dx);
    }
    return angle;
}

@end


static UIColor *_greenColor = nil;
static UIColor *_blackColor = nil;
static UIColor *_scaleMarkAreaBackgroundColor;
static UIColor *_mainBackgroundColor;

@implementation NXGeometryToolDrawStyle

+ (UIColor *)greenColor {
    if (!_greenColor) {
        _greenColor = UIColorFromARGB(0xFF089C74);
    }
    return _greenColor;
}

+ (UIColor *)blackColor
{
    if (!_blackColor) {
        _blackColor = [UIColor blackColor];
    }
    return _blackColor;
}

+ (UIColor *)scaleMarkAreaBackgroundColor {
    if (!_scaleMarkAreaBackgroundColor) {
        _scaleMarkAreaBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
    }
    return _scaleMarkAreaBackgroundColor;
}

+ (UIColor *)mainBackgroundColor {
    if (!_mainBackgroundColor) {
        _mainBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    }
    return _mainBackgroundColor;
}


@end
