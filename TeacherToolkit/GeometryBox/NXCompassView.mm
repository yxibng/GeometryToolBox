//
//  NXCompassView.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import "NXCompassView.h"
#import "NXGeometryToolLayout.hpp"
#import "NXGeometryToolBoxHelper.h"

static NSString *footImageName = @"脚";
static NSString *handleImageName = @"柄";
static NSString *penImageName = @"pen";


@interface NXHandleImageView : UIImageView
@property (nonatomic, strong) UIButton *lockButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) BOOL locked;

@end

@implementation NXHandleImageView

- (void)setLocked:(BOOL)locked {
    _locked = locked;
    self.lockButton.selected = locked;
}

- (UIButton *)lockButton {
    if (!_lockButton) {
        _lockButton = [[UIButton alloc] init];
        [_lockButton setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];
        [_lockButton setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateSelected];
    }
    return _lockButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self addSubview:self.lockButton];
    [self addSubview:self.closeButton];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    //TODO: move the hard code to layout file
    
    const CGFloat normWidth = 48 / 72.0;
    const CGFloat width = self.bounds.size.width;
    const CGFloat sideLength = width * normWidth;
    {
        const CGFloat normOffsetX = 11 / 72.0;
        self.closeButton.frame = CGRectMake(width + width * normOffsetX, 0, sideLength, sideLength);
    }
    
    {
        const CGFloat normOffsetX = 12 / 72.0;
        const CGFloat normOffsetY = 83 / 72.0;
        self.lockButton.frame = CGRectMake(width * normOffsetX, width * normOffsetY, sideLength, sideLength);
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL ret = [super pointInside:point withEvent:event];
    if (ret) return YES;
    CGRect extRect = self.closeButton.frame;
    return CGRectContainsPoint(extRect, point);
}

@end



@interface NXPenImageView : UIImageView

@property (nonatomic, strong) UIButton *enalrgeButton;

@end


@implementation NXPenImageView

- (UIButton *)enalrgeButton {
    if (!_enalrgeButton) {
        _enalrgeButton = [[UIButton alloc] init];
        [_enalrgeButton setImage:[UIImage imageNamed:@"pull"] forState:UIControlStateNormal];
    }
    return _enalrgeButton;
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self addSubview:self.enalrgeButton];
    //TODO: hard code
    _enalrgeButton.layer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, NXGeometryBox::degreeToRadians(15));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat normWidth = 48 / 95.0;
    const CGFloat width = self.bounds.size.width;
    const CGFloat sideLength = width * normWidth;
    const CGFloat normCenterY = (202 + 48 /2) / 95.0;
    const CGFloat normCenterX = (22 + 48 /2) / 95.0;
    self.enalrgeButton.bounds = CGRectMake(0, 0, sideLength, sideLength);
    self.enalrgeButton.layer.position = CGPointMake(width * normCenterX, width * normCenterY);
}

@end



#pragma mark -


@interface NXCompassView ()

@property (nonatomic, strong) UIImageView *footImageView;
@property (nonatomic, strong) NXHandleImageView *handleImageView;
@property (nonatomic, strong) NXPenImageView *penImageView;

@property (nonatomic, strong) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *enlargeGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *drawArcGesture;

@end


