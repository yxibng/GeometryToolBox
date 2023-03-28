//
//  NXRightTriangleView.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import "NXRightTriangleView.h"
#import "NXGeometryToolLayout.hpp"
#import "NXGeometryToolBoxHelper.h"



@interface NXRightTriangleView ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *whiteboard;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *enlargeButton;

@property (nonatomic, strong) UIButton *rotationButton;

@property (nonatomic, strong) UIGestureRecognizer *moveGesture;

@property (nonatomic, assign) NXGeometryToolType geometryToolType;

@end

@implementation NXRightTriangleView

//创建的时候传入白板, 由此计算 whiteboardWidth
- (instancetype)initWithWhiteboard:(UIView *)whiteboard {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        _geometryToolType = NXGeometryToolTypeRightTriangle;
        _whiteboardWidth = whiteboard.bounds.size.width;
        _normPosition = CGPointMake(0.5, 0.5);
        _rotationAngle = 0;
        
        _normBaseSideLength = NXGeometryBox::RightTriangleLayout::defaultShortCatetoNormHeight();
        _baseLengthRange = (NXGeometryToolBaseLengthRange) {
            .normMinLength = NXGeometryBox::RightTriangleLayout::normHeightRange().normMinLength,
            .normMaxLength = NXGeometryBox::RightTriangleLayout::normHeightRange().normMaxLength
        };
        
        _operationButtonEnabled = NO;
        
        self.layer.anchorPoint = CGPointMake(0, 1);
        self.backgroundColor = UIColor.clearColor;
        
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onMovePanGestureChanged:)];
        moveGesture.delegate = self;
        [self addGestureRecognizer:moveGesture];
        _moveGesture = moveGesture;
        
        
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
    
    
    const CGFloat whiteboardWidth = self.whiteboardWidth;
    
    CGFloat x = whiteboardWidth * self.normPosition.x;
    CGFloat y = whiteboardWidth * self.normPosition.y;
    
    CGFloat height = whiteboardWidth * self.normBaseSideLength;
    CGFloat width = height * tan(DEGREES_TO_RADIANS(60));
    
    self.layer.bounds = CGRectMake(0, 0, width, height);
    self.layer.position = CGPointMake(x, y);
    self.layer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, _rotationAngle);
}

