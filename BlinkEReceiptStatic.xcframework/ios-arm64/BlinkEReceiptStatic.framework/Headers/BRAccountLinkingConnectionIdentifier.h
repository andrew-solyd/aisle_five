//
//  BRAccountLinkingConnectionIdentifier.h
//  WindfallSDK-Dev
//
//  Created by stanislav on 2/7/23.
//  Copyright © 2023 Windfall. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRAccountLinkingConnectionIdentifier : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString *rawValue;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
