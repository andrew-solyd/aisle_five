//
//  BREReceiptManager.h
//  WindfallSDK-Dev
//
//  Created by Danny Panzer on 5/4/18.
//  Copyright © 2018 Windfall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <BlinkReceiptStatic/BRScanResults.h>
#import "BREmailAccount.h"
#import "BRIMAPAccount.h"

///
typedef NS_ENUM(NSUInteger, BREReceiptIMAPError) {
    BREReceiptIMAPErrorInvalidCredentials = 5,
    BREReceiptIMAPErrorGmailIMAPDisabled = 6,
    BREReceiptIMAPErrorGmailTwoFactor = 40
};

///
typedef NS_ENUM(NSUInteger, BRSetupIMAPResult) {
    BRSetupIMAPResultUserCancelled = 0,
    BRSetupIMAPResultBadEmail,
    BRSetupIMAPResultBadPassword,
    BRSetupIMAPResultEnabledLSA,
    BRSetupIMAPResultRedirectToSafari,
    BRSetupIMAPResultCreatedAppPassword,
    BRSetupIMAPResultAdminNeeded,
    BRSetupIMAPResultDuplicateEmail,
    BRSetupIMAPResultSaved,
    BRSetupIMAPResultUnknownFailure
};

///
typedef NS_ENUM(NSUInteger, BREReceiptRemoteError) {
    
    BREReceiptRemoteErrorNone                   = 0,
    
    /// Remote scrape was attempted but no providers have been linked
    BREReceiptRemoteErrorNoProvider             = 1,

    /// Remote scrape was attempted with a provider that is not supported
    BREReceiptRemoteErrorInvalidProvider        = 2,

    /// Remote scrape was attempted but no valid credentials were found on disk for the specified provider
    BREReceiptRemoteErrorNoCredentials          = 3,

    /// Remote scrape was attempted for an OAuth provider but a new access token could not be obtained
    BREReceiptRemoteErrorCantObtainToken        = 4,

    /// The supplied credentials failed to authenticate againt the specified provider server side
    BREReceiptRemoteErrorInvalidCredentials     = 5,

    /// For OAuth providers this indicates the access token has expired
    BREReceiptRemoteErrorExpiredToken           = 6,

    /// No client configuration for the remote scrape service was found server side
    BREReceiptRemoteErrorNoClientConfig         = 7,

    /// Remote scrape worker could not locate all required parameters to initiate scrape (Unexpected)
    BREReceiptRemoteErrorBadInput               = 8,

    /// Remote scrape worker timed out trying to connect to email provider
    BREReceiptRemoteErrorTimeout                = 9,

    /// Remote scrape worker connected to IMAP account but found no mailboxes (Unexpected)
    BREReceiptRemoteErrorIMAPNoBoxes            = 10,

    /// Indicates that one or more receipt IDs passed in to a reprocessing job was invalid (will not be returned client side)
    BREReceiptRemoteErrorInvalidReceiptIDs      = 11,

    /// Indicates failure to connect to the results endpoint configured server side (will not be returned client side) 
    BREReceiptRemoteErrorClientEndpointErrors   = 12,
    
    /// Could not queue up a remote scrape job because there is already one queued or in progress for this email address
    BREReceiptRemoteErrorJobInProgress          = 13,
    
    /// Could not connect to or authenticate with the IMAP server
    BREReceiptRemoteErrorIMAPFailedConnection   = 16,

    /// An unknown error was encountered attempting to queue up the remote scrape job
    BREReceiptRemoteErrorUnknown                = 999
};

/**
 *  This class is the interface to manage e-receipt parsing
 */
@interface BREReceiptManager : NSObject

///------------------
/// @name Properties
///------------------

/**
 *  In order to authenticate Gmail accounts, you must enable the Gmail API in your Google API Console and obtain a Client ID for your app's bundle.
 *  When you have done so, input the Client ID here before attempting to begin the OAuth process for Gmail
 */
@property (nonatomic, strong) NSString *googleClientId;

/**
 *  In order to authenticate Outlook accounts, you must register your app at the Azure Portal (https://portal.azure.com/) and add a new App Registration. This will generate an Application (client) ID
 *  When you have done so, input that id here before attempting to begin the OAuth process for Outlook
 */
@property (nonatomic, strong) NSString *outlookClientId;

/**
 *  Whether there is a stored provider
 */
@property (nonatomic) BOOL userHasProvider;

/**
 *  How far back (in days) to search the user's inbox for e-receipts
 *
 *  Default: 14
 */
@property (nonatomic) NSInteger dayCutoff;

/**
 *  This property is an alternative to `dayCutoff` which allows you to set a specific date/time that serves as the boundary of how far back to search.
 *  If set, it will override `dayCutoff`
 *
 *  Default: nil
 */
@property (strong, nonatomic) NSDate *dateCutoff;

