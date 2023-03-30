//
//  NXIsoscelesRightTriangleView.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/14.
//

#import "NXIsoscelesRightTriangleView.h"
#import "NXGeometryToolLayout.hpp"
#import "NXGeometryToolBoxHelper.h"
#import "NXPromptHelper.h"

@interface NXIsoscelesRightTriangleView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *enlargeButton;
@property (nonatomic, strong) UIButton *rotationButton;

@property (nonatomic, strong) UIGestureRecognizer *moveGesture;

@property (nonatomic, assign) NXGeometryToolType geometryToolType;

@property (nonatomic, strong) UIPanGestureRecognizer *leftDrawLineGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *bottomDrawLineGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *hypotenuseDrawLineGesture;


//show rotation angle or draw length
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) NXPromptHelper *promptHelper;

@end


@implementation NXIsoscelesRightTriangleView

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
    
    self.layer.anchorPoint = CGPointMake(0, 1);
    self.backgroundColor = UIColor.clearColor;
    self.userInteractionEnabled = _userActionAllowed = NO;
    
    _geometryToolType = NXGeometryToolTypeIsoscelesRightTriangle;
    _rotationAngle = 0;
    
    _normBaseSideLength = NXGeometryBox::IsoscelesRightTriangleLayout::defaultShortCatetoNormHeight();
    _baseLengthRange = (NXGeometryToolBaseLengthRange) {
        .normMinLength = NXGeometryBox::IsoscelesRightTriangleLayout::normHeightRange().normMinLength,
        .normMaxLength = NXGeometryBox::IsoscelesRightTriangleLayout::normHeightRange().normMaxLength
    };
    
    //move gesture
    {
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onMovePanGestureChanged:)];
        moveGesture.delegate = self;
        [self addGestureRecognizer:moveGesture];
        _moveGesture = moveGesture;
    }

    //draw line gestures
    {
        UIPanGestureRecognizer *(^createDrawLineGesture)() = ^{
            UIPanGestureRecognizer *drawLineGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onDrawLinePanGestureChanged:)];
            drawLineGesture.delegate = self;
            return drawLineGesture;
        };
        
        _leftDrawLineGesture = createDrawLineGesture();
        [self addGestureRecognizer:_leftDrawLineGesture];
        
        _bottomDrawLineGesture = createDrawLineGesture();
        [self addGestureRecognizer:_bottomDrawLineGesture];
        
        _hypotenuseDrawLineGesture = createDrawLineGesture();
        [self addGestureRecognizer:_hypotenuseDrawLineGesture];
    }
}

- (void)_recalculate {
    
    CGFloat x = _whiteboardWidth * self.normPosition.x;
    CGFloat y = _whiteboardWidth * self.normPosition.y;
    self.layer.bounds = CGRectMake(0, 0, _whiteboardWidth * _normBaseSideLength, _whiteboardWidth * _normBaseSideLength);
    self.layer.position = CGPointMake(x, y);
    self.layer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, _rotationAngle);
}

