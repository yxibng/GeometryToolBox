//
//  NXProtractorView.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import "NXProtractorView.h"
#import "NXGeometryToolLayout.hpp"
#import "NXGeometryToolBoxHelper.h"

@interface NXProtractorView ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *whiteboard;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *enlargeButton;

@property (nonatomic, strong) UIButton *rotationButton;

@property (nonatomic, strong) UIGestureRecognizer *moveGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *drawArcGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *drawLineGesture;


@property (nonatomic, assign) NXGeometryToolType geometryToolType;


@property (nonatomic, strong) UILabel *angleLabel_1;
@property (nonatomic, strong) UILabel *angleLabel_2;

@property (nonatomic, assign) CGFloat angle1InDegree;
@property (nonatomic, assign) CGFloat angle2InDegree;


@end
@implementation NXProtractorView

//创建的时候传入白板, 由此计算 whiteboardWidth
- (instancetype)initWithWhiteboard:(UIView *)whiteboard {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        
        _angle1InDegree = 0;
        _angle2InDegree = 0;
        
        _geometryToolType = NXGeometryToolTypeProtractor;
        _whiteboardWidth = whiteboard.bounds.size.width;
        _normPosition = CGPointMake(0.5, 1);
        _rotationAngle = 0;
        
        _normBaseSideLength = NXGeometryBox::ProtractorLayout::defaultNormRadius;
        _baseLengthRange = (NXGeometryToolBaseLengthRange) {
            .normMinLength = NXGeometryBox::ProtractorLayout::radiusRange().normMinLength,
            .normMaxLength = NXGeometryBox::ProtractorLayout::radiusRange().normMaxLength
        };
        
        _operationButtonEnabled = YES;
        
        self.layer.anchorPoint = CGPointMake(0.5, 1);
        self.backgroundColor = UIColor.clearColor;
//        self.backgroundColor = UIColor.redColor;
        
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onMovePanGestureChanged:)];
        moveGesture.delegate = self;
        [self addGestureRecognizer:moveGesture];
        _moveGesture = moveGesture;
        
        
        UIPanGestureRecognizer *drawArcGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onDrawArcGestureChanged:)];
        drawArcGesture.delegate = self;
        [self addGestureRecognizer:drawArcGesture];
        _drawArcGesture = drawArcGesture;
        
        
        UIPanGestureRecognizer *drawLineGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onDrawLineGestureChanged:)];
        drawLineGesture.delegate = self;
        [self addGestureRecognizer:drawLineGesture];
        _drawLineGesture = drawLineGesture;
        
        

        [self changeWhiteboard:whiteboard];
    }
    return self;
}


//白板变更
- (void)changeWhiteboard:(UIView *)whiteboard {
    
    NSAssert(whiteboard != nil, @"changeWhiteboard, whiteboard can not be nil!");
    _whiteboard = whiteboard;
    
    CGFloat whiteboardWidth = whiteboard.bounds.size.width;
    NSAssert(whiteboardWidth > 0, @"changeWhiteboard, whiteboardWidth can not be zero!");
    _whiteboardWidth = whiteboardWidth;
    
    [whiteboard addSubview:self];
    
    [self _recalculate];
    [self _redraw];
}

//同步角度旋转
- (void)syncRotationAngle:(CGFloat)rotationAngle {
    
}

//同步位置更新
- (void)syncPosition:(CGPoint)normPosition {
    
}

//同步基准变长更新
- (void)syncBaseSideLength:(CGFloat)normBaseSideLength {
    
}


