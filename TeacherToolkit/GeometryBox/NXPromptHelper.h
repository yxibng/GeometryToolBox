//
//  NXPromptHelper.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/29.
//

#import <UIKit/UIKit.h>
#import "NXGeometryToolProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXPromptHelper : NSObject

- (instancetype)initWithGeometryTool:(UIView<NXGeometryToolProtocol> *)geometryToolView promptLabel:(UILabel *)promptLabel;

- (void)syncRotationAngle:(CGFloat)angle;
- (void)rotationAngleChanged:(CGFloat)angle;

- (void)syncDrawLineLength:(CGFloat)length;
- (void)drawLineBeganAtPoint:(CGPoint)point;
- (void)drawLineMovedToPoint:(CGPoint)point;
- (void)drawLlineEndedAtPoint:(CGPoint)point;

- (void)syncMoved;
- (void)moved;

- (void)SyncEnlarged;
- (void)enlarged;

- (void)syncDrawArcAngle:(CGFloat)angle;
- (void)drawArcBeganAtPoint:(CGPoint)point center:(CGPoint)center;
- (void)drawArcMovedToPoint:(CGPoint)point;
- (void)drawArcEndedAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
