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
    NSObject<MSListAddPageButtonDelegate>* __weak delegate;
}

@property (nonatomic, weak) NSObject<MSListAddPageButtonDelegate>* delegate;


@end
