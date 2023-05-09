//
//  BREmailAccount.h
//  WindfallSDK-Dev
//
//  Created by Danny Panzer on 7/16/21.
//  Copyright © 2021 Windfall. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///
typedef NS_ENUM(NSUInteger, BREReceiptProvider) {
    BREReceiptProviderNone = 0,
    BREReceiptProviderGmail,
    BREReceiptProviderOutlook,
    BREReceiptProviderYahoo,
    BREReceiptProviderAOL,
    BREReceiptProviderGmailIMAP,
    BREReceiptProviderCustomIMAP
};

/**
 * This class represents a user email account
 */
@interface BREmailAccount : NSObject

/**
 * The provider for this account
 */
@property (nonatomic, readonly) BREReceiptProvider provider;

/**
 * The email address for this account
 */
@property (strong, nonatomic, readonly) NSString *email;

@end

NS_ASSUME_NONNULL_END
