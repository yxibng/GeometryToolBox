//
//  NXCompassView.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/*
 圆规
 开合角度范围 0-130 度
 初次打开默认夹角为 0 度
 */
@interface NXCompassView : UIView


@property (nonatomic, assign) CGFloat whiteboardWidth;

/*
 弧度
 圆规🦵 旋转角度， 顺时针大与0， 逆时针小于 0
 */
@property (nonatomic, assign) CGFloat rotationAngle;

/*
 圆规🦵的锚点位置
 */
@property (nonatomic, assign) CGPoint normPosition;
/*
 角度
 开合角度 0 - 130度
 */
@property (nonatomic, assign) CGFloat openAngleInDegree;


/*
 是否锁定当前角度
 */
@property (nonatomic, assign) BOOL currentOpenAngleLocked;


@end

NS_ASSUME_NONNULL_END