- (void)_redraw {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    NSArray<CALayer *> *layers = [self.layer.sublayers copy];
    for (CALayer *layer in layers) {
        if ([layer isKindOfClass:CATextLayer.class]) {
            [layer removeFromSuperlayer];
        }
    }
    const CGFloat whiteboardWidth = _whiteboardWidth;
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
    
    //直角边 padding
    auto padding = NXGeometryBox::IsoscelesRightTriangleLayout::paddingForCateto();
    const float startPadding = padding.normStartPadding * whiteboardWidth;
    const float endPadding = padding.normEndPadding * whiteboardWidth;
    // Drawing left
    {
        {
            //考虑线宽
            CGContextMoveToPoint(context, NXGeometryBox::DrawLineWidth / 2, 0);
            CGContextAddLineToPoint(context, NXGeometryBox::DrawLineWidth  / 2, rect.size.height);
        }

        int num = ceil(rect.size.height - startPadding - endPadding) / mmWidth;
        CGPoint start, end;
        for (int i = 0; i <= num; i++) {
            //画刻度, 从下往上画
            start.x = 0;
            start.y = end.y = rect.size.height -  (mmWidth * i + startPadding);
            float scaleMarkLength = whiteboardWidth * [self _normScaleMarkLengthWithIndex:i];
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
        {
            //考虑线宽
            CGContextMoveToPoint(context, 0, rect.size.height - NXGeometryBox::DrawLineWidth / 2);
            CGContextAddLineToPoint(context, rect.size.width, rect.size.height - NXGeometryBox::DrawLineWidth / 2);
        }
        int num = ceil(rect.size.height - startPadding - endPadding) / mmWidth;
        CGPoint start, end;
        for (int i = 0; i <= num; i++) {
            //画刻度, 从左往右画
            start.x = end.x = mmWidth *i + startPadding;
            start.y = rect.size.height;
            
            float scaleMarkLength = whiteboardWidth * [self _normScaleMarkLengthWithIndex:i];
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
                    CGFloat width = CGRectGetWidth(layer.bounds);
                    CGFloat height = CGRectGetHeight(layer.bounds);
                    CGFloat gap = whiteboardWidth * NXGeometryBox::DrawStyle::normGapBetweenTextAndScaleMark;
                    layer.frame = CGRectMake(end.x - width / 2, end.y - height - gap, width, height);
                    [self.layer addSublayer:layer];
                }
            }
        }
    }
    
    // Drawing hypotenuse
    {
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
        
        
        auto padding = NXGeometryBox::IsoscelesRightTriangleLayout::paddingForHipotenusa();
        const float startPadding = padding.normStartPadding * whiteboardWidth;
        const float endPadding = padding.normEndPadding * whiteboardWidth;
        
        CGFloat length = sqrt(pow(rect.size.width, 2.0) + pow(rect.size.height, 2.0));
        int num = (length - startPadding - endPadding) / mmWidth;
        CGPoint start, end;
        for (int i = 0; i <= num; i++) {
            //画刻度, 从左往右画
            start.x = start.y = (mmWidth * i + startPadding) * sin(M_PI_4);
            float scaleMarkLength = whiteboardWidth * [self _normScaleMarkLengthWithIndex:i];
            end.x = start.x - scaleMarkLength * sinf(M_PI_4);
            end.y = start.y + scaleMarkLength * sinf(M_PI_4);
            
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
                
                CGFloat layerCenterX = end.x - (gap + height / 2) * sin(M_PI_4);
                CGFloat layerCenterY = end.y + (gap + height / 2) * sin(M_PI_4);
                
                layer.frame = CGRectMake(layerCenterX - width / 2 , layerCenterY - height / 2, width, height);
                [self.layer addSublayer:layer];
                //这里必须在添加以后，仿射变换才生效 ？？？
                layer.affineTransform = CGAffineTransformMakeRotation(M_PI_4);
                
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
    
    auto normAnchorPoint = NXGeometryBox::IsoscelesRightTriangleLayout::normCloseButtonAnchorPoint();
    self.closeButton.layer.position = CGPointMake(whiteboardWidth * normAnchorPoint.x, whiteboardWidth * normAnchorPoint.y);
    
    normAnchorPoint = NXGeometryBox::IsoscelesRightTriangleLayout::normEnlargeButtonAnchorPoint(self.normBaseSideLength);
    self.enlargeButton.layer.position = CGPointMake(whiteboardWidth * normAnchorPoint.x, whiteboardWidth * normAnchorPoint.y);

    normAnchorPoint = NXGeometryBox::IsoscelesRightTriangleLayout::normRotationButtonAnchorPoint(self.normBaseSideLength);
    self.rotationButton.layer.position = CGPointMake(whiteboardWidth * normAnchorPoint.x, whiteboardWidth * normAnchorPoint.y);
    
    
    //prompt label
    {
        //promptLabel
        const CGFloat fontSize = self.whiteboardWidth * NXGeometryBox::DrawStyle::normPromptFontSize;
        UIFont *font = [UIFont systemFontOfSize:fontSize];
        self.promptLabel.font = font;
        CGRect rect = [NXGeometryToolBoxHelper textRectWithString:self.promptLabel.text font:font];
        self.promptLabel.bounds = rect;
        
        const CGFloat margin = NXGeometryBox::IsoscelesRightTriangleLayout::normPromptLabelMargin * self.whiteboardWidth;
        const CGFloat x = margin + rect.size.width / 2;
        const CGFloat y = self.bounds.size.height - (margin + rect.size.height /2);
        self.promptLabel.layer.position = CGPointMake(x, y);
    }
}


- (CGFloat)_normScaleMarkLengthWithIndex:(int)index {
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


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    const CGFloat whiteboardWidth = self.whiteboardWidth;
    CGFloat extDrawAreaHeight = NXGeometryBox::NormExtDrawAreaHeight * whiteboardWidth;
    
    const CGFloat width = self.bounds.size.width;
    const CGFloat height = self.bounds.size.height;
    
    //left ext rect
    CGRect leftRect = CGRectMake(-extDrawAreaHeight, 0, extDrawAreaHeight, height);
    if (CGRectContainsPoint(leftRect, point)) {
        return YES;
    }
    
    //hypotenuse ext rect
    {
        const CGFloat hypotenuseWidth = sqrt(width *width + height * height);
        const CGRect rect = CGRectMake(0, 0, hypotenuseWidth, extDrawAreaHeight);
        /*
         使用坐标变换
         原始坐标： 逆时针旋转45度， 之后再y轴 正方向平移 extDrawAreaHeight
         */
        CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-45));
        transform = CGAffineTransformTranslate(transform, 0, extDrawAreaHeight);
        
        CGPoint transformPoint = CGPointApplyAffineTransform(point, transform);
        if (CGRectContainsPoint(rect, transformPoint)) {
            return YES;
        }
    }
    
    //bottom ext rect
    CGRect bottomRect = CGRectMake(0, height, width, extDrawAreaHeight);
    if (CGRectContainsPoint(bottomRect, point)) {
        return YES;
    }
    
    //inner triangle
    if (point.y >= point.x) {
        return YES;
    }

    return NO;
}


