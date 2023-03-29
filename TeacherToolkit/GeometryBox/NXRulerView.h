//
//  NXRulerView.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "NXGeometryToolProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface NXRulerView : UIView<NXGeometryToolProtocol>
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

@property (nonatomic, assign) CGFloat normBaseSideLength;
// normBaseSideLength 取值范围
@property (nonatomic, assign, readonly) NXGeometryToolBaseLengthRange baseLengthRange;


@end

NS_ASSUME_NONNULL_END
