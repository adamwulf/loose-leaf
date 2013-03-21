//
//  SLListAddPageIcon.h
//  Loose Leaf
//
//  Created by Adam Wulf on 9/4/12.
//
//

#import <UIKit/UIKit.h>
#import "SLListAddPageButtonDelegate.h"

@interface SLListAddPageButton : UIView{
    NSObject<SLListAddPageButtonDelegate>* delegate;
}

@property (nonatomic, assign) NSObject<SLListAddPageButtonDelegate>* delegate;


@end