#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    const CGFloat whiteboardWidth = _whiteboardWidth;
    const CGFloat extDrawAreaHeight = whiteboardWidth * NXGeometryBox::NormExtDrawAreaHeight;
    const CGFloat insideDrawAreaHeight = whiteboardWidth * NXGeometryBox::ScaleMarkLength::normLengthForType1mm;
    const CGFloat width = self.bounds.size.width;
    const CGFloat height = self.bounds.size.height;
    
    CGPoint location = [touch locationInView:self];
    if (gestureRecognizer == self.leftDrawLineGesture) {
        
        CGRect extRect = CGRectMake(-extDrawAreaHeight, 0, extDrawAreaHeight, height);
        if (CGRectContainsPoint(extRect, location)) {
            return YES;
        }
        
        CGFloat startOffsetY = insideDrawAreaHeight * tan(DEGREES_TO_RADIANS(67.5));
        CGFloat endOffsetY = insideDrawAreaHeight;
        CGFloat insideRectHeight = height - startOffsetY - endOffsetY;
        CGRect insideRect = CGRectMake(0, startOffsetY, insideDrawAreaHeight, insideRectHeight);
        if (CGRectContainsPoint(insideRect, location)) {
            return YES;
        }
    }
    
        
    if (gestureRecognizer == self.bottomDrawLineGesture) {
        
        CGRect extRect = CGRectMake(0, height, width, extDrawAreaHeight);
        if (CGRectContainsPoint(extRect, location)) {
            return YES;
        }
        
        CGFloat startOffsetX = insideDrawAreaHeight;
        CGFloat endOffsetX = insideDrawAreaHeight * tan(DEGREES_TO_RADIANS(67.5));
        CGFloat insideRectWidth = width - startOffsetX - endOffsetX;
        CGRect insideRect = CGRectMake(startOffsetX, height - insideDrawAreaHeight, insideRectWidth, insideDrawAreaHeight);
        if (CGRectContainsPoint(insideRect, location)) {
            return YES;
        }
    }
    
    
    if (gestureRecognizer == self.hypotenuseDrawLineGesture) {
        
        const CGFloat sideLength = sqrt(width * width + height * height);
        CGRect extRect = CGRectMake(0, 0, sideLength, extDrawAreaHeight);
        
        /*
         使用坐标变换
         原始坐标： 逆时针旋转45度， 之后再y轴 正方向平移 extDrawAreaHeight
         */
        {
            CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-45));
            transform = CGAffineTransformTranslate(transform, 0, extDrawAreaHeight);
            CGPoint transformPoint = CGPointApplyAffineTransform(location, transform);
            if (CGRectContainsPoint(extRect, transformPoint)) {
                return YES;
            }

        }
        
        {
            CGFloat startOffsetX = insideDrawAreaHeight * tan(DEGREES_TO_RADIANS(67.5));
            CGFloat endOffsetX = startOffsetX;
            CGFloat width = sideLength - startOffsetX - endOffsetX;
            CGRect insideRect = CGRectMake(0, 0, width, insideDrawAreaHeight);
            CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-45));
            transform = CGAffineTransformTranslate(transform, -startOffsetX, 0);
            CGPoint transformPoint = CGPointApplyAffineTransform(location, transform);
            if (CGRectContainsPoint(insideRect, transformPoint)) {
                return YES;
            }
        }
    }
    
    if (gestureRecognizer == self.moveGesture) {
        return YES;
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
    
    [self.promptHelper syncMoved];
}

- (void)setNormBaseSideLength:(CGFloat)normBaseSideLength {
    if (_normBaseSideLength == normBaseSideLength) {
        return;
    }
    if (normBaseSideLength >= _baseLengthRange.normMinLength && normBaseSideLength <= _baseLengthRange.normMaxLength) {
        _normBaseSideLength = normBaseSideLength;
        [self _recalculate];
        [self _redraw];
        [self.promptHelper SyncEnlarged];
    }
}

