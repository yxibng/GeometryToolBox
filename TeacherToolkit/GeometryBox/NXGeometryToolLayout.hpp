//
//  NXGeometryToolLayout.hpp
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/20.
//

#ifndef NXGeometryToolLayout_hpp
#define NXGeometryToolLayout_hpp

#include <cmath>

namespace NXGeometryBox {

using NXFloat = double;

//画版宽度，以此为基准进行归一化
static constexpr NXFloat WhiteboardWidth = 2000.0;
//归一化 1cm 数值
static constexpr NXFloat NormOneCm = 85.57 / WhiteboardWidth;
//绘制线宽
static constexpr NXFloat DrawLineWidth = 1.0;

//刻度上方可绘制区域
static constexpr NXFloat NormExtDrawAreaHeight = 29.34 / WhiteboardWidth;


//操作按钮边长
static constexpr NXFloat NormButtonSideLength = 48 / WhiteboardWidth;

static NXFloat degreeToRadians(NXFloat degree) {
    NXFloat pi = acos(-1);
    return pi * degree / 180.0; ;
}


struct ScaleMarkLength {
    static constexpr NXFloat normLengthForType1cm = 39.12 / WhiteboardWidth;
    static constexpr NXFloat normLengthForType5mm = 34.23 / WhiteboardWidth;
    static constexpr NXFloat normLengthForType1mm = 29.34 / WhiteboardWidth;
};

struct GeometryToolPadding {
    NXFloat normStartPadding;
    NXFloat normEndPadding;
};


struct GeometryToolBaseLengthRange {
    NXFloat normMinLength;
    NXFloat normMaxLength;
};


struct Point {
    NXFloat x;
    NXFloat y;
};



struct Size {
    NXFloat width;
    NXFloat height;
};


struct DrawStyle {
    //刻度值 字体大小
    static constexpr NXFloat normFontSize = 14.0 / WhiteboardWidth;
    //刻度线 与 刻度值之间的空隙
    static constexpr NXFloat normGapBetweenTextAndScaleMark = 4.89 / WhiteboardWidth;

    static constexpr NXFloat normPromptFontSize = 24.0 / WhiteboardWidth;
};


struct RulerLayout {
    
    //归一化高度
    static constexpr NXFloat normHeight = 183.37 / WhiteboardWidth;
    
    static constexpr NXFloat normGapBetweenCloseButtonAndPromptLabel = 16.0 / WhiteboardWidth;
    
    
    //默认归一化宽度
    static NXFloat defaultNormWidth() {
        return Padding().normStartPadding + Padding().normEndPadding + NormOneCm * 10;
    }
    
    //归一化 padding
    static GeometryToolPadding Padding() {
        static GeometryToolPadding normPadding;
        normPadding.normStartPadding = 29.34 / WhiteboardWidth;
        normPadding.normEndPadding = 29.34 / WhiteboardWidth;
        return normPadding;
    }
    
    static GeometryToolBaseLengthRange normWidthRange() {
        static GeometryToolBaseLengthRange range;
        NXFloat paddingSum = Padding().normStartPadding + Padding().normEndPadding;
        range.normMinLength = paddingSum + NormOneCm * 5;
        range.normMaxLength = paddingSum + NormOneCm * 20;
        return range;
    }
    
    
    static constexpr NXFloat normButtonLeftMargin = 40 / WhiteboardWidth;
    static constexpr NXFloat normButtonBottomMargin = 40 / WhiteboardWidth;
    
};


struct IsoscelesRightTriangleLayout {
    
    
    static constexpr NXFloat normPromptLabelMargin = 50.0 / WhiteboardWidth;
    
    //默认直角边归一化高
    static NXFloat defaultShortCatetoNormHeight() {
        return 4 * NormOneCm + paddingForCateto().normStartPadding + paddingForCateto().normEndPadding;
    }
    
