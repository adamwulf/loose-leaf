//
//  SLModeledStackView.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/13/12.
//
//

#import "SLModeledStackView.h"

@implementation SLModeledStackView

@synthesize threadSafeSubviews;
@synthesize synchronizedOn;
@synthesize otherStacks;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:1];
        [operationQueue setName:@"SLModeledStackView Queue"];
        threadSafeSubviews = [[NSMutableArray alloc] init];
        otherStacks = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Helper

/**
 * remove an object from another stack
 * so that it exactly mirrors the UIView
 */
-(void) removeObjectFromOtherStacks:(UIView*)obj{
    for(SLModeledStackView* stack in otherStacks){
        [stack removeQuietly:obj];
    }
}

/**
 * remove without synchronization or with regard
 * to the subviews array.
 *
 * this is used to remove subviews from other stacks
 * when adding a view to this stack
 */
-(void) removeQuietly:(UIView*)obj{
    [threadSafeSubviews removeObject:obj];
}


#pragma mark - UIView

- (void)addSubview:(UIView *)view{
    [super addSubview:view];
    [operationQueue addOperationWithBlock:^{
        @synchronized(synchronizedOn ? synchronizedOn : self){
            [view retain]; // just in case our removeObject below is the last to hold it
            [self removeObjectFromOtherStacks:view];
            [threadSafeSubviews removeObject:view];
            [threadSafeSubviews addObject:view];
            [view release];
        }
    }];
}

- (void)bringSubviewToFront:(UIView *)view{
    [super bringSubviewToFront:view];
    [operationQueue addOperationWithBlock:^{
        @synchronized(synchronizedOn ? synchronizedOn : self){
            [view retain]; // just in case our removeObject below is the last to hold it
            [self removeObjectFromOtherStacks:view];
            [threadSafeSubviews removeObject:view];
            [threadSafeSubviews insertObject:view atIndex:0];
            [view release];
        }
    }];
}
- (void)sendSubviewToBack:(UIView *)view{
    [super sendSubviewToBack:view];
    [operationQueue addOperationWithBlock:^{
        @synchronized(synchronizedOn ? synchronizedOn : self){
            [view retain]; // just in case our removeObject below is the last to hold it
            [self removeObjectFromOtherStacks:view];
            [threadSafeSubviews removeObject:view];
            [threadSafeSubviews addObject:view];
            [view release];
        }
    }];
}
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
    [super insertSubview:view atIndex:index];
    [operationQueue addOperationWithBlock:^{
        @synchronized(synchronizedOn ? synchronizedOn : self){
            [view retain]; // just in case our removeObject below is the last to hold it
            [self removeObjectFromOtherStacks:view];
            [threadSafeSubviews removeObject:view];
            [threadSafeSubviews insertObject:view atIndex:index];
            [view release];
        }
    }];
}
- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview{
    [super insertSubview:view aboveSubview:siblingSubview];
    [operationQueue addOperationWithBlock:^{
        @synchronized(synchronizedOn ? synchronizedOn : self){
            [view retain]; // just in case our removeObject below is the last to hold it
            [self removeObjectFromOtherStacks:view];
            [threadSafeSubviews removeObject:view];
            NSInteger indexOfSibling = [threadSafeSubviews indexOfObject:siblingSubview];
            [threadSafeSubviews insertObject:view atIndex:indexOfSibling+1];
            [view release];
        }
    }];
}
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview{
    [super insertSubview:view belowSubview:siblingSubview];
    [operationQueue addOperationWithBlock:^{
        @synchronized(synchronizedOn ? synchronizedOn : self){
            [view retain]; // just in case our removeObject below is the last to hold it
            [self removeObjectFromOtherStacks:view];
            [threadSafeSubviews removeObject:view];
            NSInteger indexOfSibling = [threadSafeSubviews indexOfObject:siblingSubview];
            [threadSafeSubviews insertObject:view atIndex:indexOfSibling];
            [view release];
        }
    }];
}
- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2{
    [super exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
    [operationQueue addOperationWithBlock:^{
        @synchronized(synchronizedOn ? synchronizedOn : self){
            NSInteger lessIndex = index1 < index2 ? index1 : index2;
            NSInteger moreIndex =index1 < index2 ? index2 : index1;
            NSObject* obj1 = [threadSafeSubviews objectAtIndex:lessIndex];
            NSObject* obj2 = [threadSafeSubviews objectAtIndex:moreIndex];
            [obj1 retain]; [obj2 retain];
            [threadSafeSubviews removeObject:obj1];
            [threadSafeSubviews removeObject:obj2];
            [threadSafeSubviews insertObject:obj2 atIndex:lessIndex];
            [threadSafeSubviews insertObject:obj1 atIndex:moreIndex];
            [obj1 release]; [obj2 release];
        }
    }];
}



#pragma mark - SLStackView

- (SLPaperView*)popSubview{
    return [super popSubview];
}

- (void)pushSubview:(SLPaperView*)obj{
    [super pushSubview:obj];
}

- (void) addSubviewToBottomOfStack:(SLPaperView*)obj{
    [super addSubviewToBottomOfStack:obj];
}

-(void) insertPage:(SLPaperView*)pageToInsert belowPage:(SLPaperView*)referencePage{
    [super insertPage:pageToInsert belowPage:referencePage];
}

-(void) insertPage:(SLPaperView*)pageToInsert abovePage:(SLPaperView*)referencePage{
    [super insertPage:pageToInsert abovePage:referencePage];
}

@end
