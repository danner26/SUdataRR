//
//  IPChecker.m
//  SUdataRR
//
//  Created by danner on 8/14/16.
//  Copyright © 2016 Daniel W. Anner. All rights reserved.
//

#ifndef IPChecker_h
#define IPChecker_h


#endif /* IPChecker_h */
#import <Foundation/Foundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include "IPChecker.h"

@implementation IPChecker : NSObject

+ (NSString *)getIP
{
    NSString *address = @"ip_address_error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *addr = NULL;
    int got = getifaddrs(&interfaces);
    if (got == 0) {
        addr = interfaces;
        while (addr != NULL) {
            if( addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)addr->ifa_addr)->sin_addr)];
                }
            }
            
            addr = addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    return address;
}
@end

