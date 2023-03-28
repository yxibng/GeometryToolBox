//
//  NXRulerView.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import "NXRulerView.h"
#import "NXGeometryToolLayout.hpp"
#import "NXGeometryToolBoxHelper.h"


@interface NXRulerView () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIView *whiteboard;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *enlargeButton;

@property (nonatomic, strong) UIButton *rotationButton;

@property (nonatomic, strong) UIPanGestureRecognizer *moveGesture;

@property (nonatomic, strong) UIPanGestureRecognizer *drawLineGesture;


@property (nonatomic, assign) NXGeometryToolType geometryToolType;

@end


@implementation NXRulerView


- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    
    _geometryToolType = NXGeometryToolTypeRuler;
    _normBaseSideLength = NXGeometryBox::RulerLayout::defaultNormWidth();
    _baseLengthRange = (NXGeometryToolBaseLengthRange) {
        .normMinLength = NXGeometryBox::RulerLayout::normWidthRange().normMinLength,
        .normMaxLength = NXGeometryBox::RulerLayout::normWidthRange().normMaxLength
    };
    _rotationAngle = 0;
    
    //锚点设置为左上角
    self.layer.anchorPoint = CGPointMake(0, 0);
    
    //TODO: 这里直接改成划线？
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 4.0;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.backgroundColor = UIColor.clearColor;

    //默认不响应事件
    self.userInteractionEnabled = NO;
    //move 手势
    {
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onMovePanGestureChanged:)];
        moveGesture.delegate = self;
        [self addGestureRecognizer:moveGesture];
        _moveGesture = moveGesture;
    }
    //划线手势
    {
        UIPanGestureRecognizer *drawLineGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onDrawLinePanGestureChanged:)];
        drawLineGesture.delegate = self;
        [self addGestureRecognizer:drawLineGesture];
        _drawLineGesture = drawLineGesture;
    }
}


//同步角度旋转
- (void)syncRotationAngle:(CGFloat)rotationAngle {
    self.rotationAngle = rotationAngle;
}

//同步位置更新
- (void)syncNormPosition:(CGPoint)normPosition {
    self.normPosition = normPosition;
}

//同步基准变长更新
- (void)syncNormBaseSideLength:(CGFloat)normBaseSideLength {
    self.normBaseSideLength = normBaseSideLength;
}

- (void)_recalculate {
    
    CGFloat x = _whiteboardWidth * self.normPosition.x;
    CGFloat y = _whiteboardWidth * self.normPosition.y;
    self.layer.bounds = CGRectMake(0, 0, _whiteboardWidth * _normBaseSideLength, _whiteboardWidth * NXGeometryBox::RulerLayout::normHeight);
    self.layer.position = CGPointMake(x, y);
    self.layer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, _rotationAngle);
}

