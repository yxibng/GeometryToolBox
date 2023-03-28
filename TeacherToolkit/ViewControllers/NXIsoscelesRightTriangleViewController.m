//
//  NXIsoscelesRightTriangleViewController.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/16.
//

#import "NXIsoscelesRightTriangleViewController.h"
#import "NXIsoscelesRightTriangleView.h"
#import "NXWhiteboardView.h"

@interface NXIsoscelesRightTriangleViewController ()<NXGeometryToolDelegate>
@property (nonatomic, strong) NXIsoscelesRightTriangleView *isoscelesRightTriangleView;
@property (nonatomic, assign) CGFloat width;
@end

@implementation NXIsoscelesRightTriangleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    const CGFloat drawLineWidth = 5;
    
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    whiteboad.drawLineWidth = drawLineWidth;
    
    _isoscelesRightTriangleView = [[NXIsoscelesRightTriangleView alloc] init];
    _isoscelesRightTriangleView.delegate = self;
    _isoscelesRightTriangleView.drawLineWidth = drawLineWidth;
    _isoscelesRightTriangleView.userActionAllowed = YES;
    
    [self.view addSubview:_isoscelesRightTriangleView];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    _isoscelesRightTriangleView.whiteboardWidth = width;
    if (_width != width) {
        _width = width;
        [_isoscelesRightTriangleView setNormPosition:CGPointMake(0.5, 0.5 * height / width)];
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

//宽度扩大，缩小事件
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


@end

