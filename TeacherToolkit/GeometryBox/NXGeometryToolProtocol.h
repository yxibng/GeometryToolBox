//
//  NXGeometryToolProtocol.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/20.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


typedef struct NXGeometryToolBaseLengthRange {
    CGFloat normMinLength;
    CGFloat normMaxLength;
} NXGeometryToolBaseLengthRange;


typedef NS_ENUM(NSUInteger, NXGeometryToolType) {
    NXGeometryToolTypeRuler,
    NXGeometryToolTypeIsoscelesRightTriangle,
    NXGeometryToolTypeRightTriangle,
    NXGeometryToolTypeProtractor,
    NXGeometryToolTypeCompass
};

@protocol NXGeometryToolProtocol;


//draw line
@protocol NXGeometryToolDrawLineDelegate <NSObject>
@optional
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawLineBeganAtPoint:(CGPoint)point;
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawLineMovedToPoint:(CGPoint)point;
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawLineEndedAtPoint:(CGPoint)point;
- (void)geometryToolOnDrawLineCanceled:(UIView<NXGeometryToolProtocol> *)geometryTool;

- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawLineLengthChanged:(CGFloat)length;
@end

//draw arc
@protocol NXGeometryToolDrawArcDelegate <NSObject>
@optional
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawArcBeganAtPoint:(CGPoint)point center:(CGPoint)center;
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawArcMovedToPoint:(CGPoint)point;
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawArcEndedAtPoint:(CGPoint)point;
- (void)geometryToolOnDrawArcCanceled:(UIView<NXGeometryToolProtocol> *)geometryTool;

- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawArcAngleChanged:(CGFloat)angle;
@end


@protocol NXGeometryToolAngleMeasurerDelegate <NSObject>
@optional
//测量器角度变化
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onMeasurer1AngleChanged:(CGFloat)measurer1Angle;
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onMeasurer2AngleChanged:(CGFloat)measurer2Angle;
@end

@protocol NXGeometryToolCompassDelegate <NSObject>
@optional

//报告打开角度变更
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onOpenAngleChanged:(CGFloat)openAngleInDegree;
//报告锁定状态变更
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onCurrentOpenAngleLockStateChanged:(BOOL)currentOpenAngleLocked;

@end


@protocol NXGeometryToolDelegate <NXGeometryToolDrawLineDelegate, NXGeometryToolDrawArcDelegate, NXGeometryToolAngleMeasurerDelegate, NXGeometryToolCompassDelegate>
//旋转事件
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onRotationAngleChanged:(CGFloat)rotationAngle;
//拖移事件
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onNormPositionChanged:(CGPoint)normPosition;
//关闭事件
- (void)geometryToolOnCloseButtonClicked:(UIView<NXGeometryToolProtocol> *)geometryTool;

@optional

//宽度扩大，缩小事件
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onNormBaseSideLengthChanged:(CGFloat)normBaseSideLength;

@end



@protocol NXGeometryToolProtocol <NSObject>

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


#pragma mark - optional
@optional

#pragma mark - ruler, triangle, protractor
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
// normBaseSideLength 取值范围
@property (nonatomic, assign, readonly) NXGeometryToolBaseLengthRange baseLengthRange;

#pragma mark - protractor only
/*
弧度 0 - M_PI
*/
@property (nonatomic, assign) CGFloat measurer1Angle;
@property (nonatomic, assign) CGFloat measurer2Angle;

#pragma mark - compass only
// 开合角度 0 - 130
@property (nonatomic, assign) CGFloat openAngleInDegree;
//是否锁定当前的开合角度
@property (nonatomic, assign) BOOL currentOpenAngleLocked;

@end

NS_ASSUME_NONNULL_END