/**
 *  This property works in tandem with `dateCutoff` and allows you to set the later boundary (i.e. until when) for the search period
 *
 *  Default: nil
 */
@property (strong, nonatomic) NSDate *searchUntilDate;

/**
 *  If populated, the keys in this dictionary will be used as the senders to search the user's inbox for, and the corresponding values will be used as the merchant sender address for parsing purposes
 *  Default: nil
 */
@property (strong, nonatomic) NSDictionary<NSString*, NSString*> *senderWhitelist;

/**
 *  Controls whether or not to aggregate all emails relating to a given e-receipt order (such as shipping status updates) in the results structure
 *  Default: NO
*/
@property (nonatomic) BOOL aggregateResults;

/**
 * If set, overrides the client endpoint configured server side to which results will be POSTed following a remote scrape
 * Default: nil
 */
@property (strong, nonatomic) NSString *remoteScrapeClientEndpoint;

/**
 * If set, overrides the default date cutoff for the current user in remote scrapes
 * Default: nil
 */
@property (strong, nonatomic) NSDate *remoteScrapeUserDateCutoff;

/**
 * If the e-receipts being scraped are known to be from a specific country, set this property to the ISO 2 character country code to improve parsing
 * Deafult: nil
 */
@property (strong, nonatomic) NSString *countryCode;

///---------------------
/// @name Class Methods
///---------------------

+ (instancetype)shared;

///---------------
/// @name Methods
///---------------

/**
 * Retrieves all the currently linked accounts
 */
- (NSArray<BREmailAccount*>*)getLinkedAccounts;

/**
 *  Begins the OAuth process for the given provider (currently only Gmail and Outlook supported). If the completion is called with no error, you may then invoke `-[BREReceiptManager getEReceiptsWithCompletion:]`
 *
 *  @param provider         The provider you would like to authenticate against
 *  @param viewController   The view controller from which to present the OAuth modal
 *  @param completion       The completion is invoked after the OAuth attempt has completed
 *
 *      * `NSError *error` - The error returned during the OAuth attempt, if any. A successful attempt will return `nil`
 */
- (void)beginOAuthForProvider:(BREReceiptProvider)provider
           withViewController:(UIViewController*)viewController
                andCompletion:(void(^)(NSError *error))completion;

/**
*  To connect to Gmail, Yahoo, or AOL accounts via IMAP, the user will have to enable certain account settings. Call this function to start the process
*
*  @param account  Instantiate an instance of `BRIMAPAccount` and optionally set custom values for host, port, and TLS
*  @param viewController   The view controller from which to present the controller that manages the account settings
*  @param completion       The completion is invoked after the attempt to configure the account has finished
*
*      * `BRSetupIMAPResult result` - The result of the attempt to configure the account. A successful result is `BRSetupIMAPResultEnabledLSA` or `BRSetupIMAPResultCreatedAppPassword`
*/
- (void)setupIMAPForAccount:(BRIMAPAccount*)account
             viewController:(UIViewController*)viewController
             withCompletion:(void(^)(BRSetupIMAPResult result))completion;

/**
 * If users have already generated an App Password for a Gmail / Yahoo / AOL IMAP account, use this method to link the account
 *
 * @param account   Instantiate an instance of `BRIMAPAccount`, setting the App Password as the `password` property
 * @param completion       The completion is invoked after the attempt to configure the account has finished
 *
 *      * `BRSetupIMAPResult result` - The result of the attempt to configure the account. A successful result is `BRSetupIMAPResultSaved`

 */
- (void)linkIMAPAccountWithoutSetup:(BRIMAPAccount*)account
                     withCompletion:(void(^)(BRSetupIMAPResult result))completion;

/**
 *  Verifies that stored IMAP credentials are valid
 *
 *  @param account The account you would like to verify (must be one of the members of `getLinkedAccount`
 *  @param completion   The completion is invoked after the attempt to verify IMAP credentials completes
 *
 *      * `BOOL success` - indicates whether verification succeeded or not
 *      * `NSError *error` - `nil` on success, otherwise contains error information
 */
