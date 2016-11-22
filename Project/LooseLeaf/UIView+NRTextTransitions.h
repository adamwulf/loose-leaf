//
//  UIView+NRTextTransitions.h
//  NRTextTransitionsExample
//
//  Created by Natan Rolnik on 2/26/14.
//
//

#import <UIKit/UIKit.h>

/**
 NRTextTransitions is a category in UIView that makes easier handling animated text transitions for UILabel, UITextView and UITextField. As the standard +[UIView animateWithDuration:animations:] is not able to animate non-animatable properties, and text, font and textColor properties of UILabel, UITextView and UITextField, are non-animatable, you need to use CATransition to do so with animation.
 
 NRTextTransitions uses a similar API to the standard UIView class methods, encapsulating the changes passed in the `animations` parameter block. In order to apply the transitions to the objects mentioned in this block, you **MUST** create an array, add the objects to this array, and pass it in the 'textObjects' parameter.
 */
@interface UIView (NRTextTransitions)

/**
 Executes the changes contained inside the parameter 'animations', in the given duration. In order to work, the object (UILabel, UITextView or UITextField) should be contained inside an NSArray passed in the 'textObjects' parameter. Executes the method without delay.
 
 @param textObjects An array of objects you want to apply the transition to. IMPORTANT: If you don't mention the object in this array, the changes will be applied with **NO** transition.
 @param duration The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
 @param animations A block object containing the changes to commit to the text objects. This is where you programmatically change any the properties of your objects the object (UILabel, UITextView or UITextField), as text, font, and textColor. This block takes no parameters and has no return value. IMPORTANT: In order to apply the transitions to the objects mentioned in this block, you **MUST** add them to the array passed in the 'textObjects' parameter.
 */
+ (void)animateTextTransitionForObjects:(NSArray*)textObjects withDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;

/**
 Executes the changes contained inside the parameter 'animations', in the given duration. In order to work, the object (UILabel, UITextView or UITextField) should be contained inside an NSArray passed in the 'textObjects' parameter. Executes the method without delay.
 
 @param textObjects An array of objects you want to apply the transition to. IMPORTANT: If you don't mention the object in this array, the changes will be applied with **NO** transition.
 @param duration The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
 @param animations A block object containing the changes to commit to the text objects. This is where you programmatically change any the properties of your objects the object (UILabel, UITextView or UITextField), as text, font, and textColor. This block takes no parameters and has no return value. IMPORTANT: In order to apply the transitions to the objects mentioned in this block, you **MUST** add them to the array passed in the 'textObjects' parameter.
 @param completion A block object to be executed when the animation sequence ends. This block takes no parameters and has no return value.
 */
+ (void)animateTextTransitionForObjects:(NSArray*)textObjects withDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(void))completion;

/**
 Executes the changes contained inside the parameter 'animations', in the given duration. In order to work, the object (UILabel, UITextView or UITextField) should be contained inside an NSArray passed in the 'textObjects' parameter. Executes the method without delay.
 
 @param textObjects An array of objects you want to apply the transition to. IMPORTANT: If you don't mention the object in this array, the changes will be applied with **NO** transition.
 @param duration The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
 @param delay The amount of time (measured in seconds) to wait before beginning the transitions. Specify a value of 0 to begin the animations immediately.
 @param animations A block object containing the changes to commit to the text objects. This is where you programmatically change any the properties of your objects the object (UILabel, UITextView or UITextField), as text, font, and textColor. This block takes no parameters and has no return value. IMPORTANT: In order to apply the transitions to the objects mentioned in this block, you **MUST** add them to the array passed in the 'textObjects' parameter.
 @param completion A block object to be executed when the animation sequence ends. This block takes no parameters and has no return value.
 */
+ (void)animateTextTransitionForObjects:(NSArray*)textObjects withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(void (^)(void))animations completion:(void (^)(void))completion;

@end
