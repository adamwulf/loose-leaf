//
//  MMShakeScrapGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/30/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMShakeScrapGestureRecognizer.h"

@implementation MMShakeScrapGestureRecognizer

//
// I think my goal will be to set the panScrap gestures
// as the delegates of this gesture. Then, this gesture
// will look for any touch movement.
//
// when it finds them, it'll look to see if the scrap
// gestures are active, and ask what touches they're using
// for their scrap.
//
// it'll then track only those valid touches per panScrap
// gesture for shakes, and will only trigger recognized
// when a shake is found.
//
// i'll probably have to keep the gesture alive during the touch
// otherwise it'll only find 1 shake at most for any given
// scrap. I could track the shakes by sending them through
// a delegate method instead of the state, or by
// tracking shake counts per scrap.

@end
