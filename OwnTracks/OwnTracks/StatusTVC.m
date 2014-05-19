//
//  StatusTVC.m
//  OwnTracks
//
//  Created by Christoph Krey on 11.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "StatusTVC.h"
#import "QosTVC.h"
#import "OwnTracksAppDelegate.h"


@interface StatusTVC ()
@property (weak, nonatomic) IBOutlet UIProgressView *UIprogress;
@property (weak, nonatomic) IBOutlet UISwitch *UIconnection;
@property (weak, nonatomic) IBOutlet UITextField *UIurl;
@property (weak, nonatomic) IBOutlet UITextField *UIVersion;
@property (weak, nonatomic) IBOutlet UITextView *UIerrorCode;
@property (weak, nonatomic) IBOutlet UITextField *UIeffectiveTopic;
@property (weak, nonatomic) IBOutlet UITextField *UIeffectiveClientId;
@property (weak, nonatomic) IBOutlet UITextField *UIeffectiveWillTopic;
@property (weak, nonatomic) IBOutlet UITextField *UIeffectiveDeviceId;
@property (weak, nonatomic) IBOutlet UITextField *UIDeviceID;
@property (weak, nonatomic) IBOutlet UITextField *UILocatorDisplacement;
@property (weak, nonatomic) IBOutlet UITextField *UILocatorInterval;
@property (weak, nonatomic) IBOutlet UITextField *UIHost;
@property (weak, nonatomic) IBOutlet UITextField *UIUserID;
@property (weak, nonatomic) IBOutlet UITextField *UIPassword;
@property (weak, nonatomic) IBOutlet UITextField *UISubscription;
@property (weak, nonatomic) IBOutlet UISwitch *UIUpdateAddressBook;
@property (weak, nonatomic) IBOutlet UITextField *UIPositionsToKeep;
@property (weak, nonatomic) IBOutlet UITextField *UITopic;
@property (weak, nonatomic) IBOutlet UISwitch *UIRetain;
@property (weak, nonatomic) IBOutlet UISwitch *UICMD;
@property (weak, nonatomic) IBOutlet UITextField *UIClientID;
@property (weak, nonatomic) IBOutlet UITextField *UIPort;
@property (weak, nonatomic) IBOutlet UISwitch *UITLS;
@property (weak, nonatomic) IBOutlet UISwitch *UICleanSession;
@property (weak, nonatomic) IBOutlet UISwitch *UIAuth;
@property (weak, nonatomic) IBOutlet UITextField *UIKeepAlive;
@property (weak, nonatomic) IBOutlet UITextField *UIWillTopic;
@property (weak, nonatomic) IBOutlet UISwitch *UIWillRetain;
@property (weak, nonatomic) IBOutlet UITextField *UIqos;
@property (weak, nonatomic) IBOutlet UITextField *UIwillqos;
@property (weak, nonatomic) IBOutlet UITextField *UIsubscriptionqos;

@property (strong, nonatomic) UIDocumentInteractionController *dic;

@end

