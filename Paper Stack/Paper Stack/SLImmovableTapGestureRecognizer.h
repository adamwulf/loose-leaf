//
//  SLImmovableTapGestureRecognizer.h
//  scratchpaper
//
//  Created by Adam Wulf on 10/19/12.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SLImmovableTapGestureRecognizer : UITapGestureRecognizer{
    NSMutableDictionary* touchLocations;
}

@end
