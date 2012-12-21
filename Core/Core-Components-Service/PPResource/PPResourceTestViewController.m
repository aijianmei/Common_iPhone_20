//
//  PPResourceTestViewController.m
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import "PPResourceTestViewController.h"
#import "PPResourceService.h"

@interface PPResourceTestViewController ()

@end

@implementation PPResourceTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    PPDebug(@"<PPResourceTestViewController> viewDidLoad");
    [super viewDidLoad];

    [[PPResourceService defaultService] startDownloadInView:self.view backgroundImage:@"DiceDefault" resourcePackageName:@"dice_core" success:^(BOOL alreadyExisted) {

        [self popupMessage:@"Load resources OK!" title:@""];
        
        [self.button2 setImage:[[PPResourceService defaultService] imageByName:@"win_face" inResourcePackage:@"dice_core"]  forState:UIControlStateNormal];
        
        [self.button3 setImage:[[PPResourceService defaultService] imageByName:@"win_face" inResourcePackage:@"dice_core"]  forState:UIControlStateNormal];
        
    } failure:^(NSError *error, UIView* downloadView) {
        
        [self popupMessage:@"Fail to load resources" title:@""];
        
    }];
    
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_imageView1 release];
    [_button1 release];
    [_button2 release];
    [_button3 release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setImageView1:nil];
    [self setButton1:nil];
    [self setButton2:nil];
    [self setButton3:nil];
    [super viewDidUnload];
}
@end
