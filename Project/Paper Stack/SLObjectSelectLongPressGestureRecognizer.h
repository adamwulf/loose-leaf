//
//  SLObjectSelectLongPressGestureRecognizer.h
//  scratchpaper
//
//  Created by Adam Wulf on 10/19/12.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

/**
 *
 * This class, along with SLImmovableTapGestureRecognizer, are used to select
 * objects on a page.
 *
 * The behavior that we want is for the user to either:
 * 1) select an object by long pressing on it, then being able to drag/rotate/size it etc with a pan
 * 2) select an object by tapping on it
 * 3) both 1 and 2 failing, and being able to pan/scale the page itself
 *
 * In order for 3 to happen, both 1 and 2 have to fail. But the default behavior for tap
 * and long press gestures to fail, the gesture has to:
 * 1) wait for .5 seconds to determine if the long press was long enough or not
 * 2) determine if the gesture moved more than allowableDistance
 *
 * This would be fine by default if #2 took into account the movement of each touch.
 * However, the allowableDistance is for the /gesture/ not the individual touches.
 * This means if the user does a pinch gesture, then the position of the /gesture/ is
 * the averag of the pinched touches and doesn't seem to move at all, which doesn't
 * cancel the gesture.
 *
 * When pinching, we want the gesture to immediately fail if any of the /touches/ moves
 * too much.
 *
 * this class and SLImmovableTapGestureRecognizer both add checks for the touches themselves
 * and cancel the gesture if any of the touches of the gesture move too much.
 *
 * this keeps the pan/scale of the page very fast, and allows the long press to trump
 * the page level gesture only if the touches haven't moved more than allowableDistance.
 *
 *
 */
@interface SLObjectSelectLongPressGestureRecognizer : UILongPressGestureRecognizer{
    NSMutableDictionary* touchLocations;
}

@end
