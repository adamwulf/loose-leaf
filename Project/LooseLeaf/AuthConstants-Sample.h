//
//  AuthConstants.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/10/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//
//
// Copy this file to Project/LooseLeaf/AuthConstants.h and update to use your own API keys.
//

#ifndef LooseLeaf_AuthConstants_h
#define LooseLeaf_AuthConstants_h

#define FACEBOOK_APP_ID @"YOUR_FACEBOOK_APP_ID"
#define PINTEREST_APP_ID @"YOUR_PINTEREST_APP_ID"

#ifdef DEBUG
#define MIXPANEL_TOKEN @"YOUR_DEBUG_MIXPANEL_TOKEN"
#else
#define MIXPANEL_TOKEN @"YOUR_PROD_MIXPANEL_TOKEN"
#endif

// Imgur
#define kImgurClientID @"YOUR_IMGUR_CLIENT_ID"
#define kImgurClientSecret @"YOUR_IMGUR_CLIENT_SECRET"
#define kMashapeClientID @"YOUR_MASHAPE_CLIENT_ID"

#endif
