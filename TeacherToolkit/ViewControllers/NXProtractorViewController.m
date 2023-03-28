//
//  NXProtractorViewController.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/16.
//

#import "NXProtractorViewController.h"
#import "NXProtractorView.h"
#import "NXWhiteboardView.h"
#import "NXGeometryToolBoxHelper.h"

@interface NXProtractorViewController ()<NXGeometryToolDelegate>

@property (nonatomic, strong) NXProtractorView *protractorView;
@property (nonatomic, assign) CGFloat width;

@end

@implementation NXProtractorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    const CGFloat drawLineWidth = 5;
    
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    whiteboad.drawLineWidth = drawLineWidth;

    _protractorView = [[NXProtractorView alloc] init];
    _protractorView.delegate = self;
    _protractorView.userActionAllowed = YES;
    _protractorView.drawLineWidth = drawLineWidth;
    [self.view addSubview:_protractorView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    _protractorView.whiteboardWidth = width;
    
    if (_width != width) {
        _width = width;
        [_protractorView setNormPosition:CGPointMake(0.5, 0.5 * height / width)];
    }
}


- (void)geometryTool:(nonnull UIView<NXGeometryToolProtocol> *)geometryTool onNormPositionChanged:(CGPoint)normPosition {
    //TODO: send message
}

- (void)geometryTool:(nonnull UIView<NXGeometryToolProtocol> *)geometryTool onRotationAngleChanged:(CGFloat)rotationAngle {
    //TODO: send message
}

- (void)geometryToolOnCloseButtonClicked:(nonnull UIView<NXGeometryToolProtocol> *)geometryTool {
    //TODO: send message and remove
    [geometryTool removeFromSuperview];
}

//扩大，缩小事件
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onNormBaseSideLengthChanged:(CGFloat)normBaseSideLength {
    //TODO: send message
}

//画线事件
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawLineBeganAtPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad gestureBeganWithPoint:point];
}

- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawLineMovedToPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad gestureMovedToPoint:point];
    
}

- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawLineEndedAtPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad gestureEndedWithPoint:point];
}


//draw arc
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawArcBeganAtPoint:(CGPoint)point center:(CGPoint)center {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad arcGestureBeganWithPoint:point center:center];
}

- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawArcMovedToPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad arcGestureMovedToPoint:point];
}
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onDrawArcEndedAtPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad arcGestureEndedWithPoint:point];
}

//measure angle
- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onMeasurer1AngleChanged:(CGFloat)measurer1Angle {
    NSLog(@"measurer1Angle in degree = %f", RADIANS_TO_DEGREES(measurer1Angle));
}

- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onMeasurer2AngleChanged:(CGFloat)measurer2Angle {
    NSLog(@"measurer2Angle in degree = %f", RADIANS_TO_DEGREES(measurer2Angle));
}

@end