- (void)_recalculate {
    
    const CGFloat whiteboardWidth = _whiteboardWidth;
    
    CGFloat x = whiteboardWidth * self.normPosition.x;
    CGFloat y = whiteboardWidth * self.normPosition.y;
    const CGFloat height =  whiteboardWidth * _normBaseSideLength;
    self.layer.bounds = CGRectMake(0, 0, height * 2, height);
    self.layer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, _rotationAngle);
    self.layer.position = CGPointMake(x, y);
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
    
    const CGFloat whiteboardWidth = self.whiteboardWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    const CGFloat radius = rect.size.height;
    //需要考虑线宽
    const CGFloat outerRadius = NXGeometryBox::ProtractorLayout::normOuterRadius(_normBaseSideLength) * whiteboardWidth;
    const CGFloat middleRadius = NXGeometryBox::ProtractorLayout::normMiddleRadius(_normBaseSideLength) * whiteboardWidth;
    const CGFloat innerRadius = NXGeometryBox::ProtractorLayout::normInnerRadius * whiteboardWidth;
    const CGPoint arcCenter = CGPointMake(rect.size.width/2, rect.size.height);
    
    //draw background color
    {
        
        //背景
        {
            CGContextBeginPath(context);
            UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:outerRadius startAngle:0 endAngle:M_PI clockwise:NO];
            [bgPath closePath];
            CGContextAddPath(context, bgPath.CGPath);
            CGContextClosePath(context);
            //fill path
            CGContextSetFillColorWithColor(context, NXGeometryToolDrawStyle.mainBackgroundColor.CGColor);
            CGContextFillPath(context);
        }
        //arc and line
        {
            
            CGContextBeginPath(context);
            
            UIBezierPath *outerPath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:outerRadius startAngle:0 endAngle:M_PI clockwise:NO];
            [outerPath closePath];
            CGContextAddPath(context, outerPath.CGPath);
            
            UIBezierPath *middleArc = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:middleRadius startAngle:0 endAngle:M_PI clockwise:NO];
            CGContextAddPath(context, middleArc.CGPath);
            
            UIBezierPath *innerArc = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:innerRadius startAngle:0 endAngle:M_PI clockwise:NO];
            CGContextAddPath(context, innerArc.CGPath);
            
            CGContextClosePath(context);
            
            //stroke path
            CGContextSetLineWidth(context, NXGeometryBox::DrawLineWidth);
            CGContextSetStrokeColorWithColor(context, NXGeometryToolDrawStyle.blackColor.CGColor);
            CGContextStrokePath(context);
            
        }
    }
    
    
    CGPoint start, end;
    for (int i = 1; i< 180; i++) {
        
        const CGFloat scaleMarkLength = [self normScaleMarkLengthWithIndex: i] * whiteboardWidth;
        CGFloat startRadius = 0;
        if (i % 10 == 0) {
            startRadius = innerRadius;
        } else {
            startRadius = middleRadius;
        }
        
        start.x = startRadius * cos(DEGREES_TO_RADIANS(i)) + radius;
        start.y = rect.size.height - startRadius * sin(DEGREES_TO_RADIANS(i));
        
        end.x = (middleRadius + scaleMarkLength) * cos(DEGREES_TO_RADIANS(i)) + radius;
        end.y = rect.size.height - (middleRadius + scaleMarkLength) * sin(DEGREES_TO_RADIANS(i));
        
        CGContextMoveToPoint(context, start.x, start.y);
        CGContextAddLineToPoint(context, end.x, end.y);
        
        
        start.x = outerRadius * cos(DEGREES_TO_RADIANS(i)) + radius;
        start.y = rect.size.height - outerRadius *sin(DEGREES_TO_RADIANS(i));
        end.x = (outerRadius - scaleMarkLength) * cos(DEGREES_TO_RADIANS(i)) + radius;
        end.y = rect.size.height - (outerRadius - scaleMarkLength) * sin(DEGREES_TO_RADIANS(i));
        
        CGContextMoveToPoint(context, start.x, start.y);
        CGContextAddLineToPoint(context, end.x, end.y);
    }
    
    CGContextSetLineWidth(context, NXGeometryBox::DrawLineWidth);
    CGContextSetStrokeColorWithColor(context, NXGeometryToolDrawStyle.blackColor.CGColor);
    CGContextStrokePath(context);
    
    
    //两条绿线
    {
        
        CGContextBeginPath(context);
        const CGFloat endPointRadius = (_normBaseSideLength - NXGeometryBox::ProtractorLayout::AngleMeasurer::normRadius * 2) * whiteboardWidth;
        //中心点
        {
            CGFloat degree = _angle1InDegree;
            CGContextMoveToPoint(context, radius, radius);
            CGFloat x = radius + endPointRadius * cos(DEGREES_TO_RADIANS(degree));
            CGFloat y = radius - endPointRadius * sin(DEGREES_TO_RADIANS(degree));
            CGContextAddLineToPoint(context, x, y);
        }
        
        {
            CGFloat degree = _angle2InDegree;
            CGContextMoveToPoint(context, radius, radius);
            CGFloat x = radius + endPointRadius * cos(DEGREES_TO_RADIANS(degree));
            CGFloat y = radius - endPointRadius * sin(DEGREES_TO_RADIANS(degree));
            CGContextAddLineToPoint(context, x, y);
        }
        CGContextSetStrokeColorWithColor(context, NXGeometryToolDrawStyle.greenColor.CGColor);
        CGContextSetLineWidth(context, NXGeometryBox::DrawLineWidth);
        CGContextStrokePath(context);
    }
    
    
    
    
    
    
    //刻度值，内圈， 逆时针
    const int indexForCalculateSmallTextSize = 80;
    const CGRect innerTextBounds = [self _layerWithIndex:indexForCalculateSmallTextSize].bounds;
    
    //中间弧度半径 + 刻度长度 + gap + textHeight / 2
    const CGFloat innerTextRadius = middleRadius + ([self normScaleMarkLengthWithIndex:indexForCalculateSmallTextSize] + NXGeometryBox::DrawStyle::normGapBetweenTextAndScaleMark) * whiteboardWidth + CGRectGetHeight(innerTextBounds) / 2;
    
    for (int i = 0; i <= 180; i = i + 10) {
        if (i == 90) {
            continue;
        }
        CGFloat fixedDegree  = 0;
        if (i == 0) {
            fixedDegree = 1.5;
        }
        
        if (i == 180) {
            fixedDegree = -3;
        }
        
        
        CGFloat actualDegree = i + fixedDegree;
        CGFloat rotationAngle = 0;
        CGPoint position = CGPointZero;
        position.x = innerTextRadius * cos(DEGREES_TO_RADIANS(actualDegree)) + radius;
        position.y = rect.size.height - innerTextRadius *sin(DEGREES_TO_RADIANS(actualDegree));
        
        if (actualDegree > 90) {
            rotationAngle = -DEGREES_TO_RADIANS(actualDegree - 90);
        } else {
            rotationAngle = DEGREES_TO_RADIANS(90 - actualDegree);
        }
        CATextLayer *layer = [self _layerWithIndex:i];
        [self.layer addSublayer:layer];
        layer.position = position;
        layer.affineTransform = CGAffineTransformMakeRotation(rotationAngle);
    }
    
    //外圈半径 - 刻度 - gap - textHeight / 2
    const CGFloat outerTextRadius = outerRadius - ([self normScaleMarkLengthWithIndex:indexForCalculateSmallTextSize] + NXGeometryBox::DrawStyle::normGapBetweenTextAndScaleMark) * whiteboardWidth - CGRectGetHeight(innerTextBounds) / 2;
    //刻度值，外圈， 顺时针
    for (int i = 0; i <= 180; i = i + 10) {
        if (i == 90) {
            continue;
        }
        CGFloat fixedDegree  = 0;
        if (i == 0) {
            fixedDegree = 1.5;
        }
        
        if (i == 180) {
            fixedDegree = -3;
        }
        
        CGFloat actualDegree = i + fixedDegree;
        actualDegree = 180 - actualDegree;
        
        CGFloat rotationAngle = 0;
        CGPoint position = CGPointZero;
        position.x = outerTextRadius * cos(DEGREES_TO_RADIANS(actualDegree)) + radius;
        position.y = rect.size.height - outerTextRadius *sin(DEGREES_TO_RADIANS(actualDegree));
        
        if (actualDegree > 90) {
            rotationAngle = -DEGREES_TO_RADIANS(actualDegree - 90);
        } else {
            rotationAngle = DEGREES_TO_RADIANS(90 - actualDegree);
        }
        CATextLayer *layer = [self _layerWithIndex:i];
        [self.layer addSublayer:layer];
        layer.position = position;
        layer.affineTransform = CGAffineTransformMakeRotation(rotationAngle);
    }
    
    //刻度值，处理 90 度
    const CGFloat text90Radius = outerRadius - (outerRadius - middleRadius) / 2;
    {
        CATextLayer *layer = [self _layerWithIndex:90];
        [self.layer addSublayer:layer];
        layer.position = CGPointMake(radius, radius - text90Radius);
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat whiteboardWidth = _whiteboardWidth;
    
    const CGFloat radius = _normBaseSideLength * whiteboardWidth;
    const CGFloat buttonRadius = NXGeometryBox::ProtractorLayout::normButtonRadius(_normBaseSideLength) * whiteboardWidth;
    
    const CGFloat normButtonSideLength = NXGeometryBox::NormButtonSideLength;
    const CGRect buttonBounds = CGRectMake(0, 0, normButtonSideLength * whiteboardWidth, normButtonSideLength * whiteboardWidth);
    self.closeButton.bounds = self.enlargeButton.bounds = self.rotationButton.bounds = buttonBounds;
    
    
    const CGFloat diffX = radius;
    
    
    CGFloat x = diffX + buttonRadius * cos(DEGREES_TO_RADIANS(180 - NXGeometryBox::ProtractorLayout::closeAndRotationButtonDegree));
    CGFloat y = radius - buttonRadius * sin(DEGREES_TO_RADIANS(180 - NXGeometryBox::ProtractorLayout::closeAndRotationButtonDegree));
    self.closeButton.layer.position = CGPointMake(x, y);
    
    x = diffX;
    y = radius - buttonRadius;
    self.enlargeButton.layer.position = CGPointMake(x, y);
    
    x = diffX + buttonRadius * cos(DEGREES_TO_RADIANS(NXGeometryBox::ProtractorLayout::closeAndRotationButtonDegree));
    y = radius - buttonRadius * sin(DEGREES_TO_RADIANS(NXGeometryBox::ProtractorLayout::closeAndRotationButtonDegree));
    self.rotationButton.layer.position = CGPointMake(x, y);
    
    
    
    {
        const CGFloat angleLableSideLength = 2 * NXGeometryBox::ProtractorLayout::AngleMeasurer::normRadius *  whiteboardWidth;
        
        const CGFloat angleRadius = (_normBaseSideLength - NXGeometryBox::ProtractorLayout::AngleMeasurer::normRadius) * whiteboardWidth;
        
        void (^configLable)(CGFloat degree, UILabel *label) = ^(CGFloat degree, UILabel *label) {
            
            label.bounds = CGRectMake(0, 0, angleLableSideLength , angleLableSideLength);
            label.layer.cornerRadius = angleLableSideLength / 2;
            label.layer.masksToBounds = YES;
            label.layer.borderColor = NXGeometryToolDrawStyle.greenColor.CGColor;
            label.layer.borderWidth = 2.0;
            
            CGFloat x = radius + angleRadius * cos(DEGREES_TO_RADIANS(degree));
            CGFloat y = radius - angleRadius * sin(DEGREES_TO_RADIANS(degree));
            label.layer.position = CGPointMake(x, y);
            
            const CGFloat fontSize = NXGeometryBox::ProtractorLayout::AngleMeasurer::normFontSize * whiteboardWidth;
            UIFont *font = [UIFont systemFontOfSize:fontSize];
            label.font = font;
            label.backgroundColor = UIColor.clearColor;
        };
        
        configLable(_angle1InDegree, self.angleLabel_1);
        configLable(_angle2InDegree, self.angleLabel_2);
        
        //update degree
        int angleInDegree = abs(_angle1InDegree - _angle2InDegree);
        _angleLabel_1.text = _angleLabel_2.text = @(angleInDegree).stringValue;
    }
}



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([super pointInside:point withEvent:event]) {
        return YES;
    }
    const CGFloat whiteboardWidth = self.whiteboardWidth;
    const CGFloat radius = whiteboardWidth * self.normBaseSideLength;
    const CGFloat outerRadius = NXGeometryBox::ProtractorLayout::normOuterRadius(self.normBaseSideLength) * whiteboardWidth;
    const CGFloat extHeight = NXGeometryBox::NormExtDrawAreaHeight * whiteboardWidth;
    CGRect extRect = CGRectMake(radius - outerRadius, radius, outerRadius * 2, extHeight);
    if (CGRectContainsPoint(extRect, point)) {
        return YES;
    }
    return NO;
}


