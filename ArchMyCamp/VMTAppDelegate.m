//
//  VMTAppDelegate.m
//  ArchMyCamp
//
//  Created by Sun Peng on 9/5/12.
//  Copyright (c) 2012 Void Main. All rights reserved.
//

#import "VMTAppDelegate.h"

@implementation VMTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
}

- (IBAction)doLogin:(id)sender {
    [self signInToCustomService];
}


#pragma mark -
#pragma mark OAuth 2.0
NSString *kClientID = @"db52676f22fb5f9597cac2885d17ad8f3d484074";     // pre-assigned by service
NSString *kClientSecret = @"9d8eb103b287b31bd4932effc66abb14fb424c74"; // pre-assigned by service
NSString *kKeychainItemName = @"me.voidmain.app.ArchMyCamp-Basecamp";  // Custom Api

- (GTMOAuth2Authentication *)authForCustomService {
    
    NSURL *tokenURL = [NSURL URLWithString:@"https://launchpad.37signals.com/authorization/token"];
    
    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page.
    NSString *redirectURI = @"http://www.arch-my-camp.com/oauth";
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Basecamp Service"
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:kClientID
                                                         clientSecret:kClientSecret];
    return auth;
}

- (void)signInToCustomService {
    [self signOut];
    
    GTMOAuth2Authentication *auth = [self authForCustomService];
    
    // Specify the appropriate scope string, if any, according to the service's API documentation
    auth.scope = @"read";
    
    NSURL *authURL = [NSURL URLWithString:@"https://launchpad.37signals.com/authorization/new"];
    
    // Display the authentication view
    GTMOAuth2WindowController *viewController;
    viewController = [[GTMOAuth2WindowController alloc] initWithAuthentication:auth authorizationURL:authURL keychainItemName:kKeychainItemName resourceBundle:nil];
    
    [viewController signInSheetModalForWindow:[self window] delegate:self finishedSelector:@selector(viewController:finishedWithAuth:error:)];
}

- (void) signOut {
    [GTMOAuth2WindowController removeAuthFromKeychainForName:kKeychainItemName];
}

- (void)viewController:(GTMOAuth2WindowController *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Sign-in failed
        NSLog(@"Sign-in failed - %@", error);
    } else {
        NSMutableURLRequest *myNSURLMutableRequest = [[NSMutableURLRequest alloc] init];
        [auth authorizeRequest:myNSURLMutableRequest
                      delegate:self
             didFinishSelector:@selector(authentication:request:finishedWithError:)];
    }
}

- (void)authentication:(GTMOAuth2Authentication *)auth
               request:(NSMutableURLRequest *)request
     finishedWithError:(NSError *)error {
    if (error != nil) {
        NSLog(@"Authorization failed - %@", error);
    } else {
        NSLog(@"%@", [auth accessToken]);
    }
}

- (void) awakeFromNib {
}


@end
