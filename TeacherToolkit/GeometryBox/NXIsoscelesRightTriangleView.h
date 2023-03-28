//
//  NXIsoscelesRightTriangleView.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "NXGeometryToolProtocol.h"

NS_ASSUME_NONNULL_BEGIN


/*
 等腰直角三角形
 短边长度3-8cm
 初次打开默认 4cm
 */


@class NXIsoscelesRightTriangleView;
@protocol NXIsoscelesRightTriangleViewDelegate <NSObject>

- (void)isoscelesRightTriangleView:(NXIsoscelesRightTriangleView *)isoscelesRightTriangleView gestureBeganWithPoint:(CGPoint)point;
- (void)isoscelesRightTriangleView:(NXIsoscelesRightTriangleView *)isoscelesRightTriangleView gestureMovedToPoint:(CGPoint)point;
- (void)isoscelesRightTriangleView:(NXIsoscelesRightTriangleView *)isoscelesRightTriangleView gestureEndedWithPoint:(CGPoint)point;


@end



@interface NXIsoscelesRightTriangleView : UIView<NXGeometryToolProtocol>

//创建的时候传入白板, 由此计算 whiteboardWidth
- (instancetype)initWithWhiteboard:(UIView *)whiteboard;


@property (nonatomic, assign, readonly) NXGeometryToolType geometryToolType;


@property (nonatomic, weak) id <NXIsoscelesRightTriangleViewDelegate>isoscelesRightTriangleViewDelegate;

@property (nonatomic, weak) id<NXGeometryToolDelegate>delegate;


/*
 当前 whiteboard 的宽度
 宽度发生变化，尺规工具需要重绘自身
 */
@property (nonatomic, assign) CGFloat whiteboardWidth;

/*
 当前视图的锚点在白板中的归一化位置
 白板切换，从 A 到 B，锚点相对位置不变
 默认(0.5, 0.5)
 */
@property (nonatomic, assign) CGPoint normPosition;

/*
 当前工具旋转的角度， 绕锚点顺时针，弧度
 白板切换， 从 A 到 B， 锚点相对位置不变
 默认为 0
 */
@property (nonatomic, assign) CGFloat rotationAngle;

/*
 决定尺规工具的基准边长
 1. 对直尺来说，是宽度
 2. 对三角形，是短边长度
 3. 对量角器，是半径
 
 更新此变量，会导致尺规工具自身大小发生变化。
 改变量的设置需要参考各工具基准变长的取值范围 baseLengthRange。
 
 默认长度： 参考 NXGeometryToolLayout
 */
@property (nonatomic, assign) CGFloat normBaseSideLength;

/*
 关闭，放大，旋转按钮是否可用
 默认： NO
 */
@property (nonatomic, assign) BOOL operationButtonEnabled;


@property (nonatomic, assign) CGFloat drawLineWidth;



// normBaseSideLength 取值范围
@property (nonatomic, assign, readonly) NXGeometryToolBaseLengthRange baseLengthRange;

//白板变更
- (void)changeWhiteboard:(UIView *)whiteboard;

//同步角度旋转
- (void)syncRotationAngle:(CGFloat)rotationAngle;

//同步位置更新
- (void)syncPosition:(CGPoint)normPosition;

//同步基准变长更新
- (void)syncBaseSideLength:(CGFloat)normBaseSideLength;



@end

NS_ASSUME_NONNULL_END