- (void)_redraw {
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    NSArray<CALayer *> *layers = [self.layer.sublayers copy];
    
    for (CATextLayer *layer in layers) {
        if ([layer isKindOfClass:CATextLayer.class]) {
            [layer removeFromSuperlayer];
        }
    }
    
    const CGFloat whiteboardWidth = _whiteboardWidth;
    const CGFloat startPadding = NXGeometryBox::RulerLayout::Padding().normStartPadding * whiteboardWidth;
    const CGFloat endPadding = NXGeometryBox::RulerLayout::Padding().normEndPadding * whiteboardWidth;
    const CGFloat mmWidth = whiteboardWidth * NXGeometryBox::NormOneCm / 10;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    //draw background color
    {
        CGFloat scaleMarkAreaHeight = whiteboardWidth * NXGeometryBox::ScaleMarkLength::normLengthForType1mm;
        CGContextSetFillColorWithColor(context, NXGeometryToolDrawStyle.scaleMarkAreaBackgroundColor.CGColor);

        CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, scaleMarkAreaHeight));        
        CGContextSetFillColorWithColor(context, NXGeometryToolDrawStyle.mainBackgroundColor.CGColor);
        CGContextFillRect(context, CGRectMake(0, scaleMarkAreaHeight, rect.size.width, rect.size.height-scaleMarkAreaHeight));
    }
    
    // Drawing code
    const int num = ceil(rect.size.width - startPadding -endPadding) / mmWidth;
    CGPoint start, end;
    for (int i = 0; i <= num; i++) {
        start.x = end.x = mmWidth * i + startPadding;
        start.y = 0;
        //绘制刻度线
        float scaleMarkLength = 0;
        if (i % 10 == 0) {
            scaleMarkLength = whiteboardWidth * NXGeometryBox::ScaleMarkLength::normLengthForType1cm;
        } else if (i % 5 == 0) {
            scaleMarkLength = whiteboardWidth * NXGeometryBox::ScaleMarkLength::normLengthForType5mm;
        } else {
            scaleMarkLength = whiteboardWidth * NXGeometryBox::ScaleMarkLength::normLengthForType1mm;
        }
        end.y = scaleMarkLength;
        
        if (i % 50 == 0) {
            //之前黑色刻度
            CGContextSetStrokeColorWithColor(context, NXGeometryToolDrawStyle.blackColor.CGColor);
            CGContextStrokePath(context);
            
            //当前绿色刻度
            CGContextMoveToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, end.x, end.y);
            
            CGContextSetStrokeColorWithColor(context, NXGeometryToolDrawStyle.greenColor.CGColor);

            CGContextStrokePath(context);
    
            //重置绘制颜色
            CGContextSetStrokeColorWithColor(context, NXGeometryToolDrawStyle.blackColor.CGColor);
        } else {
            CGContextMoveToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, end.x, end.y);
        }
        
        //绘制刻度值
        if (i % 10 == 0) {
            int index = i / 10;
            CATextLayer *layer = [self _layerWithIndex:index];
            CGFloat width = CGRectGetWidth(layer.bounds);
            CGFloat height = CGRectGetHeight(layer.bounds);
            CGFloat gap = whiteboardWidth * NXGeometryBox::DrawStyle::normGapBetweenTextAndScaleMark;
            layer.frame = CGRectMake(end.x - width / 2, end.y + gap, width, height);
            [self.layer addSublayer:layer];
        }
    }
    CGContextSetLineWidth(context, NXGeometryBox::DrawLineWidth);
    CGContextSetStrokeColorWithColor(context, NXGeometryToolDrawStyle.blackColor.CGColor);
    CGContextStrokePath(context);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat whiteboardWidth = self.whiteboardWidth;
    const CGRect rect = self.bounds;
    
    CGFloat sideLength = whiteboardWidth * NXGeometryBox::NormButtonSideLength;
    CGFloat leftMargin = whiteboardWidth * NXGeometryBox::RulerLayout::normButtonLeftMargin;
    CGFloat bottomMargin = whiteboardWidth * NXGeometryBox::RulerLayout::normButtonBottomMargin;
    {
        self.closeButton.bounds = CGRectMake(0, 0, sideLength , sideLength);
        CGFloat x = leftMargin + sideLength / 2;
        CGFloat y = rect.size.height - (bottomMargin + sideLength /2);
        _closeButton.layer.position = CGPointMake(x, y);
    }
    
    {
        
        self.enlargeButton.bounds = CGRectMake(0, 0, sideLength , sideLength);
        CGFloat x = rect.size.width / 2;
        CGFloat y = rect.size.height - (bottomMargin + sideLength /2);
        _enlargeButton.layer.position = CGPointMake(x, y);
    }

    {
        self.rotationButton.bounds = CGRectMake(0, 0, sideLength , sideLength);
        CGFloat x = rect.size.width - (leftMargin + sideLength / 2);
        CGFloat y = rect.size.height - (bottomMargin + sideLength /2);
        _rotationButton.layer.position = CGPointMake(x, y);
    }
}


- (CATextLayer *)_layerWithIndex:(int)index {
    CATextLayer *layer = [[CATextLayer alloc] init];
    layer.string = @(index).stringValue;
    
    const CGFloat fontSize = NXGeometryBox::DrawStyle::normFontSize * _whiteboardWidth;
    UIFont *font;
    UIColor *color;
    if (index % 5 == 0) {
        font = [UIFont boldSystemFontOfSize:fontSize];
        color = NXGeometryToolDrawStyle.greenColor;
    } else {
        font = [UIFont systemFontOfSize:fontSize];
        color = NXGeometryToolDrawStyle.blackColor;
    }
    layer.fontSize = fontSize;
    CGRect textRect = [NXGeometryToolBoxHelper textRectWithString:layer.string font:font];
    layer.bounds = textRect;
    layer.foregroundColor = color.CGColor;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    return layer;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL ret = [super pointInside:point withEvent:event];
    if (ret) return YES;
    CGFloat extDrawAreaHeight = NXGeometryBox::NormExtDrawAreaHeight * _whiteboardWidth;
    CGRect rect = CGRectMake(0, -extDrawAreaHeight, self.bounds.size.width, extDrawAreaHeight);
    return CGRectContainsPoint(rect, point);
}

#pragma mark -
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (gestureRecognizer == self.moveGesture) {
        CGPoint point = [touch locationInView:self];
        const CGFloat y = _whiteboardWidth * NXGeometryBox::ScaleMarkLength::normLengthForType1mm;
        CGRect bounds = self.bounds;
        bounds.origin.y = y;
        
        if (CGRectContainsPoint(bounds, point)) {
            return YES;
        }
    }
    
    if (gestureRecognizer == self.drawLineGesture) {
        
        CGPoint point = [touch locationInView:self];
        const CGFloat extDrawAreaHeight = _whiteboardWidth * NXGeometryBox::NormExtDrawAreaHeight;
        const CGFloat insideDrawAreaHeight = _whiteboardWidth * NXGeometryBox::ScaleMarkLength::normLengthForType1mm;
        CGRect bounds = self.bounds;
        bounds.origin.y = -extDrawAreaHeight;
        bounds.size.height = extDrawAreaHeight + insideDrawAreaHeight;
        if (CGRectContainsPoint(bounds, point)) {
            return YES;
        }
    }
    return NO;
}


