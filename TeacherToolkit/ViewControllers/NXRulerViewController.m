//
//  NXRulerViewController.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/16.
//

#import "NXRulerViewController.h"
#import "NXRulerView.h"
#import "NXWhiteboardView.h"

@interface NXRulerViewController ()<NXGeometryToolDelegate>
@property (nonatomic, strong) NXRulerView *rulerView;
@property (nonatomic, assign) CGFloat width;
@end

@implementation NXRulerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat drawLineWidth = 5.0;
    
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    whiteboad.drawLineWidth = drawLineWidth;
    
    _rulerView = [[NXRulerView alloc] init];
    _rulerView.delegate = self;
    _rulerView.drawLineWidth = drawLineWidth;
    _rulerView.userActionAllowed = YES;
    
    [self.view addSubview:_rulerView];
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _rulerView.whiteboardWidth = CGRectGetWidth(self.view.bounds);
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    if (_width != width) {
        _width = width;
        [_rulerView setNormPosition:CGPointMake(0.5, 0.5 * height / width)];
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