#pragma mark -
- (CGFloat)normScaleMarkLengthWithIndex:(int)index {
    if (index % 10 == 0) {
        return NXGeometryBox::ScaleMarkLength::normLengthForType1cm;
    } else if (index % 5 == 0) {
        return NXGeometryBox::ScaleMarkLength::normLengthForType5mm;
    } else {
        return NXGeometryBox::ScaleMarkLength::normLengthForType1mm;
    }
}


- (CATextLayer *)_layerWithIndex:(int)index {
    CATextLayer *layer = [[CATextLayer alloc] init];
    layer.string = @(index).stringValue;
    
    CGFloat fontSize = NXGeometryBox::DrawStyle::normFontSize * _whiteboardWidth;
    UIColor *color = NXGeometryToolDrawStyle.blackColor;
    UIFont *font;
    if (index == 90) {
        fontSize = NXGeometryBox::ProtractorLayout::font90NormSize * _whiteboardWidth;
        font = [UIFont boldSystemFontOfSize:fontSize];
        color = NXGeometryToolDrawStyle.greenColor;
    } else if (index % 30 == 0) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
        
    }
    layer.fontSize = fontSize;
    CGRect textRect = [NXGeometryToolBoxHelper textRectWithString:layer.string font:font];
    layer.bounds = textRect;
    layer.foregroundColor = color.CGColor;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    return layer;
}