#pragma mark -

- (void)setWhiteboardWidth:(CGFloat)whiteboardWidth {
    if (_whiteboardWidth == whiteboardWidth) {
        return;
    }
    _whiteboardWidth = whiteboardWidth;
    [self _recalculate];
    [self _redraw];
}

- (void)setNormPosition:(CGPoint)normPosition {
    if (CGPointEqualToPoint(_normPosition, normPosition)) {
        return;
    }
    _normPosition = normPosition;
    [self _recalculate];
    [self _redraw];
}

- (void)setNormBaseSideLength:(CGFloat)normBaseSideLength {
    if (_normBaseSideLength == normBaseSideLength) {
        return;
    }
    if (normBaseSideLength >= _baseLengthRange.normMinLength && normBaseSideLength <= _baseLengthRange.normMaxLength) {
        _normBaseSideLength = normBaseSideLength;
        [self _recalculate];
        [self _redraw];
    }
}

- (void)setRotationAngle:(CGFloat)rotationAngle {
    if (_rotationAngle == rotationAngle) {
        return;
    }
    _rotationAngle = rotationAngle;
    [self _recalculate];
    [self _redraw];
}


- (void)setUserActionAllowed:(BOOL)userActionAllowed {
    _userActionAllowed = userActionAllowed;
    self.userInteractionEnabled = userActionAllowed;
}


- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(_onClickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }
    return _closeButton;
}

- (UIButton *)enlargeButton {
    if (!_enlargeButton) {
        _enlargeButton = [[UIButton alloc] init];
        [_enlargeButton setImage:[UIImage imageNamed:@"pull"] forState:UIControlStateNormal];
        
        UIPanGestureRecognizer *pan =  [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onEnlargePanGestureChanged:)];
        [_enlargeButton addGestureRecognizer:pan];
        [self addSubview:_enlargeButton];
    }
    return _enlargeButton;
}

- (UIButton *)rotationButton {
    if (!_rotationButton) {
        _rotationButton = [[UIButton alloc] init];
        [_rotationButton setImage:[UIImage imageNamed:@"rotate"] forState:UIControlStateNormal];
        
        UIPanGestureRecognizer *pan =  [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onRotationPanGestureChanged:)];
        [_rotationButton addGestureRecognizer:pan];
        [self addSubview:_rotationButton];
    }
    return _rotationButton;
}

#pragma mark -

- (void)_onClickCloseButton:(UIButton *)button {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.delegate && [self.delegate respondsToSelector:@selector(geometryToolOnCloseButtonClicked:)]) {
        [self.delegate geometryToolOnCloseButtonClicked:self];
    }
}

- (void)_onEnlargePanGestureChanged:(UIPanGestureRecognizer *)panGesture {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSAssert(_whiteboardWidth > 0, @"_onEnlargePanGestureChanged, whiteboardWidth can not be zero!");
    CGPoint translation = [panGesture translationInView:self.superview];
    CGFloat ratio = translation.x * 2 / _whiteboardWidth;
    [panGesture setTranslation:CGPointZero inView:self.superview];
    CGFloat newWidth = _normBaseSideLength + ratio;
    if (newWidth >= _baseLengthRange.normMinLength && newWidth <= _baseLengthRange.normMaxLength) {
        _normBaseSideLength = newWidth;
        [self _recalculate];
        [self _redraw];
    }
}


- (void)_onRotationPanGestureChanged:(UIPanGestureRecognizer *)rotationGesture {
    
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
            _rotationAngle += angle;
            self.layer.affineTransform = CGAffineTransformMakeRotation(_rotationAngle);
            pre = cur;
        }
            break;
        default:
            break;
    }
}

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


- (void)_onDrawLinePanGestureChanged:(UIPanGestureRecognizer *)panGesture {
#if 0
    CGPoint translation = [panGesture translationInView:self];
    CGPoint location = [panGesture locationInView:self];
    //drop y to zero
    location.y = 0;
    location.y -= self.drawLineWidth / 2;
    CGPoint locationInSuperView = [self convertPoint:location toView:self.superview];
    NSLog(@"translation %@", NSStringFromCGPoint(translation));
    NSLog(@"location %@", NSStringFromCGPoint(location));
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"began");
            [self.rulerViewDelegate rulerView:self gestureBeganWithPoint:locationInSuperView];
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"changed");
            [self.rulerViewDelegate rulerView:self gestureMovedToPoint:locationInSuperView];
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"ended");
            [self.rulerViewDelegate rulerView:self gestureEndedWithPoint:locationInSuperView];
            break;
            
        case UIGestureRecognizerStateCancelled:
            NSLog(@"cancelled");
            break;

        default:
            break;
    }
#endif
}

@end
