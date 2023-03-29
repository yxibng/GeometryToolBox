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
@property (nonatomic, assign, readonly) CGPoint penNibPoint;

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


- (BOOL)pointInPen:(CGPoint)point {
    
    const CGFloat normWidth = 35/ 95.0;
    const CGFloat normHeight = 294 /95.0;
    const CGFloat boundWidth = self.bounds.size.width;
    const CGFloat width = normWidth * boundWidth;
    const CGFloat height = normHeight * boundWidth;
    
    //顺时针旋转了11度
    const CGFloat rotationDegree = 11.0;
    {
        /*
         CGAffineTransformMakeRotation
         angle >0, 逆时针
         angle <0, 顺时针
         */
        
        
        CGFloat x = boundWidth * 61 / 95.0;
        CGFloat y = boundWidth * 78 / 95.0;
        
        const CGAffineTransform translation = CGAffineTransformMakeTranslation(-x, -y);
        const CGAffineTransform rotation = CGAffineTransformMakeRotation(-DEGREES_TO_RADIANS(rotationDegree));
        
        CGPoint p = CGPointApplyAffineTransform(point, translation);
        p = CGPointApplyAffineTransform(p, rotation);
        //笔杆
        CGRect rect = CGRectMake(0, 0, width, height);
        if (CGRectContainsPoint(rect, p)) {
            return YES;
        }
        
        const CGFloat triangleWidth = width / 2;
        const CGFloat triangleHeight = 62 / 95.0 * boundWidth;
        
        //笔尖, 左一半三角形
        if ( p.x <= triangleWidth && p.x >= 0) {
            CGFloat diffY = p.y - height;
            CGFloat maxY = p.x * triangleHeight / triangleWidth;
            if (diffY >= 0 && diffY <= maxY ) {
                return YES;
            }
        }
        
        //笔尖，右一半三角形
        if ( p.x >= triangleWidth && p.x <= width ) {
            CGFloat diffY = p.y - height;
            CGFloat maxY = (width - p.x) * triangleHeight / triangleWidth;
            if (diffY >= 0 && diffY <= maxY ) {
                return YES;
            }
        }
    }
    return NO;
}


- (CGPoint)penNibPoint {
    return CGPointMake(0, self.bounds.size.height);
}

@end



#pragma mark -


@interface NXCompassView ()<UIGestureRecognizerDelegate>

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
    
    self.clipsToBounds = NO;
    self.backgroundColor = UIColor.clearColor;
    //锚点设置为右下角
    self.layer.anchorPoint = CGPointMake(1.0, 1.0);
    
    _rotationAngle = 0;
    _openAngleInDegree = 0;
    
    //move gesture
    {
        _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onMovePanGestureChanged:)];
        [self addGestureRecognizer:_moveGesture];
    }
    
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
            drawArcGesture.delegate = self;
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
    
}

#pragma mark - 
//同步打开角度变更
- (void)syncOpenAngleInDegree:(CGFloat)openAngleInDegree {
    self.openAngleInDegree = openAngleInDegree;
}
//同步锁定状态
- (void)syncCurrentOpenAngleLocked:(BOOL)currentOpenAngleLocked {
    self.currentOpenAngleLocked = currentOpenAngleLocked;
}
//同步旋转角度
- (void)syncRotationAngle:(CGFloat)rotationAngle {
    self.rotationAngle = rotationAngle;
}
//同步锚点位置
- (void)syncNormPosition:(CGPoint)normPosition {
    self.normPosition = normPosition;
}



#pragma mark -

- (void)setWhiteboardWidth:(CGFloat)whiteboardWidth {
    
    if (_whiteboardWidth == whiteboardWidth) {
        return;
    }
    _whiteboardWidth = whiteboardWidth;
    {
        CGRect bounds = self.bounds;
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


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (gestureRecognizer == self.drawArcGesture) {
        if ([touch.view isDescendantOfView:self.penImageView.enalrgeButton]) {
            return NO;
        }
        CGPoint point = [touch locationInView:self.penImageView];
        if ([self.penImageView pointInPen:point]) {
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
    //notify norm position changed
    if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onNormPositionChanged:)]) {
        [self.delegate geometryTool:self onNormPositionChanged:_normPosition];
    }
}

- (void)_onEnlargePanGestureChanged:(UIPanGestureRecognizer *)panGesture {
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
            if (!self.currentOpenAngleLocked) {
                //非锁定状态，才可以改变开合角度
                CGPoint center = [self convertPoint:CGPointMake(self.bounds.size.width, 0) toView:self.superview];
                CGFloat angle = [NXGeometryToolBoxHelper rotationAngleWithCenter:center startPoint:pre endPoint:cur];
                CGFloat degree = RADIANS_TO_DEGREES(angle);
                CGFloat nextDegree = _openAngleInDegree - degree;
                if (nextDegree <= 0) {
                    nextDegree = 0;
                } else if (nextDegree >= 130) {
                    nextDegree = 130;
                }
                
                if (_openAngleInDegree != nextDegree) {
                    _openAngleInDegree = nextDegree;
                    //notify openAngleInDegree changed
                    if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onOpenAngleChanged:)]) {
                        [self.delegate geometryTool:self onOpenAngleChanged:_openAngleInDegree];
                    }
                }
            }
            //update rotation angle
            {
                CGFloat angle = [NXGeometryToolBoxHelper rotationAngleWithCenter:self.layer.position startPoint:pre endPoint:cur];
                _rotationAngle += angle;
                self.layer.affineTransform = CGAffineTransformMakeRotation(_rotationAngle);
                //notify rotation angle changed
                if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onRotationAngleChanged:)]) {
                    [self.delegate geometryTool:self onRotationAngleChanged:_rotationAngle];
                }
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
    
    //参考： https://ost.51cto.com/posts/89
    CGPoint point = [self.penImageView convertPoint:self.penImageView.penNibPoint toView:self.superview];
    static CGPoint pre;
    switch (rotationGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            pre = [rotationGesture locationInView:self.superview];
            if ([self.delegate respondsToSelector:@selector(geometryTool:onDrawArcBeganAtPoint:center:)]) {
                [self.delegate geometryTool:self onDrawArcBeganAtPoint:point center:self.layer.position];
            }
        }
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
            
            //notify rotation angle changed
            if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onRotationAngleChanged:)]) {
                [self.delegate geometryTool:self onRotationAngleChanged:_rotationAngle];
            }
            //notify draw arc changed
            if (rotationGesture.state == UIGestureRecognizerStateChanged) {
                if ([self.delegate respondsToSelector:@selector(geometryTool:onDrawArcMovedToPoint:)]) {
                    [self.delegate geometryTool:self onDrawArcMovedToPoint:point];
                }
            } else if (rotationGesture.state == UIGestureRecognizerStateEnded) {
                if ([self.delegate respondsToSelector:@selector(geometryTool:onDrawArcEndedAtPoint:)]) {
                    [self.delegate geometryTool:self onDrawArcEndedAtPoint:point];
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -

- (void)_onClickChangeLockStateButton:(UIButton *)sender {
    self.currentOpenAngleLocked = !self.currentOpenAngleLocked;
    //notify lock state changed
    if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onCurrentOpenAngleLockStateChanged:)]) {
        [self.delegate geometryTool:self onCurrentOpenAngleLockStateChanged:self.currentOpenAngleLocked];
    }
}

- (void)_onClickCloseButton:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(geometryToolOnCloseButtonClicked:)]) {
        [self.delegate geometryToolOnCloseButtonClicked:self];
    }
}



@end
