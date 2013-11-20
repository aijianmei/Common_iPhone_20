//
//  PPViewController.h
//  ___PROJECTNAME___
//
//  Created by qqn_pipi on 10-10-1.
//  Copyright 2010 QQN-PIPI.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "UIUtils.h"
#import "LocaleUtils.h"
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "TKLoadingView.h"
#import "UIBlankView.h"
#import "PPDebug.h"





#define kDefaultBarButton			@"barbutton.png"

#define kLocationUpdateTimeOut		60.0
#define kTimeOutObjectString		@"Time out"

@class PPSegmentControl;
@class ProgressHUD;


@interface PPViewController : UIViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

	NSString*				backgroundImageName;
	
	dispatch_queue_t		workingQueue;
	ABAddressBookRef		addressBook;
	
	TKLoadingView*          loadingView;
    
    ProgressHUD             *progressHUDView;

	
	UIAlertView				*tomcallonalertView;
	int						alertAction;	
	NSTimer					*timer;
	
	// for location handling
	CLLocationManager		*locationManager;
	CLLocation				*currentLocation;
	MKReverseGeocoder		*reverseGeocoder;
	MKPlacemark				*currentPlacemark;
	
//    PPSegmentControl        *titlePPSegControl;
    UISegmentedControl      *titleSegControl;
    UIImage                 *selectedImage;
    NSString                *selectedImageSaveFileName;
    
    UIKeyboardType          currentKeyboardType;
    UIBlankView             *blankView;
    NSMutableDictionary     *notifications;             
}

@property (nonatomic, assign) BOOL                  enableAddressBook;

@property (nonatomic, retain) TKLoadingView*        loadingView;

@property (nonatomic, retain) ProgressHUD*  progressHUDView;




@property (nonatomic, retain) NSTimer				*timer;
@property (nonatomic, retain) NSString*				backgroundImageName;
@property (nonatomic, retain) UIAlertView			*alertView;

@property (nonatomic, retain) CLLocationManager		*locationManager;
@property (nonatomic, copy)	  CLLocation			*currentLocation;
@property (nonatomic, retain) MKReverseGeocoder		*reverseGeocoder;
@property (nonatomic, retain) MKPlacemark			*currentPlacemark;

@property (nonatomic, retain) PPSegmentControl    *titlePPSegControl;
@property (nonatomic, retain) UISegmentedControl  *titleSegControl;
@property (nonatomic, retain) UIImage               *selectedImage;
@property (nonatomic, retain) NSString              *selectedImageSaveFileName;
@property (nonatomic, assign) UIKeyboardType        currentKeyboardType;

@property (nonatomic, retain) UIBlankView             *blankView;


- (void)showBackgroundImage;
- (void)setNavigationRightButton:(NSString*)title imageName:(NSString*)imageName action:(SEL)action;
- (void)setNavigationLeftButton:(NSString*)title imageName:(NSString*)imageName action:(SEL)action;
- (void)setNavigationLeftButton:(NSString*)title action:(SEL)action;
- (void)setNavigationRightButton:(NSString*)title action:(SEL)action;
- (void)setNavigationRightButtonWithSystemStyle:(UIBarButtonSystemItem)systemItem action:(SEL)action;
- (void)setNavigationLeftButtonWithSystemStyle:(UIBarButtonSystemItem)systemItem action:(SEL)action;
- (void)setNavigationLeftButton:(NSString*)title imageName:(NSString*)imageName action:(SEL)action hasEdgeInSet:(BOOL)hasEdgeInSet;
- (void)setNavigationRightButton:(NSString*)title imageName:(NSString*)imageName action:(SEL)action hasEdgeInSet:(BOOL)hasEdgeInSet;
- (void)setNavigationRightButton:(NSString*)title image:(UIImage*)strectableImage action:(SEL)action hasEdgeInSet:(BOOL)hasEdgeInSet;

//- (void)createNavigationTitleToolbar:(NSArray*)titleArray defaultSelectIndex:(int)defaultSelectIndex;
- (void)createDefaultNavigationTitleToolbar:(NSArray*)titleArray defaultSelectIndex:(int)defaultSelectIndex;

