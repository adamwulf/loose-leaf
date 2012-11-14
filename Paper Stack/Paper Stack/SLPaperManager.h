//
//  SLPageManager.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import <Foundation/Foundation.h>
#import "SLPaperStackView.h"

@interface SLPaperManager : NSObject{
    //
    // this is the stack of pages
    // that we need to save
    //
    // anything in the bezelStackHolder
    // (used for animation)
    // will be assumed to be hidden
    SLPaperStackView* stackView;
    CGRect idealBounds;
    
    NSOperationQueue* opQueue;
    
    // be able to look up pages
    // by UUID
    NSMutableDictionary* cacheOfPagesByUUID;

    // Debug
    NSTimer* timer;
    
    
}

@property (nonatomic, assign) SLPaperStackView* stackView;
@property (nonatomic, assign) CGRect idealBounds;

+(SLPaperManager*) sharedInstace;

-(void) load;
-(void) save;

-(SLPaperView*) createNewBlankPage;

@end
