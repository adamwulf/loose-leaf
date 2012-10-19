//
//  SLObjectSelectLongPressGestureRecognizer.h
//  scratchpaper
//
//  Created by Adam Wulf on 10/19/12.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SLObjectSelectLongPressGestureRecognizer : UILongPressGestureRecognizer{
    NSMutableDictionary* touchLocations;
}

@end
