//
//  AppDelegate.m
//  Snake
//
//  Created by Noy H on 11/01/2017.
//  Copyright © 2017 Inscriptio. All rights reserved.
//

#import "AppDelegate.h"
#import "SnakeGame.h"

@implementation AppDelegate

- (id)init {
    if (self = [super init]) {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        [NSApp activateIgnoringOtherApps:YES];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    SnakeGame *view = [[SnakeGame alloc] initWithFrame:NSMakeRect(0, 0, 600, 600)];
    [self.window.contentView addSubview:view];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [NSApp setMainMenu:[NSMenu new]];
    NSMenuItem *appMenuItem = [NSMenuItem new];
    [[NSApp mainMenu] addItem:appMenuItem];
    
    NSMenu *appMenu = [NSMenu new];
    [appMenuItem setSubmenu:appMenu];
    
    NSString *appName = [[NSProcessInfo processInfo] processName];
    NSString *quitTitle = [@"Quit " stringByAppendingString:appName];
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle action:@selector(terminate:) keyEquivalent:@"q"];
    [appMenu addItem:quitMenuItem];
    
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 600, 600)
                                                   styleMask:NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:NO];
    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window setTitle:[[NSProcessInfo processInfo] processName]];
    [window makeKeyAndOrderFront:self];
    [window makeMainWindow];
    self.window = window;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return YES; }

@end