- (void)_redraw {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    NSArray<CALayer *> *layers = [self.layer.sublayers copy];
    for (CALayer *layer in layers) {
        if ([layer isKindOfClass:CATextLayer.class]) {
            [layer removeFromSuperlayer];
        }
    }
    
    const CGFloat whiteboardWidth = self.whiteboardWidth;
    const CGFloat mmWidth = whiteboardWidth * NXGeometryBox::NormOneCm / 10;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    //draw background
    {
        
        CGContextMoveToPoint(context, 0, 0);
        CGPoint lines[3]  = {
            CGPointMake(0, 0),
            CGPointMake(0, rect.size.height),
            CGPointMake(rect.size.width, rect.size.height)
        };
        CGContextSetFillColorWithColor(context, NXGeometryToolDrawStyle.mainBackgroundColor.CGColor);
        CGContextAddLines(context, lines, 3);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
    
    /*
     1. 画左边
     2. 画下边
     3. 画斜边
     */
    
    // Drawing left
    {
        
        auto padding = NXGeometryBox::RightTriangleLayout::paddingForShortCateto();
        const CGFloat startPadding = whiteboardWidth * padding.normStartPadding;
        const CGFloat endPadding = whiteboardWidth * padding.normEndPadding;
        //考虑线宽
        CGContextMoveToPoint(context, NXGeometryBox::DrawLineWidth / 2, 0);
        CGContextAddLineToPoint(context, NXGeometryBox::DrawLineWidth / 2, rect.size.height);
        int num = ceil(rect.size.height - startPadding - endPadding) / mmWidth;
        CGPoint start, end;
        for (int i = 0; i <= num; i++) {
            //画刻度, 从下往上画
            start.x = 0;
            start.y = end.y = rect.size.height -  (mmWidth * i + startPadding);
            CGFloat scaleMarkLength = whiteboardWidth * [self normScaleMarkLengthWithIndex:i];
            end.x = start.x + scaleMarkLength;
            
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
            
            //画刻度值
            if (i % 10 == 0) {
                int index = i / 10;
                if (index > 0) {
                    CATextLayer *layer = [self _layerWithIndex:index];
                    CGFloat width = CGRectGetWidth(layer.bounds);
                    CGFloat height = CGRectGetHeight(layer.bounds);
                    CGFloat ratio = height / width;
                    CGFloat gap = whiteboardWidth * NXGeometryBox::DrawStyle::normGapBetweenTextAndScaleMark * ratio;
                    layer.frame = CGRectMake(end.x + gap, end.y - height / 2, width, height);
                    [self.layer addSublayer:layer];
                    layer.affineTransform = CGAffineTransformMakeRotation(-M_PI_2);
                }
            }
        }
    }
    
    // Drawing bottom
    {
        
        auto padding = NXGeometryBox::RightTriangleLayout::paddingForLongCateto();
        
        const CGFloat startPadding = padding.normStartPadding * whiteboardWidth;
        const CGFloat endPadding = padding.normEndPadding * whiteboardWidth;
        //考虑线宽
        CGContextMoveToPoint(context, 0, rect.size.height - NXGeometryBox::DrawLineWidth / 2);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height - NXGeometryBox::DrawLineWidth / 2);
        
        int num = ceil(rect.size.width - startPadding - endPadding) / mmWidth;
        CGPoint start, end;
        for (int i = 0; i <= num; i++) {
            //画刻度, 从左往右画
            start.x = end.x = mmWidth *i + startPadding;
            start.y = rect.size.height;
            
            CGFloat scaleMarkLength = whiteboardWidth * [self normScaleMarkLengthWithIndex:i];
            end.y = start.y - scaleMarkLength;
            
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
            
            
            //画刻度值
            if (i % 10 == 0) {
                int index = i / 10;
                if (index > 0) {
                    CATextLayer *layer = [self _layerWithIndex:index];
                    CGFloat height = CGRectGetHeight(layer.bounds);
                    CGFloat gap = NXGeometryBox::DrawStyle::normGapBetweenTextAndScaleMark * whiteboardWidth;
                    [self.layer addSublayer:layer];
                    layer.position = CGPointMake(end.x, end.y - height/2 - gap);
                }
            }
        }
    }
    
    // Drawing hypotenuse
    {
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
        
        auto padding = NXGeometryBox::RightTriangleLayout::paddingForHipotenusa();
        const float startPadding = padding.normStartPadding * whiteboardWidth;
        const float endPadding = padding.normEndPadding * whiteboardWidth;
        
        CGFloat length = sqrt(pow(rect.size.width, 2.0) + pow(rect.size.height, 2.0));
        int num = (length - startPadding - endPadding) / mmWidth;
        CGPoint start, end;
        for (int i = 0; i <= num; i++) {
            //画刻度, 从左往右画
            start.x = (mmWidth * i + startPadding) * sin(DEGREES_TO_RADIANS(60));
            start.y = (mmWidth * i + startPadding) * sin(DEGREES_TO_RADIANS(30));
            float scaleMarkLength = whiteboardWidth * [self normScaleMarkLengthWithIndex:i];
            end.x = start.x - scaleMarkLength * sin(DEGREES_TO_RADIANS(30));
            end.y = start.y + scaleMarkLength * sin(DEGREES_TO_RADIANS(60));
            
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
            
            //画刻度值
            if (i % 10 == 0) {
                int index = i / 10;
                CATextLayer *layer = [self _layerWithIndex:index];
                CGFloat width = CGRectGetWidth(layer.bounds);
                CGFloat height = CGRectGetHeight(layer.bounds);
                
                CGFloat gap = whiteboardWidth * NXGeometryBox::DrawStyle::normGapBetweenTextAndScaleMark;
                
                CGFloat layerCenterX = end.x - (gap + height / 2) * sin(DEGREES_TO_RADIANS(30));
                CGFloat layerCenterY = end.y + (gap + height / 2) * sin(DEGREES_TO_RADIANS(60));
                
                layer.frame = CGRectMake(layerCenterX - width / 2 , layerCenterY - height / 2, width, height);
                [self.layer addSublayer:layer];
                //TODO: 这里必须在添加以后，仿射变换才生效 ？？？
                layer.affineTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(30));
            }
        }
    }
    CGContextSetLineWidth(context, NXGeometryBox::DrawLineWidth);
    CGContextSetStrokeColorWithColor(context, NXGeometryToolDrawStyle.blackColor.CGColor);
    CGContextStrokePath(context);
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat whiteboardWidth = _whiteboardWidth;
    const CGFloat normButtonSideLength = NXGeometryBox::NormButtonSideLength;
    const CGRect buttonBounds = CGRectMake(0, 0, normButtonSideLength * whiteboardWidth, normButtonSideLength * whiteboardWidth);
    
    self.closeButton.bounds = self.enlargeButton.bounds = self.rotationButton.bounds = buttonBounds;
    
    auto normCloseAnchorPoint = NXGeometryBox::RightTriangleLayout::normCloseButtonAnchorPoint();
    self.closeButton.layer.position = CGPointMake(whiteboardWidth * normCloseAnchorPoint.x, whiteboardWidth * normCloseAnchorPoint.y);
    
    auto normRotationAnchorPoint = NXGeometryBox::RightTriangleLayout::normRotationButtonAnchorPoint(self.normBaseSideLength);
    self.rotationButton.layer.position = CGPointMake(whiteboardWidth * normRotationAnchorPoint.x, whiteboardWidth * normRotationAnchorPoint.y);
    
    auto normEnlargeAnchorPoint = NXGeometryBox::RightTriangleLayout::normEnlargeButtonAnchorPoint(normCloseAnchorPoint, normRotationAnchorPoint);
    self.enlargeButton.layer.position = CGPointMake(whiteboardWidth * normEnlargeAnchorPoint.x, whiteboardWidth * normEnlargeAnchorPoint.y);
}


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


//TODO: 响应范围
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    //    BOOL ret = [super pointInside:point withEvent:event];
    //    if (ret) return YES;
    //    CGFloat extDrawAreaHeight = NXTeachToolPosition.normDrawAreaExtendedHeight * self.position.whiteboard.frame.size.width;
    //    CGRect rect = CGRectMake(0, -extDrawAreaHeight, self.bounds.size.width, extDrawAreaHeight);
    //    return CGRectContainsPoint(rect, point);
    return YES;
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
        _enlargeButton.layer.affineTransform = CGAffineTransformMakeRotation(-DEGREES_TO_RADIANS(60));
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
    CGFloat ratio = translation.x / _whiteboardWidth;
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


@end
