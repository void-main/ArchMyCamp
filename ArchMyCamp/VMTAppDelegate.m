//
//  VMTAppDelegate.m
//  ArchMyCamp
//
//  Created by Sun Peng on 9/5/12.
//  Copyright (c) 2012 Void Main. All rights reserved.
//

#import "VMTAppDelegate.h"
#import "VMTMainScreenWindowController.h"

@implementation VMTAppDelegate

- (IBAction)doLogin:(id)sender {
    [self signInToBasecamp];
}


#pragma mark -
#pragma mark OAuth 2.0

// Pre-assigned api key id and secret
static NSString *const kClientID = @"db52676f22fb5f9597cac2885d17ad8f3d484074";
static NSString *const kClientSecret = @"9d8eb103b287b31bd4932effc66abb14fb424c74";
static NSString *const kBasecampKeychainItemName = @"me.voidmain.app.ArchMyCamp-Basecamp";
static NSString *const kBasecampServiceName = @"BasecampIntegrate Service";

- (void) awakeFromNib {
    GTMOAuth2Authentication *auth = [self authForBasecamp];
    if (auth) {
        BOOL didAuth = [GTMOAuth2WindowController authorizeFromKeychainForName:kBasecampKeychainItemName authentication:auth];
        if (didAuth) {
            // Bring up the Main View
            [self setAuthentication:auth];
            [self gotoMainWindow];
        }
    }
    
    [self setAuthentication:auth];
}

- (GTMOAuth2Authentication *)authForBasecamp {
    // https://github.com/37signals/api/blob/master/sections/authentication.md#oauth-2
    NSURL *tokenURL = [NSURL URLWithString:@"https://launchpad.37signals.com/authorization/token"];
    
    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page.
    NSString *redirectURI = @"http://www.arch-my-camp.com/oauth";
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:kBasecampServiceName
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:kClientID
                                                         clientSecret:kClientSecret];
    return auth;
}

- (void) setAuthentication:(GTMOAuth2Authentication *)auth {
    mAuth = auth;
}

- (BOOL)isSignedIn {
    BOOL isSignedIn = mAuth.canAuthorize;
    return isSignedIn;
}

- (void)signInToBasecamp {
    [self signOut];
    
    GTMOAuth2Authentication *auth = [self authForBasecamp];
    auth.scope = @"read";
    
    NSURL *authURL = [NSURL URLWithString:@"https://launchpad.37signals.com/authorization/new"];
    
    // Display the authentication view
    GTMOAuth2WindowController *viewController;
    viewController = [[GTMOAuth2WindowController alloc] initWithAuthentication:auth authorizationURL:authURL keychainItemName:kBasecampKeychainItemName resourceBundle:nil];
    NSString *html = @"<html><body><div align=center>Loading sign-in page...</div></body></html>";
    [viewController setInitialHTMLString:html];
    
    [viewController signInSheetModalForWindow:[self window] delegate:self finishedSelector:@selector(viewController:finishedWithAuth:error:)];
}

- (void) signOut {
    // Remove the stored Basecamp authentication from the keychain, if any
    [GTMOAuth2WindowController removeAuthFromKeychainForName:kBasecampKeychainItemName];
    
    // Discard our retained authentication object
    [self setAuthentication:nil];
}

- (void) viewController:(GTMOAuth2WindowController *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSString *errorStr = [error localizedDescription];
        
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // Show the body of the server's authentication failure response
            errorStr = [[NSString alloc] initWithData:responseData
                                              encoding:NSUTF8StringEncoding];
        } else {
            NSString *str = [[error userInfo] objectForKey:kGTMOAuth2ErrorMessageKey];
            if ([str length] > 0) {
                errorStr = str;
            }
        }
        [errorLog setStringValue:@"Login Failed..."];
        NSLog(@"Error - %@", errorStr);
        
        [self setAuthentication:nil];
    } else {
        [errorLog setStringValue:@""];
        
        [self setAuthentication:auth];
        
        // Show Main View
        NSLog(@"now, we can go to main view");
        [self gotoMainWindow];
    }
}

- (void) gotoMainWindow {
    if (!mainController) {
        mainController = [[VMTMainScreenWindowController alloc] initWithWindowNibName:@"VMTMainScreenWindowController"];
    }
    
    [self doAnAuthenticatedAPIFetch];
    
    [[self window] setReleasedWhenClosed:YES] ;
    [[self window] close];
    [self setWindow:[mainController window]];
}


- (void)doAnAuthenticatedAPIFetch {
    NSString *urlStr = @"https://launchpad.37signals.com/authorization.json";
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mAuth authorizeRequest:request
                  delegate:self
         didFinishSelector:@selector(authentication:request:finishedWithError:)];
}

- (void)authentication:(GTMOAuth2Authentication *)auth
               request:(NSMutableURLRequest *)request
     finishedWithError:(NSError *)error {
    if (error != nil) {
        NSLog(@"Error - %@", error);
    } else {
        NSLog(@"Auth Succeeded...");
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        if (data) {
            NSString *str = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
            NSLog(@"Data - %@", str);
        } else {
            NSLog(@"Fetch Error - %@", [error description]);
        }
    }
}


@end
