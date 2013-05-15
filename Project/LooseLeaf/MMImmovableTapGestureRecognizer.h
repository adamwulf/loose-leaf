//
//  MMImmovableTapGestureRecognizer.h
//  Loose Leaf
//
//  Created by Adam Wulf on 10/19/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>


/**
 *
 * For notes on why this class even exists, look at the documentation
 * for MMObjectSelectLongPressGestureRecognizer. The purpose of both
 * these classes is essentially the same.
 *
 */
@interface MMImmovableTapGestureRecognizer : UITapGestureRecognizer{
    NSMutableDictionary* touchLocations;
}

@end