- (void)verifyImapAccount:(BRIMAPAccount*)account
           withCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Attempts to retrieve new (since last check) e-receipts from all linked e-mail accounts. You must have successfully authenticated an OAuth provider, or stored IMAP credentials (and setup IMAP if necessary) prior to calling this method
 *  @note You must have a valid license key set in `[BRScanManager sharedManager].licenseKey` as well as a valid prod intel key set in `[BRScanManager sharedManager].prodIntelKey` in order to receive any results
 *
 *  @param completion   The completion function will be invoked when e-receipt parsing has completed.
 *
 *      * `NSArray<BRScanResults*> *receipts` - an array of `BRScanResults` objects corresponding to the e-receipts that were successfully parsed. You can expect the following order-level properties to be populated:
 *
 *          * `BRScanResults.total`
 *          * `BRScanResults.receiptDate`
 *          * `BRScanResults.ereceiptOrderNumber`
 *
 *          For products in an e-receipt, you can expect the following properties to be populated:
 *
 *          * `BRProduct.productNumber`
 *          * `BRProduct.productDescription`
 *          * `BRProduct.unitPrice`
 *          * `BRProduct.totalPrice`
 *          * `BRProduct.quantity`
 *          * `BRProduct.shippingStatus`
 *
 *          If you have product intelligence enabled, we also attempt to populate these product fields:
 *
 *          * `BRProduct.productName`
 *          * `BRProduct.brand`
 *          * `BRProduct.category`
 *          * `BRProduct.size`
 *          * `BRProduct.upc`
 *          * `BRProduct.imgUrl`
 *
 *      * `BREmailAccount *account` - the account that the current array of results are for
 *      * `NSError *error` - `nil` on success, otherwise contains the error
 */
- (void)getEReceiptsWithCompletion:(void(^)(NSArray<BRScanResults*> *receipts,
                                            BREmailAccount *account,
                                            NSError *error))completion;

/**
 * Same as above method, just for a single linked account
 */
- (void)getEReceiptsForAccount:(BREmailAccount*)account
                withCompletion:(void(^)(NSArray<BRScanResults*> *receipts,
                                            BREmailAccount *account,
                                            NSError *error))completion;

/**
 *  Initiates a remote asynchronous scrape for all linked accounts. You must have successfully authenticated an OAuth provider, or stored IMAP credentials (and setup IMAP if necessary) prior to calling this method
 *
 *  @param completion   The completion function will be invoked when the attempt to queue the remote scrape job has completed
 *
 *      * `NSInteger jobId` - on success this will contain the job_id which will be used to POST results to your pre-configured results endpoint
 *
 *      * `BREmailAccount *account` - on success this will contain the account which the current `jobId` relates to
 *
 *      * `NSError *error` - `nil` on success, otherwise contains the error
 */
- (void)startRemoteEReceiptScrapeWithCompletion:(void(^)(NSInteger jobId,
                                                         BREmailAccount *account,
                                                         NSError *error))completion;

/**
 * Same as above method, just for a single linked account
 */
- (void)startRemoteEReceiptScrapeForAccount:(BREmailAccount*)account
                             withCompletion:(void(^)(NSInteger jobId,
                                                         BREmailAccount *account,
                                                         NSError *error))completion;
/**
 *  Initiates a remote asynchronous scrape of provided email data (for cases where inbox scraping is done outside of the BlinkEReceipt SDK)
 *
 *  @param email The email address from which the message was obtained
 *  @param provider The email provider from which the message was obtained
 *  @param emlBase64 The base 64-encoded EML data
 *  @param completion   The completion function will be invoked when the attempt to queue the remote scrape job has completed
 *
 *      * `NSInteger jobId` - on success this will contain the job_id which will be used to POST results to your pre-configured results endpoint
 *
 *      * `BREmailAccount *account` - always `nil` in this context since no account is passed in
 *
 *      * `NSError *error` - `nil` on success, otherwise contains the error
 */
- (void)startRemoteEReceiptScrapeForEmail:(NSString*)email
                              andProvider:(BREReceiptProvider)provider
                               andEMLFile:(NSString*)emlBase64
                           withCompletion:(void(^)(NSInteger jobId,
                                                   BREmailAccount *account,
                                                   NSError *error))completion;

/**
*  For debugging the parsing of e-receipt HTML
*
*  @param senderAddress    The email address from which this email originated, must be one of the recognized senders
*  @param rawHTML          The raw HTML from this email
*  @param completion       Same as completion for `getEReceiptWithCompletion:` above
*/
- (void)parseEReceiptFromSender:(NSString*)senderAddress
                        rawHTML:(NSString*)rawHTML
                     completion:(void(^)(NSArray<BRScanResults*> *receipts, NSError *error))completion;

/**
 *  Signs out of all linked email accounts and stored e-receipt info. For OAuth providers this signs out of the provider and invalidates the access token. For IMAP providers this removes stored credentails.
 *
 *  @param completion   The completion function will be invoked when the sign out is complete
 *
 *      * `NSError *error` - `nil` on success, otherwise contains the error
 */
- (void)signOutWithCompletion:(void(^)(NSError *error))completion;

/**
 * Same as above method, just for a single linked account
 */
- (void)signOutFromAccount:(BREmailAccount*)account
            withCompletion:(void(^)(NSError *error))completion;

/**
 *  Resets emails for all linked email accounts so you don't need to log out and log in during testing
 */
- (void)resetEmailsChecked;

/**
 *  A passthrough function to be used in your app delegate's `openURL:options:provider:` method
 */
- (BOOL)openURL:(NSURL*)url
        options:(NSDictionary*)options
       provider:(BREReceiptProvider)provider;

@end
