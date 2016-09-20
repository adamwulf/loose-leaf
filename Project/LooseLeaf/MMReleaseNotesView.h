//
//  MMReleaseNotesView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMRoundedSquareView.h"

@interface MMReleaseNotesView : MMRoundedSquareView

-(instancetype) initWithFrame:(CGRect)frame NS_UNAVAILABLE;

-(instancetype) initWithFrame:(CGRect)frame andReleaseNotes:(NSString*)htmlReleaseNotes;

@end
