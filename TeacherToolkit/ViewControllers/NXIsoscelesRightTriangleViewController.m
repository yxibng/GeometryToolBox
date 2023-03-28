//
//  NXIsoscelesRightTriangleViewController.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/16.
//

#import "NXIsoscelesRightTriangleViewController.h"
#import "NXIsoscelesRightTriangleView.h"
#import "NXWhiteboardView.h"

@interface NXIsoscelesRightTriangleViewController ()<NXIsoscelesRightTriangleViewDelegate>
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
    
    
    
    _isoscelesRightTriangleView = [[NXIsoscelesRightTriangleView alloc] initWithWhiteboard:self.view];
    _isoscelesRightTriangleView.isoscelesRightTriangleViewDelegate = self;
    _isoscelesRightTriangleView.drawLineWidth = drawLineWidth;

}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
   
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    if (_width != width) {
        _width = width;
        [_isoscelesRightTriangleView setNormPosition:CGPointMake(0.5, 0.5 * height / width)];
    }
    
    [_isoscelesRightTriangleView setWhiteboardWidth:self.view.bounds.size.width];
    
    
    
}


- (void)isoscelesRightTriangleView:(NXIsoscelesRightTriangleView *)isoscelesRightTriangleView gestureBeganWithPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad gestureBeganWithPoint:point];
}
- (void)isoscelesRightTriangleView:(NXIsoscelesRightTriangleView *)isoscelesRightTriangleView gestureMovedToPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad gestureMovedToPoint:point];
}
- (void)isoscelesRightTriangleView:(NXIsoscelesRightTriangleView *)isoscelesRightTriangleView gestureEndedWithPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad gestureEndedWithPoint:point];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

