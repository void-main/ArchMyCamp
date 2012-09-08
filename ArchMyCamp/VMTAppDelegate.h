//
//  VMTAppDelegate.h
//  ArchMyCamp
//
//  Created by Sun Peng on 9/5/12.
//  Copyright (c) 2012 Void Main. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GTMOAuth2/GTMOAuth2Authentication.h"
#import "GTMOAuth2/Mac/GTMOAuth2WindowController.h"
#import "GTMOAuth2/GTMOAuth2Authentication.h"

@class VMTMainScreenWindowController;

@interface VMTAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSButton *loginBtn;
    IBOutlet NSTextField *errorLog;
    
    GTMOAuth2Authentication *mAuth;
    VMTMainScreenWindowController *mainController;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)doLogin:(id)sender;

@end
