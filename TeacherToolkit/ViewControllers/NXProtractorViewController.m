//
//  NXProtractorViewController.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/16.
//

#import "NXProtractorViewController.h"
#import "NXProtractorView.h"
#import "NXWhiteboardView.h"

@interface NXProtractorViewController ()<NXProtractorViewDelegate>

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

    _protractorView = [[NXProtractorView alloc] initWithWhiteboard:self.view];
    _protractorView.protractorViewDelegate = self;
    _protractorView.drawLineWidth = drawLineWidth;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    if (_width != width) {
        _width = width;
        [_protractorView setNormPosition:CGPointMake(0.5, 0.5 * height / width)];
    }
    [_protractorView setWhiteboardWidth:self.view.bounds.size.width];}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//draw line

- (void)protractorView:(NXProtractorView *)protractorView lineGestureBeganWithPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad gestureBeganWithPoint:point];

}

- (void)protractorView:(NXProtractorView *)protractorView lineGestureMovedToPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad gestureMovedToPoint:point];
}

- (void)protractorView:(NXProtractorView *)protractorView lineGestureEndedWithPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad gestureEndedWithPoint:point];
}

//draw arc

- (void)protractorView:(NXProtractorView *)protractorView arcGestureBeganWithPoint:(CGPoint)point center:(CGPoint)center {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad arcGestureBeganWithPoint:point center:center];
}
- (void)protractorView:(NXProtractorView *)protractorView arcGestureMovedToPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad arcGestureMovedToPoint:point];
}
- (void)protractorView:(NXProtractorView *)protractorView arcGestureEndedWithPoint:(CGPoint)point {
    NXWhiteboardView *whiteboad = (NXWhiteboardView *)self.view;
    [whiteboad arcGestureEndedWithPoint:point];
}


@end
