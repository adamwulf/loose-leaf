//
//  SLSynchronizedStackView.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import "SLStackView.h"

@interface SLSynchronizedStackView : SLStackView{
    NSObject* synchronizedOn;
}

@property (nonatomic, assign) NSObject* synchronizedOn;

@end