#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    const CGFloat whiteboardWidth = self.whiteboardWidth;
    const CGPoint location = [touch locationInView:self];
    const CGPoint center = CGPointMake(self.bounds.size.height, self.bounds.size.height);
    //外圈半径
    const CGFloat outerRadius = NXGeometryBox::ProtractorLayout::normOuterRadius(self.normBaseSideLength) * whiteboardWidth;
    
    CGFloat dx = center.x - location.x;
    CGFloat dy = center.y - location.y;
    CGFloat distance = sqrt(dx * dx + dy * dy);

    if (gestureRecognizer == self.drawArcGesture) {
        
        //外圈半径 - lengthForType1mm
        CGFloat minRadius = outerRadius - NXGeometryBox::ScaleMarkLength::normLengthForType1mm * whiteboardWidth;
        //外圈半径 + extDrawAreaHeight
        CGFloat maxRadius = outerRadius + NXGeometryBox::NormExtDrawAreaHeight * whiteboardWidth;
        if (distance >= minRadius && distance <= maxRadius) {
            return YES;
        }
    }
    
    
    if (gestureRecognizer == self.drawLineGesture) {
        const CGFloat whiteboardWidth = self.whiteboardWidth;
        const CGFloat radius = whiteboardWidth * self.normBaseSideLength;
        const CGFloat outerRadius = NXGeometryBox::ProtractorLayout::normOuterRadius(self.normBaseSideLength) * whiteboardWidth;
        const CGFloat extHeight = NXGeometryBox::NormExtDrawAreaHeight * whiteboardWidth;
        CGRect extRect = CGRectMake(radius - outerRadius, radius, outerRadius * 2, extHeight);
        if (CGRectContainsPoint(extRect, location)) {
            return YES;
        }
    }
    
    
    if (gestureRecognizer == self.moveGesture) {
        CGFloat radius = outerRadius - NXGeometryBox::ScaleMarkLength::normLengthForType1mm * whiteboardWidth;
        if (distance <= radius) {
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
        _enlargeButton.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
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
    CGPoint translation = [panGesture translationInView:self];
    CGFloat ratio = -translation.y / _whiteboardWidth;
    [panGesture setTranslation:CGPointZero inView:self];
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
    CGPoint translation = [moveGesture translationInView:self];
    CGPoint anchorPoint = self.layer.position;
    anchorPoint = self.layer.position;
    anchorPoint.x += translation.x;
    anchorPoint.y += translation.y;
    self.layer.position = anchorPoint;
    [moveGesture setTranslation:CGPointZero inView:self];
    
    _normPosition = CGPointMake(anchorPoint.x / _whiteboardWidth, anchorPoint.y / _whiteboardWidth);
}



- (void)_onRotationAngleLabelGestureChanged:(UIPanGestureRecognizer *)panGesture {
    
    const CGFloat minDegree = 0;
    const CGFloat maxDegree = 180;
    //FIXME: 这里的角度计算有问题
    if (panGesture.view == _angleLabel_1) {
        
        CGPoint location = [panGesture locationInView:self];
        CGFloat x = location.x - self.bounds.size.height;
        if (x < -self.bounds.size.height) {
            x = -self.bounds.size.height;
        }
        
        if (x > self.bounds.size.height) {
            x = self.bounds.size.height;
        }
        CGFloat cosx = x / self.bounds.size.height;
        CGFloat angle = acos(cosx);
        CGFloat nextDegree = ceil(RADIANS_TO_DEGREES(angle));
        
        if (nextDegree >= minDegree && nextDegree <= maxDegree) {
            _angle1InDegree = nextDegree;
            [self setNeedsLayout];
            [self layoutIfNeeded];
            [self setNeedsDisplay];
        }
    }
    
    
    if (panGesture.view == _angleLabel_2) {
        CGPoint location = [panGesture locationInView:self];
        CGFloat x = location.x - self.bounds.size.height;
        if (x < -self.bounds.size.height) {
            x = -self.bounds.size.height;
        }
        
        if (x > self.bounds.size.height) {
            x = self.bounds.size.height;
        }
        CGFloat cosx = x / self.bounds.size.height;
        CGFloat angle = acos(cosx);
        CGFloat nextDegree = ceil(RADIANS_TO_DEGREES(angle));
        
        if (nextDegree >= minDegree && nextDegree <= maxDegree) {
            _angle2InDegree = nextDegree;
            [self setNeedsLayout];
            [self layoutIfNeeded];
            [self setNeedsDisplay];
        }
    }
}


- (void)_onDrawArcGestureChanged:(UIPanGestureRecognizer *)panGesture {
    

    const CGFloat whiteboardWidth = self.whiteboardWidth;
    const CGPoint center = CGPointMake(self.bounds.size.height, self.bounds.size.height);
    //外圈半径
    const CGFloat outerRadius = NXGeometryBox::ProtractorLayout::normOuterRadius(self.normBaseSideLength) * whiteboardWidth + self.drawLineWidth / 2;

    CGPoint location = [panGesture locationInView:self];
    
    CGFloat dx =  location.x - center.x;
    CGFloat dy =  location.y - center.y;
    const CGFloat distance = sqrt(dx * dx + dy * dy);
    
    
    if (distance == 0) return;
    
    CGFloat cosx = dx / distance;
    CGFloat x = outerRadius * cosx + center.x;
    CGFloat angle = acos(cosx);
    CGFloat y = center.y - outerRadius * sin(angle);
    
    location.x = x;
    location.y = y;
    
    CGPoint locationInSuperView = [self convertPoint:location toView:self.superview];
    NSLog(@"location %@", NSStringFromCGPoint(location));
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"began");
            [self.protractorViewDelegate protractorView:self arcGestureBeganWithPoint:locationInSuperView center:self.layer.position];
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"changed");
            [self.protractorViewDelegate protractorView:self arcGestureMovedToPoint:locationInSuperView];
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"ended");
            [self.protractorViewDelegate protractorView:self arcGestureEndedWithPoint:locationInSuperView];
            break;
            
        case UIGestureRecognizerStateCancelled:
            NSLog(@"cancelled");
            break;

        default:
            break;
    }

}


