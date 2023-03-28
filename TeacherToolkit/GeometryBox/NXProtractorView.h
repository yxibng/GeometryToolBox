//
//  NXProtractorView.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "NXGeometryToolProtocol.h"



NS_ASSUME_NONNULL_BEGIN


@class NXProtractorView;
@protocol NXProtractorViewDelegate <NSObject>

//draw line

- (void)protractorView:(NXProtractorView *)protractorView lineGestureBeganWithPoint:(CGPoint)point;
- (void)protractorView:(NXProtractorView *)protractorView lineGestureMovedToPoint:(CGPoint)point;
- (void)protractorView:(NXProtractorView *)protractorView lineGestureEndedWithPoint:(CGPoint)point;

//draw arc

- (void)protractorView:(NXProtractorView *)protractorView arcGestureBeganWithPoint:(CGPoint)point center:(CGPoint)center;
- (void)protractorView:(NXProtractorView *)protractorView arcGestureMovedToPoint:(CGPoint)point;
- (void)protractorView:(NXProtractorView *)protractorView arcGestureEndedWithPoint:(CGPoint)point;

@end




/*
 量角器
 直径范围 8-14cm
 初次打开默认直径 8cm
 */
@interface NXProtractorView : UIView<NXGeometryToolProtocol>

//创建的时候传入白板, 由此计算 whiteboardWidth
- (instancetype)initWithWhiteboard:(UIView *)whiteboard;

@property (nonatomic, assign, readonly) NXGeometryToolType geometryToolType;


@property (nonatomic, weak) id<NXProtractorViewDelegate>protractorViewDelegate;

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

// normBaseSideLength 取值范围
@property (nonatomic, assign, readonly) NXGeometryToolBaseLengthRange baseLengthRange;

@property (nonatomic, assign) CGFloat drawLineWidth;


//白板变更
- (void)changeWhiteboard:(UIView *)whiteboard;

//同步角度旋转Z
- (void)syncRotationAngle:(CGFloat)rotationAngle;

//同步位置更新
- (void)syncPosition:(CGPoint)normPosition;

//同步基准变长更新
- (void)syncBaseSideLength:(CGFloat)normBaseSideLength;


@end

NS_ASSUME_NONNULL_END
