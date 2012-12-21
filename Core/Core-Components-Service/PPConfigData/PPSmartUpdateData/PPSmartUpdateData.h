//
//  PPSmartUpdateData.h
//  Draw
//
//  Created by qqn_pipi on 12-11-29.
//
//


/*
 
 Usage Guide
 
 
 Step 1: Init Paths
 
 [PPSmartUpdateDataUtils initPaths];
 
 Step 2: Create a Smart Data Object
 
 _smartData = [[PPSmartUpdateData alloc] initWithName:WORD_BASE_ZIP_NAME
 type:SMART_UPDATE_DATA_TYPE_ZIP
 initDataPath:bundlePath
 initDataVersion:[version stringValue]
 isAutoDownload:YES];
 
 Step 3: Call CheckHasUpdate Method when you need 
 
 [_smartData checkHasUpdate:^(BOOL hasNewVersion, NSString *latestVersion) {
 if (hasNewVersion){
 [_smartData downloadData:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
 } failureBlock:^(NSError *error) {
 } downloadDataVersion:latestVersion];
 }
 } failureBlock:^(NSError *error) {
 
 }];
 
*/

#import <Foundation/Foundation.h>

typedef void(^PPSmartDataFetchSuccessBlock)(BOOL isAlreadyExisted, NSString* dataFilePath);
typedef void(^PPSmartDataCheckUpdateSuccessBlock)(BOOL hasNewVersion, NSString* latestVersion);
typedef void(^PPSmartDataFetchFailureBlock)(NSError *error);

typedef enum {
    SMART_UPDATE_DATA_TYPE_ZIP,
    SMART_UPDATE_DATA_TYPE_PB,
    SMART_UPDATE_DATA_TYPE_TXT
} PPSmartUpdateDataType;

@class ASIHTTPRequest;

@interface PPSmartUpdateData : NSObject

@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) PPSmartUpdateDataType type;
@property (nonatomic, retain) NSString* currentVersion;     // record current version
@property (nonatomic, retain) NSString* currentDataPath;    // current file data path

@property (nonatomic, assign) NSString* initDataPath;       // init data path

@property (nonatomic, retain) NSString* latestVersion;      // record the latest version in server, need to read from server

@property (nonatomic, assign) BOOL isAutoDownload;          // decide whether to auto download file after detecting new version

@property (nonatomic, retain) ASIHTTPRequest* checkVersionHttpRequest;      // record the latest version in server, need to read from server
@property (nonatomic, retain) ASIHTTPRequest* downloadHttpRequest;      // record the latest version in server, need to read from server

@property (nonatomic, assign) PPSmartDataFetchSuccessBlock  downloadDataSuccessBlock;
@property (nonatomic, assign) PPSmartDataFetchFailureBlock  downloadDataFailureBlock;
@property (nonatomic, retain) NSString*                     downloadDataVersion;      

- (id)initWithName:(NSString*)name
              type:(PPSmartUpdateDataType)type
      initDataPath:(NSString*)initDataPath
   initDataVersion:(NSString*)initDataVersion;

- (id)initWithName:(NSString*)name
              type:(PPSmartUpdateDataType)type
        bundlePath:(NSString*)bundlePath
   initDataVersion:(NSString*)initDataVersion;


// call this method to get data file path
- (NSString*)dataFilePath;

// call this method to download data
- (void)downloadData:(PPSmartDataFetchSuccessBlock)successBlock
        failureBlock:(PPSmartDataFetchFailureBlock)failureBlock
 downloadDataVersion:(NSString*)downloadDataVersion;

// call this method to check whether the data has updated version
- (void)checkHasUpdate:(PPSmartDataCheckUpdateSuccessBlock)successBlock failureBlock:(PPSmartDataFetchFailureBlock)failureBlock;

// call this method to check and update and auto download
- (void)checkUpdateAndDownload:(PPSmartDataFetchSuccessBlock)successBlock failureBlock:(PPSmartDataFetchFailureBlock)failureBlock;

@end
