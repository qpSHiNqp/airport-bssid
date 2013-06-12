//
//  main.m
//  airport-bssid
//
//  Created by Shintaro Tanaka on 6/11/13.
//  Copyright (c) 2013 Shintaro Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreWLAN/CoreWLAN.h>

NSString *usage_string(NSString *arg0) {
    return [NSString stringWithFormat:@"usage: %@ <ifname> [<bssid>] [<password>]", arg0];
}

void dump_error(NSString *message) {
    printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
    exit(1);
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // args check and initialization
        if (!(argc > 1)) dump_error(usage_string([NSString stringWithUTF8String:argv[0]]));
        NSString *interfaceName = [NSString stringWithUTF8String:argv[1]];
        NSString *bssid = nil;
        if (argc > 2) {
            bssid = [NSString stringWithUTF8String:argv[2]];
        }
        NSString *password = nil;
        if (argc > 3) {
            password = [NSString stringWithUTF8String:argv[3]];
        }
        
        // interface check
        CWInterface *interface = [[CWInterface alloc] initWithInterfaceName:interfaceName];
        if(interface.powerOn == NO )
            dump_error(@"The interface is down. Please activate the interface before connecting to network!");
        
        // search for target bssid
        NSError *error = nil;
        NSSet *scan = [interface scanForNetworksWithSSID:nil error:&error];
        if (error)
            dump_error([NSString stringWithFormat:@"An error has been occurred while scanning networks: %@", error]);
        CWNetwork *targetNetwork = nil;
        
        printf("\x1B[0m***** Scanned networks *****\n");
        for (CWNetwork *network in scan) {
            if ([network.bssid isEqualToString:bssid]) {
                targetNetwork = network;
                printf("%s* [ssid: %-24s, bssid: %18s, channel: %3lu, rssi: %3ld dBm]\n", "\x1B[32m", [network.ssid cStringUsingEncoding:NSUTF8StringEncoding], [network.bssid cStringUsingEncoding:NSUTF8StringEncoding], (unsigned long)network.wlanChannel.channelNumber, (long)network.rssiValue);
            } else {
                printf("%s- [ssid: %-24s, bssid: %18s, channel: %3lu, rssi: %3ld dBm]\n", "\x1B[0m", [network.ssid cStringUsingEncoding:NSUTF8StringEncoding], [network.bssid cStringUsingEncoding:NSUTF8StringEncoding], (unsigned long)network.wlanChannel.channelNumber, (long)network.rssiValue);
            }
        }
        printf("\x1B[0m****************************\n");

        if (bssid == nil) {
            dump_error([NSString stringWithFormat:@"Network scan completed. If you want to connect to specific BSSID, please enter the command below:\n %@ <ifname> <bssid> [<password>]", [NSString stringWithUTF8String:argv[0]]]);
        }

        if (targetNetwork == nil)
            dump_error([NSString stringWithFormat:@"The target network \"%@\" could not be found.", bssid]);
        
        // connection trial
        BOOL result = [interface associateToNetwork:targetNetwork password:password error:&error];
        
        if (error)
            dump_error([NSString stringWithFormat:@"Could not connect to the network: %@", error]);
        
        if( !result )
			dump_error(@"Could not connect to the network!");
        
        printf("Associated to network \"%s\" (BSSID: %s)\n", [targetNetwork.ssid cStringUsingEncoding:NSUTF8StringEncoding], [bssid cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    return 0;
}

