//
//  ViewController.m
//  Xyrality_Test
//
//  Created by Vitalik Beloded on 22.12.15.
//  Copyright © 2015 Vitalik Beloded. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) UITextField* loginField;
@property (nonatomic, assign) UITextField* passwordField;
@property (nonatomic, assign) UILabel* statusField;

@property (nonatomic, retain) UIView* loginView;
@property (nonatomic, retain) UIView* worldsView;

@end

@implementation ViewController

- (void)dealloc {
    
    self.loginView = nil;
    self.worldsView = nil;
    
    [super dealloc];
};

- (void)viewDidLoad {
    
//    _worldsView.hidden = YES;
    
    [self initLoginView];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
};

- (enum UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
};

- (void)initLoginView {
    
    self.loginView = [[[UIView alloc] initWithFrame:[[self view] bounds]] autorelease];
    [self.view addSubview:_loginView];
    
    UIFont* defaultFont = [UIFont fontWithName:@"ArialRoundedMTBold" size:20];
    CGRect defaultFrame = CGRectMake(0,0, _loginView.bounds.size.width * 0.7f, 25);
    
    UILabel* loginDesription = [[[UILabel alloc] initWithFrame:defaultFrame] autorelease];
    loginDesription.text = @"Login:";
    loginDesription.font = defaultFont;
    loginDesription.textColor = [UIColor greenColor];
    
    UITextField* loginField = [[[UITextField alloc] initWithFrame:defaultFrame] autorelease];
    loginField.text = @"ios.test@xyrality.com";
    loginField.textColor = [UIColor greenColor];
    loginField.font = defaultFont;
    loginField.backgroundColor = [UIColor grayColor];
    loginField.borderStyle = UITextBorderStyleRoundedRect;
    
    UILabel* passwordDesription = [[[UILabel alloc] initWithFrame:defaultFrame] autorelease];
    passwordDesription.text = @"Password:";
    passwordDesription.font = defaultFont;
    passwordDesription.textColor = [UIColor greenColor];
    
    UITextField* passwordField = [[[UITextField alloc] initWithFrame:defaultFrame] autorelease];
    passwordField.text = @"password";
    passwordField.textColor = [UIColor greenColor];
    passwordField.font = defaultFont;
    passwordField.backgroundColor = [UIColor grayColor];
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    passwordField.secureTextEntry = YES;
    
    UIButton *connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    connectButton.frame = defaultFrame;
    connectButton.backgroundColor = [UIColor clearColor];
    connectButton.titleLabel.font = defaultFont;
    [connectButton setTitle:@"[ Connect ]"
                forState:UIControlStateNormal];
    
    [connectButton setTitleColor:[UIColor greenColor]
                     forState:UIControlStateNormal ];
    
    [connectButton addTarget:self
                      action:@selector(onConnectButtonPress:)
            forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* statusField = [[[UILabel alloc] initWithFrame:defaultFrame] autorelease];
//    statusField.text = @"Status:";
    statusField.font = defaultFont;
    statusField.textColor = [UIColor greenColor];
    
    id controls = @[ loginDesription, loginField, passwordDesription, passwordField, connectButton, statusField ];
    
    CGPoint c = _loginView.center;
    c.y -= 0.5f * [controls count] * 30.0f;
    
    for (UIView* view in controls)
    {
        view.center = c;
        c.y += 30;
        
        [_loginView addSubview:view];
    }
    
    self.loginField = loginField;
    self.passwordField = passwordField;
    self.statusField = statusField;
};

- (void)onConnectButtonPress:(id)sender {
    
    UIButton* btn = (UIButton*)sender;
    
    btn.enabled = NO;
    
    NSString* parameters = [NSString stringWithFormat:@"login=%@&password=%@&deviceType=%@&deviceId=%@",
                            _loginField.text,
                            _passwordField.text,
                            [NSString stringWithFormat:@"%@ - %@ %@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]],
                            [[NSUUID UUID] UUIDString]
                            ];
    
    NSString* requestString = [NSString stringWithFormat:@"%@?%@",
                               @"http://backend1.lordsandknights.com/XYRALITY/WebObjects/BKLoginServer.woa/wa/worlds",
                               parameters
                               ];
    
    NSURL* requestUrl = [NSURL URLWithString:[requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData * _Nullable data,
                                                                                     NSURLResponse * _Nullable response,
                                                                                     NSError * _Nullable error) {
         
         NSDictionary* worldsInfo = [NSPropertyListSerialization propertyListWithData:data
                                                                      options:NSPropertyListMutableContainersAndLeaves
                                                                       format:NULL
                                                                        error:nil];
                                                                    
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [self initWorldsView:worldsInfo];
             
             _loginView.hidden = YES;
             
         });
                                                                     
        }];
    
    _statusField.text = @"Request processing...";
    
    [task resume];
};

- (void)initWorldsView:(NSDictionary*)worlds {
    
    self.worldsView = [[[UIView alloc] initWithFrame:[[self view] bounds]] autorelease];
    [self.view addSubview:_worldsView];
    
    CGSize s = _worldsView.bounds.size;
    
    UILabel* caption = [[[UILabel alloc] initWithFrame:CGRectMake(s.width * 0.1f, s.height * 0.05f, s.width * 0.8f, 40)] autorelease];
    caption.text = @"Game Worlds (scrollable):";
    caption.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:25];
    caption.textColor = [UIColor greenColor];
    [_worldsView addSubview:caption];
    
    UITextView* textView = [[[UITextView alloc] initWithFrame:CGRectMake(s.width * 0.1f, s.height * 0.05f + 50, s.width * 0.8f, s.height * 0.85f) textContainer:nil] autorelease];
    textView.textColor = [UIColor whiteColor];
    textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20];
    textView.editable = NO;
    [_worldsView addSubview:textView];
    
    NSMutableString* worldsString = [NSMutableString string];
    
    NSArray* allWorldsInfo = worlds[@"allAvailableWorlds"];
    
    for (NSDictionary* worldInfo in allWorldsInfo)
        [worldsString appendFormat:@"%@ %@ %@\n", worldInfo[@"name"], worldInfo[@"country"], (worldInfo[@"worldStatus"])[@"description"]];
    
    textView.text = worldsString;
    
};

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
};

@end
