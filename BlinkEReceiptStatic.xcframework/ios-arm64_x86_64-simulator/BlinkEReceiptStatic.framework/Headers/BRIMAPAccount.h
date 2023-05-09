//
//  BRIMAPAccount.h
//  WindfallSDK-Dev
//
//  Created by Danny Panzer on 7/16/21.
//  Copyright © 2021 Windfall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BREmailAccount.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents an IMAP account that should be instantiated with the user's credentials prior to beginning IMAP setup in `BREReceiptManager`
 */
@interface BRIMAPAccount : BREmailAccount

/**
*  The first step in linking a user's IMAP account is instantiating this class with the user's credentials.
*
*  @param provider  The provider for this IMAP account
*  @param email   The email address for this IMAP account
*  @param password  The password for this IMAP account (Note: this is the user's regular password - an "app password" will be created automatically during setup
*/
- (instancetype)initWithProvider:(BREReceiptProvider)provider
                           email:(NSString*)email
                        password:(NSString*)password;

/**
*  If the IMAP provider is not Gmail, AOL, or Yahoo, use this method to specify the provider's configuration
*
*  @param host  The provider's IMAP host name
*  @param port   The provider's IMAP port
*  @param useTLS  Whether the provider uses TLS (virtually all providers do)
*/
- (void)configureCustomHost:(NSString*)host
                       port:(NSInteger)port
                     useTLS:(BOOL)useTLS;


@end

NS_ASSUME_NONNULL_END
