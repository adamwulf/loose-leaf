//
//  DGTAuthenticationConfiguration.h
//  
//  Copyright (c) 2015 Twitter. All rights reserved.
//

@class DGTAppearance;

/**
 *  Controls several of the features for authentication flow.
 *
 */

typedef NS_OPTIONS(NSInteger, DGTAccountFields) {
    DGTAccountFieldsNone = 1 << 0,
    DGTAccountFieldsEmail = 1 << 1,
    DGTAccountFieldsDefaultOptionMask = DGTAccountFieldsNone
};

@interface DGTAuthenticationConfiguration : NSObject <NSCopying>

// Appearance of the authentication flow views.
@property (nonatomic, strong) DGTAppearance *appearance;

// Prepopulate the phone number field with this value.
// Value should be a string containing only numbers, and prefixed with an optional '+' character if the number includes a country dial code.
// If a '+' is provided, the country dial code will be parsed out and selected from the country picker.
// You could also pass only the country code using the '+' prefix and only the country picker will be populated, no phone number.
// Examples: '+15555555555' (USA, 5555555555), '5555555555' (USA, 5555555555), '+345555555555' (Spain, 5555555555), '+52' (Mexico, no number input)
@property (nonatomic, strong) NSString *phoneNumber;

// Title for the modal screens. Will default to the name of your app.
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithAccountFields:(DGTAccountFields)accountFields;

- (instancetype)init __unavailable;

@end