    //直角边 padding
    static GeometryToolPadding paddingForCateto () {
        static GeometryToolPadding normCatetoPadding;
        normCatetoPadding.normStartPadding = 39.12 / WhiteboardWidth;
        normCatetoPadding.normEndPadding = 119.8 / WhiteboardWidth;
        return normCatetoPadding;
        
    };
    //斜边padding
    static GeometryToolPadding paddingForHipotenusa() {
        static GeometryToolPadding normHipotenusaPadding;
        normHipotenusaPadding.normStartPadding = 92.9 / WhiteboardWidth;
        normHipotenusaPadding.normEndPadding = 92.9 / WhiteboardWidth;
        return normHipotenusaPadding;
        
    }
    //归一化高度范围, 短边 3-8 cm
    static GeometryToolBaseLengthRange normHeightRange() {
        static GeometryToolBaseLengthRange range;
        NXFloat paddingSum = paddingForCateto().normStartPadding + paddingForCateto().normEndPadding;
        range.normMinLength = paddingSum + NormOneCm * 3;
        range.normMaxLength = paddingSum + NormOneCm * 8;
        return range;
    }
    
    //关闭按钮
    static Point normCloseButtonAnchorPoint() {
        static Point p;
        const NXFloat normLeftMargin = 66 / WhiteboardWidth;
        const NXFloat x = normLeftMargin + NormButtonSideLength / 2;
        const NXFloat y = x * tan(degreeToRadians(45 + 45 / 2));
        p.x = x;
        p.y = y;
        return p;
    }
    
    //放大按钮, 需要参考当前的短边长
    static Point normEnlargeButtonAnchorPoint(NXFloat normBaseSideLength) {
        
        const NXFloat normMarginToHipotenusa = 66 / WhiteboardWidth;
        //斜边中点坐标
        Point normMidPointInHipotenusa;
        normMidPointInHipotenusa.x = 0.5 * normBaseSideLength;
        normMidPointInHipotenusa.y = 0.5 * normBaseSideLength;
        
        //根据斜边中点推算放大按钮位置
        const NXFloat enlargeCenterToHipotenusa = normMarginToHipotenusa + NormButtonSideLength / 2;
        static Point p;
        p.x = normMidPointInHipotenusa.x - enlargeCenterToHipotenusa * sin(degreeToRadians(45));
        p.y = normMidPointInHipotenusa.y + enlargeCenterToHipotenusa * sin(degreeToRadians(45));
        
        return p;
    }
    
    
    //旋转按钮, 需要参考当前短边长
    static Point normRotationButtonAnchorPoint(NXFloat normBaseSideLength) {
        static Point p;
        const NXFloat normBottomMargin = 66 / WhiteboardWidth;
        const NXFloat x = normBaseSideLength - tan(degreeToRadians(45 + 45 / 2)) * (normBottomMargin + NormButtonSideLength / 2);
        const NXFloat y = normBaseSideLength - normBottomMargin - NormButtonSideLength / 2;
        p.x = x;
        p.y = y;
        return p;
    }
};


struct RightTriangleLayout {

    static constexpr NXFloat normPromptLabelMargin = 50.0 / WhiteboardWidth;

    //默认短直角边归一化高
    static NXFloat defaultShortCatetoNormHeight() {
        return 4 * NormOneCm + paddingForShortCateto().normStartPadding + paddingForShortCateto().normEndPadding;
    }
    //直角边-短边 padding
    static GeometryToolPadding paddingForShortCateto() {
        static GeometryToolPadding padding;
        padding.normStartPadding = 39.12 / WhiteboardWidth;
        padding.normEndPadding = 119.8 / WhiteboardWidth;
        return padding;
        
    }
    //直角边-长边 padding
    static GeometryToolPadding paddingForLongCateto() {
        static GeometryToolPadding padding;
        padding.normStartPadding = 39.12 / WhiteboardWidth;
        padding.normEndPadding = 193.15 / WhiteboardWidth;
        return padding;
    }
    //斜边padding
    static GeometryToolPadding paddingForHipotenusa() {
        static GeometryToolPadding padding;
        padding.normStartPadding = 92.9 / WhiteboardWidth;
        padding.normEndPadding = 180.93 / WhiteboardWidth;
        return padding;
    }
    //归一化高度范围, 短边 3-8 cm
    static GeometryToolBaseLengthRange normHeightRange() {
        static GeometryToolBaseLengthRange range;
        NXFloat paddingSum = paddingForShortCateto().normStartPadding + paddingForShortCateto().normEndPadding;
        range.normMinLength = paddingSum + NormOneCm * 3;
        range.normMaxLength = paddingSum + NormOneCm * 8;
        return range;
        
    }
    
