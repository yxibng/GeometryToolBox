//
//  NXCompassViewController.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/16.
//

#import "NXCompassViewController.h"
#import "NXCompassView.h"

@interface NXCompassViewController ()
@property (nonatomic, strong) NXCompassView *compassView;
@end

@implementation NXCompassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _compassView = [[NXCompassView alloc] init];
    [self.view addSubview:_compassView];
    // Do any additional setup after loading the view.
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    const CGFloat width = CGRectGetWidth(self.view.bounds);
    const CGFloat height = CGRectGetHeight(self.view.bounds);
    
    _compassView.whiteboardWidth = self.view.bounds.size.width;
    _compassView.normPosition = CGPointMake(0.5, 0.8 * height / width);
//    _compassView.openAngleInDegree = 10;
//    _compassView.rotationAngle = 0;
}

@end
