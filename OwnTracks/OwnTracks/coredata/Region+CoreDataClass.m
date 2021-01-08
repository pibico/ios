//
//  Region+CoreDataClass.m
//  OwnTracks
//
//  Created by Christoph Krey on 30.05.18.
//  Copyright © 2018-2021 OwnTracks. All rights reserved.
//
//

#import "Region+CoreDataClass.h"
#import "Friend+CoreDataClass.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation Region

- (NSUUID *)getAndFillIdentifier {
    if (!self.identifier) {
        self.identifier = [NSUUID UUID];
    }
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSData *stringBytes = [self.identifier.UUIDString dataUsingEncoding: NSUTF8StringEncoding];
    unsigned char *sha1 = CC_SHA1([stringBytes bytes], (unsigned int)[stringBytes length], digest);
    if (sha1) {
    } else {
    }
    NSString *string = [[NSString alloc] init];
    for (NSInteger i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        string = [string stringByAppendingFormat:@"%02x", digest[i]];
    }

    return self.identifier;
}

- (NSDate *)getAndFillTst {
    if (!self.tst) {
        self.tst = [NSDate date];
    }
    return self.tst;
}


- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake((self.lat).doubleValue,
                                                              (self.lon).doubleValue);
    return coord;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    self.lat = @(coordinate.latitude);
    self.lon = @(coordinate.longitude);
}

- (MKMapRect)boundingMapRect {
    return [MKCircle circleWithCenterCoordinate:self.coordinate radius:(self.radius).doubleValue].boundingMapRect;
}

- (MKCircle *)circle {
    return [MKCircle circleWithCenterCoordinate:self.coordinate radius:(self.radius).doubleValue];
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    CLRegion *CLregion = self.CLregion;

    if ([CLregion isKindOfClass:[CLCircularRegion class]]) {
        return [NSString stringWithFormat:@"%g,%g r:%gm",
                (self.lat).doubleValue,
                (self.lon).doubleValue,
                (self.radius).doubleValue];
    } else if ([CLregion isKindOfClass:[CLBeaconRegion class]]) {
        return [NSString stringWithFormat:@"%@:%@:%@",
                self.uuid,
                self.major,
                self.minor];
    } else {
        return [NSString stringWithFormat:@"%g,%g",
                (self.lat).doubleValue,
                (self.lon).doubleValue];

    }
}

- (CLRegion *)CLregion {
    CLRegion *region = nil;

    if (self.name && self.name.length) {

        if ((self.radius).doubleValue > 0) {
            region = [[CLCircularRegion alloc] initWithCenter:self.coordinate
                                                       radius:(self.radius).doubleValue
                                                   identifier:self.name];
        } else {
            if (self.uuid) {
                CLBeaconRegion *beaconRegion;
                NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.uuid];

                if ((self.major).unsignedIntValue > 0) {
                    if ((self.minor).unsignedIntValue > 0) {
                        beaconRegion = [[CLBeaconRegion alloc]
                                        initWithUUID:uuid
                                        major:(self.major).unsignedIntValue
                                        minor:(self.minor).unsignedIntValue
                                        identifier:self.name];
                    } else {
                        beaconRegion = [[CLBeaconRegion alloc]
                                        initWithUUID:uuid
                                        major:(self.major).unsignedIntValue
                                        identifier:self.name];
                    }
                } else {
                    beaconRegion = [[CLBeaconRegion alloc]
                                    initWithUUID:uuid
                                    identifier:self.name];
                }
                region = beaconRegion;
            }
        }
    }
    return region;
}

@end
