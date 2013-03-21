//
//  SLImmovableTapGestureRecognizer.h
//  scratchpaper
//
//  Created by Adam Wulf on 10/19/12.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>


/**
 *
 * For notes on why this class even exists, look at the documentation
 * for SLObjectSelectLongPressGestureRecognizer. The purpose of both
 * these classes is essentially the same.
 *
 */
@interface SLImmovableTapGestureRecognizer : UITapGestureRecognizer{
    NSMutableDictionary* touchLocations;
}

@end