- (void)_onDrawLineGestureChanged:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint location = [panGesture locationInView:self];
    location.y = self.bounds.size.height;
    CGPoint locationInSuperView = [self convertPoint:location toView:self.superview];
    NSLog(@"location %@", NSStringFromCGPoint(location));
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"began");
            [self.protractorViewDelegate protractorView:self lineGestureBeganWithPoint:locationInSuperView];
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"changed");
            [self.protractorViewDelegate protractorView:self lineGestureMovedToPoint:locationInSuperView];
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"ended");
            [self.protractorViewDelegate protractorView:self lineGestureEndedWithPoint:locationInSuperView];
            break;
            
        case UIGestureRecognizerStateCancelled:
            NSLog(@"cancelled");
            break;

        default:
            break;
    }

}




#pragma mark -

- (UILabel *)angleLabel_1 {
    
    if (!_angleLabel_1) {
        _angleLabel_1 = [[UILabel alloc] init];
        _angleLabel_1.textColor = NXGeometryToolDrawStyle.greenColor;
        _angleLabel_1.textAlignment = NSTextAlignmentCenter;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onRotationAngleLabelGestureChanged:)];
        [_angleLabel_1 addGestureRecognizer:pan];
        _angleLabel_1.userInteractionEnabled = _operationButtonEnabled;
        [self addSubview:_angleLabel_1];
    }
    return _angleLabel_1;
}


- (UILabel *)angleLabel_2 {
    
    if (!_angleLabel_2) {
        _angleLabel_2 = [[UILabel alloc] init];
        _angleLabel_2.textColor = NXGeometryToolDrawStyle.greenColor;
        _angleLabel_2.textAlignment = NSTextAlignmentCenter;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onRotationAngleLabelGestureChanged:)];
        [_angleLabel_2 addGestureRecognizer:pan];
        _angleLabel_2.userInteractionEnabled = _operationButtonEnabled;
        [self addSubview:_angleLabel_2];
    }
    return _angleLabel_2;
}

@end
