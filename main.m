//
//  main.m
//  Snake
//
//  Created by Noy H on 11/01/2017.
//  Copyright © 2017 Inscriptio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [[NSApplication sharedApplication] setDelegate:delegate];
        [NSApp run];
    }
    return EXIT_SUCCESS;
}
