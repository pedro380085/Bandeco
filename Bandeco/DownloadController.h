//
//  DownloadController.h
//  Reader
//
//  Created by Pedro Góes on 22/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "SynthesizeSingleton.h"
#import "HTMLParser.h"

@class MasterViewController;

@interface DownloadController : NSObject {
    NSMutableArray * fila;
    NSMutableData * dadosRecebidos;
    BOOL baixando;
    
    MasterViewController *delegate;
}

@property (strong, nonatomic) NSMutableArray * fila;
@property (strong, nonatomic) NSMutableData * dadosRecebidos;

@property (strong, nonatomic) MasterViewController *delegate;


+ (DownloadController *) sharedDownloadController;

- (BOOL)addURL:(NSString *)url savingAs:(NSString *)file;
- (void)initDownload;
- (void)cancelDownload;
- (void)updateInterfaceWithText:(NSString *)text;
- (void)restoreInterface;
- (void)parseCache;

@end
