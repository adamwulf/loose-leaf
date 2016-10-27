//
//  Contants.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

void CGContextSaveThenRestoreForBlock(CGContextRef __nullable context, void (^block)()) {
    CGContextSaveGState(context);
    block();
    CGContextRestoreGState(context);
}

CGFloat DistanceBetweenTwoPoints(CGPoint point1, CGPoint point2) {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx * dx + dy * dy);
};

//
// useful when comparing to another squared distance
CGFloat SquaredDistanceBetweenTwoPoints(CGPoint point1, CGPoint point2) {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return dx * dx + dy * dy;
};


CGPoint NormalizePointTo(CGPoint point1, CGSize size) {
    return CGPointMake(point1.x / size.width, point1.y / size.height);
};

CGPoint DenormalizePointTo(CGPoint point1, CGSize size) {
    return CGPointMake(point1.x * size.width, point1.y * size.height);
};


CGPoint AveragePoints(CGPoint point1, CGPoint point2) {
    return CGPointMake((point1.x + point2.x) / 2, (point1.y + point2.y) / 2);
};

// interpolate between min/max with 0<=t<=1
CGFloat sqrtTransform(CGFloat min, CGFloat max, CGFloat t) {
    t = sqrt(t);
    return min + (max - min) * t;
}

CGFloat logTransform(CGFloat min, CGFloat max, CGFloat t) {
    t = logf(t + 1) / logf(2);
    return min + (max - min) * t;
}

CGFloat sqTransform(CGFloat min, CGFloat max, CGFloat t) {
    t = powf(t, 1.5);
    return min + (max - min) * t;
}
