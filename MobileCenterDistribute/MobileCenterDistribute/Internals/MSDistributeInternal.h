#import <Foundation/Foundation.h>
#import "MSDistribute.h"
#import "MSDistributeSender.h"
#import "MSReleaseDetails.h"
#import "MSSender.h"
#import "MSServiceInternal.h"

#define MOBILE_CENTER_DISTRIBUTE_BUNDLE @"MobileCenterDistributeResources.bundle"

@interface MSDistribute () <MSServiceInternal>

/**
 * An install URL that is used when the SDK needs to acquire update token.
 */
@property(nonatomic, copy) NSString *installUrl;

/**
 * An API url that is used to get release details from backend.
 */
@property(nonatomic, copy) NSString *apiUrl;

/**
 * A sender instance that is used to send a request for new release to the backend.
 */
@property(nonatomic, strong, nullable) MSDistributeSender *sender;

@end