@implementation StatusTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate addObserver:self forKeyPath:@"connectionState" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [delegate addObserver:self forKeyPath:@"connectionBuffered" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
    [self updated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate removeObserver:self forKeyPath:@"connectionState" context:nil];
    [delegate removeObserver:self forKeyPath:@"connectionBuffered" context:nil];

    if (self.UIDeviceID) [delegate.settings setString:self.UIDeviceID.text forKey:@"deviceid_preference"];
    if (self.UILocatorDisplacement) [delegate.settings setString:self.UILocatorDisplacement.text forKey:@"mindist_preference"];
    if (self.UILocatorInterval) [delegate.settings setString:self.UILocatorInterval.text forKey:@"mintime_preference"];
    if (self.UIHost) [delegate.settings setString:self.UIHost.text forKey:@"host_preference"];
    if (self.UIUserID) [delegate.settings setString:self.UIUserID.text forKey:@"user_preference"];
    if (self.UIPassword) [delegate.settings setString:self.UIPassword.text forKey:@"pass_preference"];
    if (self.UISubscription) [delegate.settings setString:self.UISubscription.text forKey:@"subscription_preference"];
    if (self.UIUpdateAddressBook) [delegate.settings setBool:self.UIUpdateAddressBook.on forKey:@"ab_preference"];
    if (self.UIPositionsToKeep) [delegate.settings setString:self.UIPositionsToKeep.text forKey:@"positions_preference"];
    if (self.UITopic) [delegate.settings setString:self.UITopic.text forKey:@"topic_preference"];
    if (self.UIRetain) [delegate.settings setBool:self.UIRetain.on forKey:@"retain_preference"];
    if (self.UICMD) [delegate.settings setBool:self.UICMD.on forKey:@"cmd_preference"];
    if (self.UIClientID) [delegate.settings setString:self.UIClientID.text forKey:@"clientid_preference"];
    if (self.UIPort) [delegate.settings setString:self.UIPort.text forKey:@"port_preference"];
    if (self.UITLS) [delegate.settings setBool:self.UITLS.on forKey:@"tls_preference"];
    if (self.UIAuth) [delegate.settings setBool:self.UIAuth.on forKey:@"auth_preference"];
    if (self.UICleanSession) [delegate.settings setBool:self.UICleanSession.on forKey:@"clean_preference"];
    if (self.UIKeepAlive) [delegate.settings setString:self.UIKeepAlive.text forKey:@"keepalive_preference"];
    if (self.UIWillTopic) [delegate.settings setString:self.UIWillTopic.text forKey:@"willtopic_preference"];
    if (self.UIWillRetain) [delegate.settings setBool:self.UIWillRetain.on forKey:@"willretain_preference"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updatedStatus];
}

- (void)updatedStatus
{
    OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.UIurl.text = delegate.connection.url;
    
    const NSDictionary *states = @{
                                   @(state_starting): @"idle",
                                   @(state_connecting): @"connecting",
                                   @(state_error): @"error",
                                   @(state_connected): @"connected",
                                   @(state_closing): @"closing",
                                   @(state_closed): @"closed"
                                   };
    
    self.UIerrorCode.text = [NSString stringWithFormat:@"%@ %@",
                             states[delegate.connectionState],
                             delegate.connection.lastErrorCode ? delegate.connection.lastErrorCode.localizedDescription : @""];
    
    switch ([delegate.connectionState longValue]) {
        case state_connected:
            self.UIconnection.on = TRUE;
            break;
        case state_starting:
        case state_closing:
        case state_connecting:
        case state_closed:
        case state_error:
        default:
            self.UIconnection.on = FALSE;
            break;
    }
    
    [self.UIprogress setProgress:1.0 / ([delegate.connectionBuffered intValue] + 1) animated:YES];
}

