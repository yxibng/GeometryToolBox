//
//  NXRightTriangleViewController.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/16.
//

#import "NXRightTriangleViewController.h"
#import "NXRightTriangleView.h"


@interface NXRightTriangleViewController ()
@property (nonatomic, strong) NXRightTriangleView *rightTriangleView;
@property (nonatomic, assign) CGFloat width;

@end

@implementation NXRightTriangleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _rightTriangleView = [[NXRightTriangleView alloc] initWithWhiteboard:self.view];

    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    if (_width != width) {
        _width = width;
        [_rightTriangleView setNormPosition:CGPointMake(0.5, 0.5 * height / width)];
    }
    [_rightTriangleView setWhiteboardWidth:self.view.bounds.size.width];
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