// this method helps you to performa an internal method with loading view
- (void)performSelectorWithLoading:(SEL)aSelector loadingText:(NSString*)loadingText;


#pragma mark activity loading view
- (void)showActivityWithText:(NSString*)loadingText withCenter:(CGPoint)point;
- (void)showActivityWithText:(NSString*)loadingText;
- (void)showActivity;
- (void)hideActivity;

#pragma mark activity ProgressHD loading view
- (void)showProgressHUDActivityWithText:(NSString*)loadingText;
- (void)showSucceedProgressHUDActivity:(NSString *)succeedText;
- (void)showErrorProgressHUDActivity:(NSString *)errorText;
- (void)showProgressHUDActivity;
- (void)hideProgressHUDActivity;


// Send Email Methods
- (BOOL)sendEmailTo:(NSArray*)toRecipients 
	   ccRecipients:(NSArray*)ccRecipients 
	  bccRecipients:(NSArray*)bccRecipients 
			subject:(NSString*)subject
			   body:(NSString*)body
			 isHTML:(BOOL)isHTML
		   delegate:(id)delegate;

- (void)sendSms:(NSString*)receiver body:(NSString*)body;
- (void)sendSmsWithReceivers:(NSArray*)receivers body:(NSString*)body;

// for internal usage
- (void)registerKeyboardNotification;
- (void)deregsiterKeyboardNotification;

- (void)popupMessage:(NSString*)msg title:(NSString*)title;
- (void)popupHappyMessage:(NSString*)msg title:(NSString*)title;
- (void)popupUnhappyMessage:(NSString*)msg title:(NSString*)title;
- (void)clearUnPopupMessages;

- (void)clearTimer;

- (void)initLocationManager;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation:(NSString *)state;
- (void)reverseGeocode:(CLLocationCoordinate2D)coordinate;

- (void)selectPhoto;
- (void)takePhoto;

- (void)addBlankView:(UIView*)searchBar;
- (void)setBlankViewDelegate:(id<UIBlankViewDelegate>)delegate;
- (void)addBlankView:(CGFloat)top currentResponder:(UIView*)currentResponder;
- (void)removeBlankView;

- (void)setGroupBuyNavigationBackButton;
- (void)setGroupBuyNavigationTitle:(NSString*)titleString;
- (void)setGroupBuyNavigationRightButton:(NSString*)buttonTitle action:(SEL)action;

// for download
- (void)setDownloadNavigationTitle:(NSString*)titleString;


+ (UIScrollView*)createButtonScrollViewByButtonArray:(NSArray*)buttons 
                                      buttonsPerLine:(int)buttonsPerLine 
                                    buttonSeparatorY:(CGFloat)buttonSeparatorY;

//Create the button with different size according to the button titles
+ (UIScrollView*)createButtonScrollViewByButtonArrayAccordingToButtonTitleSize:(NSArray*)buttons
                                                                buttonsPerLine:(int)buttonsPerLine buttonSeparatorY:(CGFloat)buttonSeparatorY;


- (UIViewController *)superViewControllerForClass:(Class)controllerClass;
- (BOOL)hasSuperViewControllerForClass:(Class)controllerClass;


- (void)registerNotificationWithName:(NSString *)name 
                              object:(id)obj 
                               queue:(NSOperationQueue *)queue
                          usingBlock:(void (^)(NSNotification *note))block;

- (void)registerNotificationWithName:(NSString *)name
                          usingBlock:(void (^)(NSNotification *note))block;

- (void)unregisterNotificationWithName:(NSString *)name;
- (void)unregisterAllNotifications;

- (void)setNavigationLeftButton:(NSString*)title 
                       fontSize:(int)fontSize
                      imageName:(NSString*)imageName 
                         action:(SEL)action;

- (void)setNavigationRightButton:(NSString*)title 
                        fontSize:(int)fontSize
                       imageName:(NSString*)imageName 
                          action:(SEL)action;


-(void)showTabBar;
-(void)hideTabBar;
@end
