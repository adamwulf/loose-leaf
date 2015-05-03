//
//  JotView+Cregle.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "JotView+Cregle.h"
#import <CRAccessoryKit/CRAccessoryKit.h>

@implementation JotView (Cregle)

-(UILabel*) label{
    UIWindow* w = [[UIApplication sharedApplication] keyWindow];
    for(UIView* v in w.subviews){
        if([v isKindOfClass:[UILabel class]] && v.tag == 10){
            return (UILabel*)v;
        }
    }
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    l.tag = 10;
    [w addSubview:l];
    return l;
}

- (void)stylus:(CRAccessory*)accessory didStartDrawing:(CRDrawing*)drawing{
    [self label].text = @"did start drawing";
}



- (void)stylus:(CRAccessory*)accessory continuesDrawing:(CRDrawing*)drawing{
    [self label].text = @"did continue drawing";
}



- (void)stylus:(CRAccessory*)accessory didEndDrawing:(CRDrawing*)drawing{
    [self label].text = @"did end drawing";
}


@end
