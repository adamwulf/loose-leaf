//
//  SLModeledStackView.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/13/12.
//
//

#import "SLStackView.h"

/**
 * the purpose of this class is to maintain a separate
 * NSMutableArray of the subviews that is managed entirely
 * on a background thread.
 *
 * this allows the view to be used also as a model
 * and not be restricted to use on the main thread
 */
@interface SLModeledStackView : SLStackView{
    NSObject* synchronizedOn;
    NSMutableArray* threadSafeSubviews;
    NSOperationQueue* operationQueue;
    
    NSString* name;
    
    // we need to know what other stacks may exist
    // so that we can remove a view from its
    // threadSafeSubviews to add it to our own
    NSMutableArray* otherStacks;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) NSObject* synchronizedOn;
@property (nonatomic, readonly) NSArray* threadSafeSubviews;
@property (nonatomic, readonly) NSMutableArray* otherStacks;

@end
