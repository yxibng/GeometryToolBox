//
//  NXWhiteboardView.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NXWhiteboardView : UIView

@property (nonatomic, assign) CGFloat drawLineWidth;

//draw line
- (void)gestureBeganWithPoint:(CGPoint)point;
- (void)gestureMovedToPoint:(CGPoint)point;
- (void)gestureEndedWithPoint:(CGPoint)point;

//draw arc
- (void)arcGestureBeganWithPoint:(CGPoint)point center:(CGPoint)center;
- (void)arcGestureMovedToPoint:(CGPoint)point;
- (void)arcGestureEndedWithPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