- (void)setRotationAngle:(CGFloat)rotationAngle {
    if (_rotationAngle == rotationAngle) {
        return;
    }
    _rotationAngle = rotationAngle;
    [self _recalculate];
    [self _redraw];
    
    [self.promptHelper syncRotationAngle:rotationAngle];
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
        _enlargeButton.layer.affineTransform = CGAffineTransformMakeRotation(-M_PI_4);
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

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.textColor = NXGeometryToolDrawStyle.promptTextColor;
        [self addSubview:_promptLabel];
        _promptLabel.backgroundColor = UIColor.clearColor;
    }
    return _promptLabel;
}

- (NXPromptHelper *)promptHelper {
    
    if (!_promptHelper) {
        _promptHelper = [[NXPromptHelper alloc] initWithGeometryTool:self promptLabel:self.promptLabel];
    }
    return _promptHelper;
    
}



#pragma mark -

- (void)_onClickCloseButton:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(geometryToolOnCloseButtonClicked:)]) {
        [self.delegate geometryToolOnCloseButtonClicked:self];
    }
}

- (void)_onEnlargePanGestureChanged:(UIPanGestureRecognizer *)panGesture {
    NSAssert(_whiteboardWidth > 0, @"_onEnlargePanGestureChanged, whiteboardWidth can not be zero!");
    CGPoint translation = [panGesture translationInView:self];
    CGFloat ratio = translation.x / _whiteboardWidth;
    [panGesture setTranslation:CGPointZero inView:self];
    CGFloat newWidth = _normBaseSideLength + ratio;
    if (newWidth >= _baseLengthRange.normMinLength && newWidth <= _baseLengthRange.normMaxLength) {
        _normBaseSideLength = newWidth;
        [self _recalculate];
        [self _redraw];
        //notify base side length change
        if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onNormBaseSideLengthChanged:)]) {
            [self.delegate geometryTool:self onNormBaseSideLengthChanged:_normBaseSideLength];
        }
        
        [self.promptHelper enlarged];
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
            
            //notify rotation angle changed
            if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onRotationAngleChanged:)]) {
                [self.delegate geometryTool:self onRotationAngleChanged:_rotationAngle];
            }
            
            [self.promptHelper rotationAngleChanged:_rotationAngle];
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
    //notify norm position changed
    if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onNormPositionChanged:)]) {
        [self.delegate geometryTool:self onNormPositionChanged:_normPosition];
    }
    [self.promptHelper moved];
}


- (void)_onDrawLinePanGestureChanged:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint location = [panGesture locationInView:self];
    if (panGesture == self.leftDrawLineGesture) {
        location.x = 0;
        location.x -= self.drawLineWidth / 2;
    } else if (panGesture == self.bottomDrawLineGesture) {
        location.y = self.bounds.size.height + self.drawLineWidth /2;
    } else if (panGesture == self.hypotenuseDrawLineGesture) {
        //参考： https://blog.csdn.net/guyuealian/article/details/53954005
        const CGPoint p0 = CGPointMake(0, -self.drawLineWidth/2/sin(M_PI_4));
        const CGPoint p1 = CGPointMake(self.drawLineWidth/2/sin(M_PI_4), 0);
        //计算直线
        const CGFloat k = (p0.y - p1.y) / (p0.x - p1.x);
        const CGFloat b = p1.y - k * p1.x;
        //计算投影点
        CGFloat x = (k * (location.y - b) + location.x) / (k * k + 1);
        CGFloat y = k * x + b;
        location.x = x;
        location.y = y;
    } else {
        NSAssert(NO, @"not support yet !!!");
    }
    
    CGPoint locationInSuperview = [self convertPoint:location toView:self.superview];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onDrawLineBeganAtPoint:)]) {
                [self.delegate geometryTool:self onDrawLineBeganAtPoint:locationInSuperview];
            }
            [self.promptHelper drawLineBeganAtPoint:location];
            break;
        case UIGestureRecognizerStateChanged:
            if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onDrawLineMovedToPoint:)]) {
                [self.delegate geometryTool:self onDrawLineMovedToPoint:locationInSuperview];
            }
            [self.promptHelper drawLineMovedToPoint:location];
            break;
        case UIGestureRecognizerStateEnded:
            if (self.delegate && [self.delegate respondsToSelector:@selector(geometryTool:onDrawLineEndedAtPoint:)]) {
                [self.delegate geometryTool:self onDrawLineEndedAtPoint:locationInSuperview];
            }
            [self.promptHelper drawLlineEndedAtPoint:location];
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.delegate && [self.delegate respondsToSelector:@selector(geometryToolOnDrawLineCanceled:)]) {
                [self.delegate geometryToolOnDrawLineCanceled:self];
            }
            break;
        default:
            break;
    }
}

@end
