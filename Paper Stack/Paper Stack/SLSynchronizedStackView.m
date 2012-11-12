//
//  SLSynchronizedStackView.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import "SLSynchronizedStackView.h"

@implementation SLSynchronizedStackView

@synthesize synchronizedOn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - UIView

- (void)addSubview:(UIView *)view{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super addSubview:view];
    }
}

- (void)bringSubviewToFront:(UIView *)view{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super bringSubviewToFront:view];
    }
}
- (void)sendSubviewToBack:(UIView *)view{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super sendSubviewToBack:view];
    }
}
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super insertSubview:view atIndex:index];
    }
}
- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super insertSubview:view aboveSubview:siblingSubview];
    }
}
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super insertSubview:view belowSubview:siblingSubview];
    }
}
- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
    }
}



#pragma mark - SLStackView

- (SLPaperView*)popSubview{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        return [super popSubview];
    }
}

- (void)pushSubview:(SLPaperView*)obj{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super pushSubview:obj];
    }
}

- (void) addSubviewToBottomOfStack:(SLPaperView*)obj{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super addSubviewToBottomOfStack:obj];
    }
}

-(void) insertPage:(SLPaperView*)pageToInsert belowPage:(SLPaperView*)referencePage{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super insertPage:pageToInsert belowPage:referencePage];
    }
}

-(void) insertPage:(SLPaperView*)pageToInsert abovePage:(SLPaperView*)referencePage{
    @synchronized(synchronizedOn ? synchronizedOn : self){
        [super insertPage:pageToInsert abovePage:referencePage];
    }
}

@end