    //关闭按钮
    static Point normCloseButtonAnchorPoint() {
        static Point p;
        const NXFloat normLeftMargin = 66 / WhiteboardWidth;
        const NXFloat x = normLeftMargin + NormButtonSideLength / 2;
        const NXFloat y = x * tan(degreeToRadians(60));
        p.x = x;
        p.y = y;
        return p;
    }
    
    //放大按钮, 参考关闭和旋转按钮
    static Point normEnlargeButtonAnchorPoint(Point closePoint, Point roationPoint) {
        static Point p;
        p.x = (closePoint.x + roationPoint.x) / 2;
        p.y = (closePoint.y + roationPoint.y) / 2;
        return p;
    }
    
    //旋转按钮, 需要参考当前短边长
    static Point normRotationButtonAnchorPoint(NXFloat normBaseSideLength) {
        static Point p;
        const NXFloat normBottomMargin = 89.24 / WhiteboardWidth;
        
        const NXFloat normWidth = normBaseSideLength * tan(degreeToRadians(60));
        const NXFloat x = normWidth - 405.87 / WhiteboardWidth - NormButtonSideLength / 2;
        const NXFloat y = normBaseSideLength - normBottomMargin - NormButtonSideLength / 2;
        p.x = x;
        p.y = y;
        return p;
    }
    
    
    
};


struct ProtractorLayout {
    
    //夹角测量器，圆圈 + 线
    struct AngleMeasurer {
        //圆圈半径
        static constexpr NXFloat normRadius = 29.34 / WhiteboardWidth;
        //连接线长度 - 外圈半径
        static constexpr NXFloat normExtRadius = (464.55 - 366.75) / WhiteboardWidth;
        
        static constexpr NXFloat normFontSize = 24 / WhiteboardWidth;
        
    };
    
    /*
     因为有夹角测量器的存在，所以要给量角器添加padding， 可以覆盖夹角测量器
     */
    static constexpr NXFloat normPaddingForAngleMeasurer = AngleMeasurer::normRadius * 2 + AngleMeasurer::normExtRadius;
    
    
    static constexpr NXFloat defaultNormRadius = 4 * NormOneCm + normPaddingForAngleMeasurer;

    static GeometryToolBaseLengthRange radiusRange() {
        static GeometryToolBaseLengthRange range;
        range.normMinLength = NormOneCm * 4 + normPaddingForAngleMeasurer;
        range.normMaxLength = NormOneCm * 7 + normPaddingForAngleMeasurer;
        return range;
    }
    

    //最内圈半径
    static constexpr NXFloat normInnerRadius = 48.90 / WhiteboardWidth;
    //中间半径,需要参考当前半径
    static NXFloat normMiddleRadius(NXFloat normBaseSideLength) {
        const NXFloat diff = 366.75-195.60;
        return normOuterRadius(normBaseSideLength) - diff / WhiteboardWidth;
    }
    //外圈半径， 不包含 padding
    static constexpr NXFloat normOuterRadius(NXFloat normBaseSideLength) {
        return normBaseSideLength - normPaddingForAngleMeasurer;
    }
    
    //90 度文字归一化大小
    static constexpr NXFloat font90NormSize = 24.0 / WhiteboardWidth;
        
    //按钮半径
    static NXFloat normButtonRadius(NXFloat normBaseSideLength) {
        NXFloat diff = NormButtonSideLength / 2 + 220.0 / WhiteboardWidth;
        return normOuterRadius(normBaseSideLength) - diff;
    }
    
    /*
     关闭按钮和旋转按钮偏移角度
     */
    static constexpr NXFloat closeAndRotationButtonDegree = 20;
};


struct CompassLayout {
    
    static Size normSizeOfHandle() {
        Size size;
        size.width = 72 / WhiteboardWidth;
        size.height = 157 / WhiteboardWidth;
        return size;
    }
    
    static Size normSizeOfFoot() {
        Size size;
        size.width = 36 / WhiteboardWidth;
        size.height = 428 / WhiteboardWidth;
        return size;
    }
    
    static Size normSizeOfPen() {
        Size size;
        size.width = 95 / WhiteboardWidth;
        size.height = 428 / WhiteboardWidth;
        return size;
    }
    
    //手柄自身锚点
    static Point handleAnchorPoint() {
        Point p;
        p.x = 0.5;
        p.y = 127 / 157.0;
        return p;
    }
    
};



};


#endif /* NXGeometryToolLayout_hpp */
