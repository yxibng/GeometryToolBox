//
//  NXCompassView.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "NXGeometryToolProtocol.h"

NS_ASSUME_NONNULL_BEGIN
/*
 圆规
 开合角度范围 0-130 度
 初次打开默认夹角为 0 度
 */
@interface NXCompassView : UIView<NXGeometryToolProtocol>

//工具类型
@property (nonatomic, assign, readonly) NXGeometryToolType geometryToolType;
/*
 每种工具可以打开多个
 该种类型的工具间， 通过tag来区分
 */
@property (nonatomic, assign) NSUInteger geometryToolTag;


//事件代理
@property (nonatomic, weak) id<NXGeometryToolDelegate>delegate;

/*
 当前 whiteboard 的宽度
 宽度发生变化，尺规工具需要重绘自身
 */
@property (nonatomic, assign) CGFloat whiteboardWidth;

/*
 当前视图的锚点在白板中的归一化位置
 白板切换，从 A 到 B，锚点相对位置不变
 */
@property (nonatomic, assign) CGPoint normPosition;

/*
 当前工具旋转的角度， 绕锚点顺时针，弧度
 白板切换， 从 A 到 B， 锚点相对位置不变
 默认为 0
 */
@property (nonatomic, assign) CGFloat rotationAngle;

/*
 是否响应事件
 1. 按钮事件：旋转，放大，关闭, 锁定，取消锁定
 2. 拖移
 3. 允许划线
 */
@property (nonatomic, assign) BOOL userActionAllowed;

//划线的宽度
@property (nonatomic, assign) CGFloat drawLineWidth;
// 开合角度 0 - 130
@property (nonatomic, assign) CGFloat openAngleInDegree;
//是否锁定当前的开合角度
@property (nonatomic, assign) BOOL currentOpenAngleLocked;

//同步打开角度变更
- (void)syncOpenAngleInDegree:(CGFloat)openAngleInDegree;
//同步锁定状态
- (void)syncCurrentOpenAngleLocked:(BOOL)currentOpenAngleLocked;

//同步旋转角度
- (void)syncRotationAngle:(CGFloat)rotationAngle;
//同步锚点位置
- (void)syncNormPosition:(CGPoint)normPosition;

@end

NS_ASSUME_NONNULL_END
