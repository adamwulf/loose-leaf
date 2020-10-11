//
//  MMPaperRequest.h
//  LooseLeaf
//
//  Created by Yih-Chun Hu on 10/11/20.
//  Copyright © 2020 Milestone Made, LLC. All rights reserved.
//

#import "HTTPConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMPaperRequest : HTTPConnection
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
