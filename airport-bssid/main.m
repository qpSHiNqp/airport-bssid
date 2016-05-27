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

char const *phyModeName( enum CWPHYMode n )
{
    switch( (int)n ) {
        case kCWPHYModeNone: return "none";
        case kCWPHYMode11n: return "802.11n";
        case kCWPHYMode11a: return "802.11a";
        case kCWPHYMode11ac: return "802.11ac";
        case kCWPHYMode11g: return "802.11g";
        case kCWPHYMode11b: return "802.11b";
        default: return "other/unknown";
            
    }
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        /**
         * Plan of improvement
         *
         * <<argument handling>>
         * -h, --help: show help
         * -i, --interactive: scan and assoc in interactive way
         * -s, --scan: scan only
         * -k, --use-keychain: let this use keychain on mac. This allows you to omit password input
         *
         * <<help screen>>
         *
         * <<interactive assoc>>
         *
         * <<keychain access>>
         */
        
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
        CWInterface *interface = [[[CWWiFiClient alloc] init] interfaceWithName:interfaceName];
        if(interface.powerOn == NO )
            dump_error(@"The interface is down. Please activate the interface before connecting to network!");
        
        printf("Notice: The interface %s is in %s phyMode.\n", [interfaceName cStringUsingEncoding:NSUTF8StringEncoding], phyModeName(interface.activePHYMode));
        
        // search for target bssid
        NSError *error = nil;
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ssid" ascending:YES];
        NSArray *scan = [[interface scanForNetworksWithSSID:nil error:&error] sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
        if (error)
            dump_error([NSString stringWithFormat:@"An error has been occurred while scanning networks: %@", error]);
        CWNetwork *targetNetwork = nil;
        
        printf("\x1B[0m***** Scanned networks *****\n");
        printf("%24s, %17s, %3s, RSSI(dBm)\n", "ESSID", "BSSID", "Ch");
        for (CWNetwork *network in scan) {
            if ([network.bssid isEqualToString:bssid]) {
                targetNetwork = network;
                printf("%s%24s, %17s, %3lu, %3ld\n", "\x1B[32m", [network.ssid cStringUsingEncoding:NSUTF8StringEncoding], [network.bssid cStringUsingEncoding:NSUTF8StringEncoding], (unsigned long)network.wlanChannel.channelNumber, (long)network.rssiValue);
            } else {
                printf("%s%24s, %17s, %3lu, %3ld\n", "\x1B[0m", [network.ssid cStringUsingEncoding:NSUTF8StringEncoding], [network.bssid cStringUsingEncoding:NSUTF8StringEncoding], (unsigned long)network.wlanChannel.channelNumber, (long)network.rssiValue);
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

