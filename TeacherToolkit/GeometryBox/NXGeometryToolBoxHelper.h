//
//  NXGeometryToolBoxHelper.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/20.
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(degrees) ((M_PI * (degrees))/180)
#define RADIANS_TO_DEGREES(radians) ((radians) / M_PI * 180)


NS_ASSUME_NONNULL_BEGIN

@interface NXGeometryToolBoxHelper : NSObject

+ (CGRect)textRectWithString:(NSString *)string font:(UIFont *)font;
/*
 大于0，顺时针，小于0， 逆时针
 */
+ (CGFloat)rotationAngleWithCenter:(CGPoint)center startPoint:(CGPoint)start endPoint:(CGPoint)end;


/*
 在绘制 bezierPath 时， 计算 point 相对于 center 的旋转角度
 */
+ (CGFloat)bezierPathAngleOfPoint:(CGPoint)point center:(CGPoint)center;


+ (CGFloat)distanceWithStartPoint:(CGPoint)start endPoint:(CGPoint)end;



@end

@interface NXGeometryToolDrawStyle : NSObject

@property (nonatomic, strong, class, readonly) UIColor *greenColor;
@property (nonatomic, strong, class, readonly) UIColor *blackColor;
@property (nonatomic, strong, class, readonly) UIColor *scaleMarkAreaBackgroundColor;
@property (nonatomic, strong, class, readonly) UIColor *mainBackgroundColor;

@property (nonatomic, strong, class, readonly) UIColor *promptTextColor;

@end


NS_ASSUME_NONNULL_END
