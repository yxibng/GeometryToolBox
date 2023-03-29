//
//  NXPromptHelper.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/29.
//

#import "NXPromptHelper.h"
#import "NXGeometryToolBoxHelper.h"
#import "NXGeometryToolLayout.hpp"

@interface NXPromptHelper ()

@property (nonatomic, weak) UIView<NXGeometryToolProtocol> *geometryToolView;
@property (nonatomic, weak) UILabel *promptLabel;

@property (nonatomic, assign) CGPoint lineStart;
@property (nonatomic, assign) CGPoint lineEnd;

@property (nonatomic, assign) CGPoint arcCenter;

@property (nonatomic, assign) CGFloat arcMinAngle;
@property (nonatomic, assign) CGFloat arcMaxAngle;

@end


@implementation NXPromptHelper
- (instancetype)initWithGeometryTool:(UIView<NXGeometryToolProtocol> *)geometryToolView promptLabel:(UILabel *)promptLabel {
    
    if (self = [super init]) {
        _geometryToolView = geometryToolView;
        _promptLabel = promptLabel;
    }
    return self;
}

- (void)syncRotationAngle:(CGFloat)angle {
    [self rotationAngleChanged:angle];
}

- (void)rotationAngleChanged:(CGFloat)angle {
    const int degree = RADIANS_TO_DEGREES(angle);
    NSString *text = [NSString stringWithFormat:@"%d°", degree];
    
    self.promptLabel.text = text;
    self.promptLabel.hidden = NO;
    
    [self.geometryToolView setNeedsLayout];
    [self.geometryToolView layoutIfNeeded];

}

- (void)syncDrawLineLength:(CGFloat)length {
    [self _onDrawLineLengthChanged:length];
}

- (void)drawLineBeganAtPoint:(CGPoint)point {
    _lineStart = point;
}
- (void)drawLineMovedToPoint:(CGPoint)point {
    _lineEnd = point;
    [self _calculateLength];
}
- (void)drawLlineEndedAtPoint:(CGPoint)point {
    _lineEnd = point;
    [self _calculateLength];
}

- (void)_calculateLength {
    CGFloat length = [NXGeometryToolBoxHelper distanceWithStartPoint:_lineStart endPoint:_lineEnd];
    const CGFloat cm = (length / self.geometryToolView.whiteboardWidth) / NXGeometryBox::NormOneCm;
    [self _onDrawLineLengthChanged:cm];
    //notify remote length changed
    if (self.geometryToolView.delegate && [self.geometryToolView.delegate respondsToSelector:@selector(geometryTool:onDrawLineLengthChanged:)]) {
        [self.geometryToolView.delegate geometryTool:self.geometryToolView onDrawLineLengthChanged:cm];
    }
}

- (void)_onDrawLineLengthChanged:(CGFloat)length {
    self.promptLabel.text = [NSString stringWithFormat:@"%.1fcm", length];
    self.promptLabel.hidden = NO;
    [self.geometryToolView setNeedsLayout];
    [self.geometryToolView layoutIfNeeded];
}

- (void)syncMoved {
    [self moved];
}
- (void)moved {
    self.promptLabel.hidden = YES;
}

- (void)SyncEnlarged {
    [self enlarged];
}
- (void)enlarged {
    self.promptLabel.hidden = YES;
}

- (void)syncDrawArcAngle:(CGFloat)angle {
    [self _arcAngleChanged:angle];
}

- (void)drawArcBeganAtPoint:(CGPoint)point center:(CGPoint)center {
    self.arcCenter = center;
    self.arcMinAngle = self.arcMaxAngle = [NXGeometryToolBoxHelper bezierPathAngleOfPoint:point center:center];
    
}

- (void)drawArcMovedToPoint:(CGPoint)point {
    [self _calculateArcAngleWithEndPoint:point];
}

- (void)drawArcEndedAtPoint:(CGPoint)point {
    [self _calculateArcAngleWithEndPoint:point];
}


- (void)_calculateArcAngleWithEndPoint:(CGPoint)point {
    CGFloat angel = [NXGeometryToolBoxHelper bezierPathAngleOfPoint:point center:self.arcCenter];
    if (angel < self.arcMinAngle) {
        self.arcMinAngle = angel;
    }
    if (angel > self.arcMaxAngle) {
        self.arcMaxAngle = angel;
    }
    
    CGFloat diff = self.arcMaxAngle - self.arcMinAngle;
    [self _arcAngleChanged:diff];
    
    //notify remote arc angle changed
    if (self.geometryToolView.delegate && [self.geometryToolView.delegate respondsToSelector:@selector(geometryTool:onDrawArcAngleChanged:)]) {
        [self.geometryToolView.delegate geometryTool:self.geometryToolView onDrawArcAngleChanged:diff];
    }
}

- (void)_arcAngleChanged:(CGFloat)angle {
    int degree = RADIANS_TO_DEGREES(angle);
    if (degree >= 360) {
        degree = 360;
    }
    
    NSString *text = [NSString stringWithFormat:@"%d°", degree];
    self.promptLabel.text = text;
    self.promptLabel.hidden = NO;
    
    [self.geometryToolView setNeedsLayout];
    [self.geometryToolView layoutIfNeeded];
}

@end
