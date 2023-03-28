//
//  NXCompassViewController.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/16.
//

#import "NXCompassViewController.h"
#import "NXCompassView.h"
#import "NXWhiteboardView.h"

@interface NXCompassViewController ()<NXGeometryToolDelegate>
@property (nonatomic, strong) NXCompassView *compassView;
@property (nonatomic, assign) CGFloat width;
@end

@implementation NXCompassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    const CGFloat drawLineWidth = 5;
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    whiteboad.drawLineWidth = drawLineWidth;

    _compassView = [[NXCompassView alloc] init];
    _compassView.userActionAllowed = YES;
    _compassView.delegate = self;
    _compassView.drawLineWidth = drawLineWidth;
    
    [self.view addSubview:_compassView];
    // Do any additional setup after loading the view.
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    const CGFloat width = CGRectGetWidth(self.view.bounds);
    const CGFloat height = CGRectGetHeight(self.view.bounds);
    _compassView.whiteboardWidth = width;
    if (_width != width) {
        _width = width;
        _compassView.normPosition = CGPointMake(0.5, 0.8 * height / width);
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

- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onOpenAngleChanged:(CGFloat)openAngleInDegree {
    
}

- (void)geometryTool:(UIView<NXGeometryToolProtocol> *)geometryTool onCurrentOpenAngleLockStateChanged:(BOOL)currentOpenAngleLocked {
    
}


@end

