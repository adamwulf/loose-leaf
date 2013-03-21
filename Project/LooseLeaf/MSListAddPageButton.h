//
//  SLListAddPageIcon.h
//  Loose Leaf
//
//  Created by Adam Wulf on 9/4/12.
//
//

#import <UIKit/UIKit.h>
#import "MSListAddPageButtonDelegate.h"

@interface MSListAddPageButton : UIView{
    NSObject<MSListAddPageButtonDelegate>* delegate;
}

@property (nonatomic, assign) NSObject<MSListAddPageButtonDelegate>* delegate;


@end