@implementation NXCompassView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    
    //move gesture
    {
        
        _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onMovePanGestureChanged:)];
        [self addGestureRecognizer:_moveGesture];
    }
        
    self.clipsToBounds = NO;
    self.backgroundColor = UIColor.clearColor;
    
    //锚点设置为右下角
    self.layer.anchorPoint = CGPointMake(1.0, 1.0);
    
    //foot
    {
        _footImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:footImageName]];
        _footImageView.userInteractionEnabled = YES;
        _footImageView.frame = self.bounds;
        _footImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_footImageView];
    }
    
    //pen
    {
        _penImageView = [[NXPenImageView alloc] initWithImage:[UIImage imageNamed:penImageName]];
        _penImageView.userInteractionEnabled = YES;
        //笔的锚点在左上角
        _penImageView.layer.anchorPoint = CGPointMake(0, 0);
        
        //draw arc gesture
        {
            //TODO: 画弧线手势响应区域需要处理， 应该只是笔的部分响应，其他部分应该响应的是移动手势
            UIPanGestureRecognizer *drawArcGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onDrawArcPanGestureChanged:)];
            [_penImageView addGestureRecognizer:drawArcGesture];
            _drawArcGesture = drawArcGesture;
        }
        
        //enlarge gesture
        {
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onEnlargePanGestureChanged:)];
            [_penImageView.enalrgeButton addGestureRecognizer:pan];
            _enlargeGesture = pan;
        }
        [self addSubview:_penImageView];
    }
    
    //handle
    {
        _handleImageView = [[NXHandleImageView alloc] initWithImage:[UIImage imageNamed:handleImageName]];
        _handleImageView.userInteractionEnabled = YES;
        auto anchorPoint = NXGeometryBox::CompassLayout::handleAnchorPoint();
        _handleImageView.layer.anchorPoint = CGPointMake(anchorPoint.x, anchorPoint.y);
        [_handleImageView.closeButton addTarget:self action:@selector(_onClickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [_handleImageView.lockButton addTarget:self action:@selector(_onClickChangeLockStateButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_handleImageView];
    }
    
    _rotationAngle = 0;
    _openAngleInDegree = 0;
}

#pragma mark -

- (void)setWhiteboardWidth:(CGFloat)whiteboardWidth {
    
    if (_whiteboardWidth == whiteboardWidth) {
        return;
    }
    _whiteboardWidth = whiteboardWidth;
    
    {
        CGRect bounds = self.bounds;
        //TOOD: 计算bounds
        auto normSizeOfFoot =  NXGeometryBox::CompassLayout::normSizeOfFoot();
        bounds.size.width = normSizeOfFoot.width * whiteboardWidth;
        bounds.size.height = normSizeOfFoot.height * whiteboardWidth;
        self.bounds = bounds;
    }
    [self _layoutNow];
}


- (void)setNormPosition:(CGPoint)normPosition {
    if (CGPointEqualToPoint(normPosition, _normPosition)) {
        return;
    }
    _normPosition = normPosition;
    //TODO: 计算自己的位置
    
    
    const CGFloat whiteboardWidth = self.whiteboardWidth;
    
    CGFloat x = whiteboardWidth * normPosition.x;
    CGFloat y = whiteboardWidth * normPosition.y;
    
    self.layer.position = CGPointMake(x, y);
}


- (void)setRotationAngle:(CGFloat)rotationAngle {
    if (_rotationAngle == rotationAngle) {
        return;
    }
    _rotationAngle = rotationAngle;
    self.layer.affineTransform = CGAffineTransformMakeRotation(_rotationAngle);
    [self _layoutNow];
}


- (void)setOpenAngleInDegree:(CGFloat)openAngleInDegree {
    if (_openAngleInDegree == openAngleInDegree) {
        return;
    }
    _openAngleInDegree = openAngleInDegree;
    [self _layoutNow];
}


- (void)setCurrentOpenAngleLocked:(BOOL)currentOpenAngleLocked {
    _currentOpenAngleLocked = currentOpenAngleLocked;
    self.handleImageView.locked = currentOpenAngleLocked;
}

- (void)_layoutNow {
    if (!self.window) {
        return;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


#pragma mark -


- (void)layoutSubviews {
    [super layoutSubviews];
    const CGFloat whiteboardWidth = self.whiteboardWidth;
    const CGPoint joinPoint = CGPointMake(whiteboardWidth * NXGeometryBox::CompassLayout::normSizeOfFoot().width, 0);
    //pen
    {
        auto normSize = NXGeometryBox::CompassLayout::normSizeOfPen();
        _penImageView.bounds = CGRectMake(0, 0, normSize.width * whiteboardWidth, normSize.height * whiteboardWidth);

        _penImageView.layer.position = joinPoint;
        _penImageView.layer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, NXGeometryBox::degreeToRadians(-self.openAngleInDegree));
    }
    
    //handle
    {
        auto normSize = NXGeometryBox::CompassLayout::normSizeOfHandle();
        _handleImageView.bounds = CGRectMake(0, 0, normSize.width * whiteboardWidth, normSize.height * whiteboardWidth);
        _handleImageView.layer.position = joinPoint;
        _handleImageView.layer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, NXGeometryBox::degreeToRadians(-self.openAngleInDegree/2));
    }
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    BOOL ret = [super pointInside:point withEvent:event];
    if (ret) return YES;

    
    //test pen
   
    {
        CGPoint p = [self convertPoint:point toView:self.penImageView];
        if (CGRectContainsPoint(self.penImageView.bounds, p)) {
            return YES;
        }
    }
    
    //test handle
    {
        CGPoint p = [self convertPoint:point toView:self.handleImageView];
        if ([self.handleImageView pointInside:p withEvent:event]) {
            return YES;
        }
    }
    
    return NO;
}


#pragma mark -


- (void)_onMovePanGestureChanged:(UIPanGestureRecognizer *)moveGesture {
    CGPoint translation = [moveGesture translationInView:self.superview];
    CGPoint anchorPoint = self.layer.position;
    anchorPoint = self.layer.position;
    anchorPoint.x += translation.x;
    anchorPoint.y += translation.y;
    self.layer.position = anchorPoint;
    [moveGesture setTranslation:CGPointZero inView:self.superview];
    
    _normPosition = CGPointMake(anchorPoint.x / _whiteboardWidth, anchorPoint.y / _whiteboardWidth);
}

- (void)_onEnlargePanGestureChanged:(UIPanGestureRecognizer *)panGesture {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSAssert(_whiteboardWidth > 0, @"_onEnlargePanGestureChanged, whiteboardWidth can not be zero!");
    static CGPoint pre;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            pre = [panGesture locationInView:self.superview];
            break;
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint cur = [panGesture locationInView:self.superview];
            if (CGPointEqualToPoint(cur, pre)) {
                break;
            }
            //update open angel
            {
                CGPoint center = [self convertPoint:CGPointMake(self.bounds.size.width, 0) toView:self.superview];
                CGFloat angle = [NXGeometryToolBoxHelper rotationAngleWithCenter:center startPoint:pre endPoint:cur];
                CGFloat degree = RADIANS_TO_DEGREES(angle);
                CGFloat nextDegree = _openAngleInDegree - degree;
                if (nextDegree <= 0) {
                    nextDegree = 0;
                } else if (nextDegree >= 130) {
                    nextDegree = 130;
                }
                _openAngleInDegree = nextDegree;
            }
            //update rotation angle
            {
                CGFloat angle = [NXGeometryToolBoxHelper rotationAngleWithCenter:self.layer.position startPoint:pre endPoint:cur];
                _rotationAngle += angle;
                self.layer.affineTransform = CGAffineTransformMakeRotation(_rotationAngle);
            }
            [self _layoutNow];
            pre = cur;
        }
            break;
        default:
            break;
    }

    
    
    
    
    
    
    
}

- (void)_onDrawArcPanGestureChanged:(UIPanGestureRecognizer *)rotationGesture {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //TODO: 旋转处理， 画弧处理
    
    //参考： https://ost.51cto.com/posts/89
    
    static CGPoint pre;
    switch (rotationGesture.state) {
        case UIGestureRecognizerStateBegan:
            pre = [rotationGesture locationInView:self.superview];
            break;
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint cur = [rotationGesture locationInView:self.superview];
            if (CGPointEqualToPoint(cur, pre)) {
                break;
            }
            CGFloat angle = [NXGeometryToolBoxHelper rotationAngleWithCenter:self.layer.position startPoint:pre endPoint:cur];
            self.rotationAngle += angle;
            pre = cur;
        }
            break;
        default:
            break;
    }

    
    
    
}




#pragma mark -

- (void)_onClickChangeLockStateButton:(UIButton *)sender {
    //TODO:
    self.currentOpenAngleLocked = !self.currentOpenAngleLocked;
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)_onClickCloseButton:(UIButton *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}



@end