- (void)updated
{
    [self updatedStatus];
    OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.UIurl.text = delegate.connection.url;
    
    self.UIVersion.text =                           [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    self.UIeffectiveDeviceId.text =                 [delegate.settings theDeviceId];
    self.UIeffectiveClientId.text =                 [delegate.settings theClientId];
    self.UIeffectiveTopic.text =                    [delegate.settings theGeneralTopic];
    self.UIeffectiveWillTopic.text =                [delegate.settings theWillTopic];
    
    self.UIDeviceID.text =                          [delegate.settings stringForKey:@"deviceid_preference"];
    self.UILocatorDisplacement.text =               [delegate.settings stringForKey:@"mindist_preference"];
    self.UILocatorInterval.text =                   [delegate.settings stringForKey:@"mintime_preference"];
    self.UIHost.text =                              [delegate.settings stringForKey:@"host_preference"];
    self.UIUserID.text =                            [delegate.settings stringForKey:@"user_preference"];
    self.UIPassword.text =                          [delegate.settings stringForKey:@"pass_preference"];
    self.UISubscription.text =                      [delegate.settings stringForKey:@"subscription_preference"];
    self.UIUpdateAddressBook.on =                   [delegate.settings boolForKey:@"ab_preference"];
    self.UIPositionsToKeep.text =                   [delegate.settings stringForKey:@"positions_preference"];
    self.UIsubscriptionqos.text =                   [self qosString:[delegate.settings intForKey:@"subscriptionqos_preference"]];
    self.UITopic.text =                             [delegate.settings stringForKey:@"topic_preference"];
    self.UIqos.text =                               [self qosString:[delegate.settings intForKey:@"qos_preference"]];
    self.UIRetain.on =                              [delegate.settings boolForKey:@"retain_preference"];
    self.UICMD.on =                                 [delegate.settings boolForKey:@"cmd_preference"];
    self.UIClientID.text =                          [delegate.settings stringForKey:@"clientid_preference"];
    self.UIPort.text =                              [delegate.settings stringForKey:@"port_preference"];
    self.UITLS.on =                                 [delegate.settings boolForKey:@"tls_preference"];
    self.UIAuth.on =                                [delegate.settings boolForKey:@"auth_preference"];
    self.UICleanSession.on =                        [delegate.settings boolForKey:@"clean_preference"];
    self.UIKeepAlive.text =                         [delegate.settings stringForKey:@"keepalive_preference"];
    self.UIWillTopic.text =                         [delegate.settings stringForKey:@"willtopic_preference"];
    self.UIwillqos.text =                           [self qosString:[delegate.settings intForKey:@"willqos_preference"]];
    self.UIWillRetain.on =                          [delegate.settings boolForKey:@"willretain_preference"];
}

- (IBAction)exportPressed:(UIButton *)sender {
    OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;
    NSError *error;
    
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                 inDomain:NSUserDomainMask
                                                        appropriateForURL:nil
                                                                   create:YES
                                                                    error:&error];
    NSString *fileName = [NSString stringWithFormat:@"config.otrc"];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    
    [[NSFileManager defaultManager] createFileAtPath:[fileURL path]
                                            contents:[delegate.settings toData]
                                          attributes:nil];
    
    self.dic = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.dic.delegate = self;
    [self.dic presentOptionsMenuFromRect:sender.window.frame
                                  inView:self.tableView
                                animated:YES];
}

- (IBAction)documentationPressed:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:@"https://github.com/owntracks/owntracks/wiki"]];
}

- (IBAction)connectionSwitched:(UISwitch *)sender {
    OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;

    if (sender.on) {
        [delegate connectionOff];
        [delegate reconnect];
    } else {
        [delegate connectionOff];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;

    if ([segue.destinationViewController respondsToSelector:@selector(setEditQos:)] &&
        [segue.destinationViewController respondsToSelector:@selector(setEditIdentifier:)]) {
        if ([segue.identifier isEqualToString:@"setQos:"]) {
            [segue.destinationViewController performSelector:@selector(setEditQos:)
                                                  withObject:@([delegate.settings intForKey:@"qos_preference"])];
            [segue.destinationViewController performSelector:@selector(setEditIdentifier:)
                                                  withObject:@"qos_preference"];
        }
        if ([segue.identifier isEqualToString:@"setWillQos:"]) {
            [segue.destinationViewController performSelector:@selector(setEditQos:)
                                                  withObject:@([delegate.settings intForKey:@"willqos_preference"])];
            [segue.destinationViewController performSelector:@selector(setEditIdentifier:)
                                                  withObject:@"willqos_preference"];
        }
        if ([segue.identifier isEqualToString:@"setSubscriptionQos:"]) {
            [segue.destinationViewController performSelector:@selector(setEditQos:)
                                                  withObject:@([delegate.settings intForKey:@"subscriptionqos_preference"])];
            [segue.destinationViewController performSelector:@selector(setEditIdentifier:)
                                                  withObject:@"subscriptionqos_preference"];
        }
    }
}

- (IBAction)setQoS:(UIStoryboardSegue *)segue {
    OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;

    if ([segue.sourceViewController respondsToSelector:@selector(editQos)] &&
        [segue.sourceViewController respondsToSelector:@selector(editIdentifier)]) {
        NSNumber *qos = [segue.sourceViewController performSelector:@selector(editQos)];
        NSString *identifier = [segue.sourceViewController performSelector:@selector(editIdentifier)];
        
        [delegate.settings setInt:[qos intValue] forKey:identifier];
        [self updated];
    }
}

- (NSString *)qosString:(int)qos
{
    switch (qos) {
        case 2:
            return @"exactly once";
        case 1:
            return @"at least once";
        case 0:
        default:
            return @"at most once";
    }
}

@end
