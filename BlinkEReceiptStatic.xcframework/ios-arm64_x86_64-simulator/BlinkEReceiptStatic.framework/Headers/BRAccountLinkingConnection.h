//
//  BRAccountLinkingConnection.h
//  WindfallSDK-Dev
//
//  Created by stanislav on 2/7/23.
//  Copyright © 2023 Windfall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRAccountLinkingCredentials.h"
#import "BRAccountLinkingConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAccountLinkingConnection : NSObject

@property (nonatomic, readonly) BRAccountLinkingRetailer retailer;
@property (nonatomic, copy, readonly, nullable) NSString *username;
@property (nonatomic, copy, readonly, nullable) NSString *password;
@property (nonatomic, readonly) NSTimeInterval lastExecutionTime;
@property (nonatomic, readonly) NSUInteger lastExecutionCode;

// A configuration object that defines the behavior when searching for new orders
@property (nonatomic, strong, nonnull) BRAccountLinkingConfiguration *configuration;


- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRetailer:(BRAccountLinkingRetailer)retailer username:(NSString * _Nullable)username password:(NSString * _Nullable)password;

@end

NS_ASSUME_NONNULL_END
