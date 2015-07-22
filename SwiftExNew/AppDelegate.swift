//
//  AppDelegate.swift
//  SwiftExNew
//
//  Created by Justin Platz on 7/20/15.
//  Copyright (c) 2015 ioJP. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

    var window: UIWindow?
    //MARK: Properties
    var client: PubNub?
    var channel1: NSString?
    var channel2: NSString?
    var channelGroup1: NSString?
    var subKey: NSString?
    var pubKey: NSString?
    var authKey: NSString?
    
    var timer: NSTimer?
    var myConfig: PNConfiguration?
    
    //MARK: Configuration
    //func updateClientConfiguration(Void){}
    //func printClientConfiguration(Void){}

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //MARK: Pam Use Case Config
        //Settings Config for PAM Example
        //Uncomment this setion line for a PAM use-case example
        
        //http://www.pubnub.com/console/?channel=good&origin=d.pubnub.com&sub=pam&pub=pam&cipher=&ssl=false&secret=pam&auth=myAuthKey
        
        //        self.channel1 = "good"
        //        self.channel2 = "bad"
        //        self.pubKey   = "pam"
        //        self.subKey   = "pam"
        //        self.authKey  = "foo"
        
        //MARK: Settings Config for Non-PAM Use Case Config
        
        self.channel1 = "bot"
        self.channel2 = "myCh"
        self.channelGroup1 = "myChannelGroup"
        self.pubKey   = "demo-36"
        self.subKey   = "demo-36"
        self.authKey  = "myAuthKey"
        
        //MARK: Kick the tires!
        
        tireKicker()
        
        return true

    }
    
    func pubNubInit(){
        PNLog.enabled(true)
        PNLog.setMaximumLogFileSize(10)
        PNLog.setMaximumNumberOfLogFiles(10)
        
        //Initialize PubNub client
        myConfig = PNConfiguration(publishKey: pubKey! as String, subscribeKey: subKey! as String)
        // # as String ^^?
        updateClientConfiguration()
        printClientConfiguration()
        
        //Bind config
        self.client = PubNub.clientWithConfiguration(myConfig)
        
        // Bind didReceiveMessage, didReceiveStatus, and didReceivePresenceEvent 'listeners' to this delegate
        // just be sure the target has implemented the PNObjectEventListener extension
        
        self.client?.addListener(self)
        //pubNubSetState()
    }

    
    func tireKicker(){
        self.pubNubInit()
        
        //MARK: - Time
        self.pubNubTime()
        
        //MARK:  - Publish
        self.pubNubPublish()
        
        //MARK:  - History
        self.pubNubHistory()
        
        //MARK:  - Channel Groups Subscribe / Unsubscribe
        self.pubNubSubscribeToChannelGroup()
        self.pubNubUnsubscribeFromChannels()
        
        //MARK:  - Here Nows
        self.pubNubHereNowForChannel()
        self.pubNubGlobalHereNow()
        self.pubNubHereNowForChannelGroups()
        self.pubNubWhereNow()
        
        //MARK:  - CG Admin
        self.pubNubCGAdd()
        self.pubNubChannelsForGroup()
        self.pubNubCGRemoveAllChannels()
        self.pubNubCGRemoveSomeChannels()
        
        //MARK:  - State Admin
        self.pubNubSetState()
        self.pubNubGetState()
        
        //MARK:  - 3rd Party Push Notifications Admin
        self.pubNubAddPushNotifications()
        self.pubNubRemovePushNotification()
        self.pubNubRemoveAllPushNotifications()
        self.pubNubGetAllPushNotifications()
        
        //MARK:  - Public Encryption/Decryption Methods
        self.pubNubAESDecrypt()
        self.pubNubAESEncrypt()
        
        //MARK: - Message Size Check Methods
        self.pubNubSizeOfMessage()
    }
    
    func pubNubTime(){
        self.client?.timeWithCompletion({ (result, status) -> Void in
            if((result.data) != nil){
                println("Result from Time: \(result.data.timetoken)")
            }
            else if((status) != nil){
                self.handleStatus(status)
            }
        })
    }
    
    func pubNubHistory(){
        // History
        
        self.client?.historyForChannel(channel1 as! String, withCompletion: { (result, status) -> Void in
            // For completion blocks that provide both result and status parameters, you will only ever
            // have a non-nil status or result.
            
            // If you have a result, the data you specifically requested (in this case, history response) is available in result.data
            // If you have a status, error or non-error status information is available regarding the call.
            
            if ((status) != nil) {
                // As a status, this contains error or non-error information about the history request, but not the actual history data I requested.
                // Timeout Error, PAM Error, etc.
                
                self.handleStatus(status)
            }
            else if ((result) != nil) {
                // As a result, this contains the messages, start, and end timetoken in the data attribute
                
                println("Loaded history data: \(result.data.messages) with start \(result.data.start) and end \(result.data.end)")
            }
        })
        
        /*
        [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> includeTimeToken:<#(BOOL)shouldIncludeTimeToken#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
        [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> limit:<#(NSUInteger)limit#> includeTimeToken:<#(BOOL)shouldIncludeTimeToken#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
        [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> limit:<#(NSUInteger)limit#> reverse:<#(BOOL)shouldReverseOrder#> includeTimeToken:<#(BOOL)shouldIncludeTimeToken#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
        [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> limit:<#(NSUInteger)limit#> reverse:<#(BOOL)shouldReverseOrder#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
        [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> limit:<#(NSUInteger)limit#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
        [self.client historyForChannel:<#(NSString *)channel#> start:<#(NSNumber *)startDate#> end:<#(NSNumber *)endDate#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
        [self.client historyForChannel:<#(NSString *)channel#> withCompletion:<#(PNHistoryCompletionBlock)block#>];
        */
    }
    
    func pubNubUnsubscribeFromChannels(){
        self.client?.unsubscribeFromChannels([channelGroup1 as! String], withPresence: true)
    }
    
    func pubNubSubscribeToChannelGroup(){
        self.client?.subscribeToChannelGroups([channelGroup1 as! String], withPresence: false)
        /*
        [self.client subscribeToChannelGroups:@[_channelGroup1] withPresence:YES clientState:@{@"foo":@"bar"}];
        */
    }
    
    func pubNubGlobalHereNow(){
        self.client?.hereNowWithCompletion({ (result, status) -> Void in
            if ((status) != nil) {
                self.handleStatus(status)
            }
            else if ((result) != nil) {
                println("^^^^ Loaded Global hereNow data: channels: \(result.data.channels), total channels: \(result.data.totalChannels), total occupancy: \(result.data.totalOccupancy)")
            }
        })
        // If you want to control the 'verbosity' of the server response -- restrict to (values are additive):
        
        // Occupancy                : PNHereNowOccupancy
        // Occupancy + UUID         : PNHereNowUUID
        // Occupancy + UUID + State : PNHereNowState
        
        self.client?.hereNowWithVerbosity(PNHereNowVerbosityLevel.Occupancy, completion: { (result, status) -> Void in
            
            if ((status) != nil) {
                self.handleStatus(status)
            }
            else if ((result) != nil) {
                println("^^^^ Loaded Global hereNow data: channels: \(result.data.channels), total channels: \(result.data.totalChannels), total occupancy: \(result.data.totalOccupancy)");
            }
        })
        //^# PNHereNowVerbosityLevel.Occupancy
    }
    
    func pubNubHereNowForChannelGroups(){
        /*
        [self.client hereNowForChannelGroup:<#(NSString *)group#> withCompletion:<#(PNChannelGroupHereNowCompletionBlock)block#>];
        [self.client hereNowForChannelGroup:<#(NSString *)group#> withVerbosity:<#(PNHereNowVerbosityLevel)level#> completion:<#(PNChannelGroupHereNowCompletionBlock)block#>];
        */
    }
    
    func pubNubHereNowForChannel(){
        self.client?.hereNowForChannel(channel1 as! String, withCompletion: { (result, status) -> Void in
            if ((status) != nil) {
                
                self.handleStatus(status)
            }
            else if ((result) != nil) {
                println("^^^^ Loaded hereNowForChannel data: occupancy: \(result.data.occupancy), uuids: \(result.data.uuids)")
            }
        })
        
        // If you want to control the 'verbosity' of the server response -- restrict to (values are additive):
        
        // Occupancy                : PNHereNowOccupancy
        // Occupancy + UUID         : PNHereNowUUID
        // Occupancy + UUID + State : PNHereNowState
        
        
        
        self.client?.hereNowForChannel(channel1 as! String, withVerbosity:  PNHereNowVerbosityLevel.State, completion: { (result, status) -> Void in
            //PNHereNowVerbosityLevel.State is not PNHereNowState
            if ((status) != nil) {
                self.handleStatus(status)
            }
            else if ((result) != nil) {
                println("^^^^ Loaded hereNowForChannel data: occupancy: \(result.data.occupancy), uuids: \(result.data.uuids)")
            }
        })
    }
    
    func pubNubWhereNow(){
        self.client?.whereNowUUID("123456", withCompletion: { (result, status) -> Void in
            if((status) != nil){
                self.handleStatus(status)
            }
            else if((result) != nil){
                println("^^^^ Loaded whereNow data: \(result.data.channels)")
            }
        })
    }
    
    func pubNubCGAdd(){
        weak var weakSelf = self
        
        self.client?.addChannels([channel1 as! String, channel2 as! String], toGroup: channelGroup1 as! String, withCompletion: { (status) -> Void in
            
//            var strongSelf = weakSelf
            
            if(!status.error){
                println("^^^^ CGAdd Request Succeeded")
            }
            else{
                println("^^^^ CGAdd Subscribe requet did not succeed. All Subscribe operations will autorety when possible")
                self.handleStatus(status)
                //^# strong self
            }
        })
    }
    
    func pubNubChannelsForGroup(){
        self.client?.channelsForGroup(channelGroup1 as! String, withCompletion: { (result, status) -> Void in
            if ((status) != nil) {
                self.handleStatus(status)
            }
            else if ((result) != nil) {
                println("^^^^ Loaded all channels \(result.data.channels) for group \(self.channelGroup1)");
            }
        })
    }
    
    func pubNubCGRemoveSomeChannels(){
        
        self.client?.removeChannels([channel2 as! String], fromGroup: channelGroup1 as! String, withCompletion: { (status) -> Void in
            if(!status.error){
                println("^^^^CG Remove some channgels request succeeded at time token ")
            }
            else{
                println("^^^^CG Remove some channels request did not succeed. All Subscribe operations will autoretry when possible")
                self.handleStatus(status)
            }
        })
    }
    
    
    func pubNubCGRemoveAllChannels(){
        self.client?.removeChannelsFromGroup(channelGroup1 as! String, withCompletion: { (status) -> Void in
            if(!status.error){
                println("^^^^ CG Remove All Channels request succeeded")
            }
            else{
                println("^^^^ CG Remove All Channels did not succeed. All Subscribe operations will autorety when possible.")
                self.handleStatus(status)
            }
        })
    }
    
    func pubNubSizeOfMessage(){
        self.client?.sizeOfMessage("Connected! I'm here!", toChannel: channel1 as! String, withCompletion: { (size) -> Void in
            println("^^^^ Message size: \(size)")
        })
    }
    
    func pubNubAESDecrypt(){
        /*
        [PNAES decrypt:<#(NSString *)object#> withKey:<#(NSString *)key#>];
        [PNAES decrypt:<#(NSString *)object#> withKey:<#(NSString *)key#> andError:<#(NSError *__autoreleasing *)error#>];
        */
    }
    
    func pubNubAESEncrypt(){
        /*
        [PNAES encrypt:<#(NSData *)data#> withKey:<#(NSString *)key#>];
        [PNAES encrypt:<#(NSData *)data#> withKey:<#(NSString *)key#> andError:<#(NSError *__autoreleasing *)error#>];
        */
    }
    
    func pubNubAddPushNotifications(){
        /*
        self.client.addPushNotificationsOnChannels((NSArray *)channels withDevicePushToken:(NSData *)pushToken andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block)
        */
    }
    
    func pubNubRemovePushNotification(){
        /*
        self.client.removePushNotificationsFromChannels((NSArray *)channels withDevicePushToken:(NSData *)pushToken andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block)
        */
    }
    
    func pubNubRemoveAllPushNotifications(){
        /*
        self.client.removeAllPushNotificationsFromDeviceWithPushToken((NSData *)pushToken andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block)
        */
    }
    
    func pubNubGetAllPushNotifications(){
        /*
        self.client.pushNotificationEnabledChannelsForDeviceWithPushToken((NSData *)pushToken andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block)
        */
        //^# does nothing?
    }

    
    func pubNubSetState(){
        weak var weakSelf = self
        self.client?.setState(["foo":"bar"] , forUUID: myConfig?.uuid, onChannel: channel1 as! String, withCompletion: { (status) -> Void in
            self.handleStatus(status)
        })
        //^# random string stuff not done right
    }
    
    func pubNubGetState(){
        self.client?.stateForUUID(myConfig?.uuid, onChannel: channel1 as! String, withCompletion: { (result, status) -> Void in
            if((status) != nil){
                self.handleStatus(status)
            }
            else if((result) != nil){
                println("^^^^ Loaded state \(result.data.state) for channel \(self.channel1)")
            }
        })
    }
    


    
    func handleStatus(status : PNStatus){
        //  Two types of status events are possible. Errors, and non-errors. Errors will prevent normal operation of your app.
        //
        //    If this was a subscribe or presence PAM error, the system will continue to retry automatically.
        //    If this was any other operation, you will need to manually retry the operation.
        //
        //    You can always verify if an operation will auto retry by checking status.willAutomaticallyRetry
        //    If the operation will not auto retry, you can manually retry by calling [status retry]
        //    Retry attempts can be cancelled via [status cancelAutomaticRetry]
        
        if(status.error){
            handleErrorStatus(status as! PNErrorStatus)
            // # ^ as!
        }
        else{
            handleNonErrorStatus(status)
        }
    }
    
    func handleErrorStatus(status : PNErrorStatus){
        println("Debug: \(status.debugDescription)")
        println("handleErrorStatus: PAM Error: for resource Will Auto Retry?: \(status.automaticallyRetry)")
        // # ^ ? YES OR NO
        
        if (status.category == PNStatusCategory.PNAccessDeniedCategory) {
            self.handlePAMError(status)
        }
        else if (status.category == PNStatusCategory.PNDecryptionErrorCategory) {
            
            println("Decryption error. Be sure the data is encrypted and/or encrypted with the correct cipher key.")
            println("You can find the raw data returned from the server in the status.data attribute: \(status.errorData)")
        }
        else if (status.category == PNStatusCategory.PNMalformedResponseCategory) {
            
            println("We were expecting JSON from the server, but we got HTML, or otherwise not legal JSON.")
            println("This may happen when you connect to a public WiFi Hotspot that requires you to auth via your web browser first,")
            println("or if there is a proxy somewhere returning an HTML access denied error, or if there was an intermittent server issue.")
        }
            
        else if (status.category == PNStatusCategory.PNTimeoutCategory) {
            
            println("For whatever reason, the request timed out. Temporary connectivity issues, etc.")
        }
            
        else {
            // Aside from checking for PAM, this is a generic catch-all if you just want to handle any error, regardless of reason
            // status.debugDescription will shed light on exactly whats going on
            
            println("Request failed... if this is an issue that is consistently interrupting the performance of your app,");
            println("email the output of debugDescription to support along with all available log info: \(status.debugDescription)");
        }
    }
    
    func handleNonErrorStatus(status : PNStatus){
        // This method demonstrates how to handle status events that are not errors -- that is,
        // status events that can safely be ignored, but if you do choose to handle them, you
        // can get increased functionality from the client
        
        if (status.category == PNStatusCategory.PNAcknowledgmentCategory) {
            println("^^^^ Non-error status: ACK")
            
            
            // For methods like Publish, Channel Group Add|Remove|List, APNS Add|Remove|List
            // when the method is executed, and completes, you can receive the 'ack' for it here.
            // status.data will contain more server-provided information about the ack as well.
            
        }
        if (status.operation == PNOperationType.SubscribeOperation) {
            
            var subscriberStatus: PNSubscribeStatus = status as! PNSubscribeStatus
            // ^ #
            // Specific to the subscribe loop operation, you can handle connection events
            // These status checks are only available via the subscribe status completion block or
            // on the long-running subscribe loop listener didReceiveStatus
            
            // Connection events are never defined as errors via status.isError
            
            if (status.category == PNStatusCategory.PNDisconnectedCategory) {
                // PNDisconnect happens as part of our regular operation
                // No need to monitor for this unless requested by support
                println("^^^^ Non-error status: Expected Disconnect, Channel Info: \(subscriberStatus.subscribedChannels)");
            }
                
            else if (status.category == PNStatusCategory.PNUnexpectedDisconnectCategory) {
                // PNUnexpectedDisconnect happens as part of our regular operation
                // This event happens when radio / connectivity is lost
                
                println("^^^^ Non-error status: Unexpected Disconnect, Channel Info: \(subscriberStatus.subscribedChannels)")
            }
                
            else if (status.category == PNStatusCategory.PNConnectedCategory) {
                
                // Connect event. You can do stuff like publish, and know you'll get it.
                // Or just use the connected event to confirm you are subscribed for UI / internal notifications, etc
                
                println("^^^^ Non-error status: Connected, Channel Info: \(subscriberStatus.subscribedChannels)");
                self.pubNubPublish()
                
            }
            else if (status.category == PNStatusCategory.PNReconnectedCategory) {
                
                // PNUnexpectedDisconnect happens as part of our regular operation
                // This event happens when radio / connectivity is lost
                
                println("^^^^ Non-error status: Reconnected, Channel Info: \(subscriberStatus.subscribedChannels)")
                
            }
            
        }
    }
    
    func handlePAMError(status : PNErrorStatus){
        // Access Denied via PAM. Access status.data to determine the resource in question that was denied.
        // In addition, you can also change auth key dynamically if needed."
        
        var pamResourceName: AnyObject = (status.errorData.channels != nil) ? status.errorData.channels[0] : status.errorData.channelGroups
        var pamResourceType = (status.errorData.channels != nil) ? "channel" : "channel-groups"
        // # ^
        
        
        println("PAM error on \(pamResourceType) \(pamResourceName)");
        
        // If its a PAM error on subscribe, lets grab the channel name in question, and unsubscribe from it, and re-subscribe to a channel that we're authed to
        
        if (status.operation   ==  PNOperationType.SubscribeOperation) {
            
            if (pamResourceType == "channel") {
                println("^^^^ Unsubscribing from \(pamResourceName)")
                self.reconfigOnPamError(status)
            }
                
            else {
                self.client?.unsubscribeFromChannelGroups(pamResourceName as! [AnyObject], withPresence: true)
                // the case where we're dealing with CGs instead of CHs... follows the same pattern as above
            }
            
        } else if (status.operation == PNOperationType.PublishOperation) {
            
            println("^^^^ Error publishing with authKey: \(authKey) to channel  \(pamResourceName)");
            println("^^^^ Setting auth to an authKey that will allow for both sub and pub");
            
            reconfigOnPamError(status)
        }
    }
    
    
    func reconfigOnPamError(status : PNErrorStatus){
        // If this is a subscribe PAM error
        
        if (status.operation == PNOperationType.SubscribeOperation) {
            
            var subscriberStatus : PNSubscribeStatus = status as! PNSubscribeStatus
            
            var currentChannels: NSArray = subscriberStatus.subscribedChannels;
            var currentChannelGroups: NSArray = subscriberStatus.subscribedChannelGroups;
            
            self.myConfig!.authKey = "myAuthKey"
            
            self.client?.copyWithConfiguration(myConfig, completion: { (client) -> Void in
                
            })
            
            
            //self.client = client
            
            self.client?.subscribeToChannels(currentChannels as [AnyObject], withPresence: false)
            self.client?.subscribeToChannelGroups(currentChannelGroups as [AnyObject], withPresence: false)
        }
    }
    
    
    func pubNubPublish(){
        self.client?.publish("Connected! I'm here!", toChannel: channel1 as! String, withCompletion: { (status) -> Void in
            if(!status.error){
                println("Message sent at TT: \(status.data.timetoken)")
            }
            else{
                self.handleStatus(status)
            }
        })
        
        /////^ # compressed
        
        /*
        [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
        [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> withCompletion:<#(PNPublishCompletionBlock)block#>];
        [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> storeInHistory:<#(BOOL)shouldStore#> withCompletion:<#(PNPublishCompletionBlock)block#>];
        [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> storeInHistory:<#(BOOL)shouldStore#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
        [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> withCompletion:<#(PNPublishCompletionBlock)block#>];
        [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
        [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> storeInHistory:<#(BOOL)shouldStore#> withCompletion:<#(PNPublishCompletionBlock)block#>];
        [self.client publish:<#(id)message#> toChannel:<#(NSString *)channel#> mobilePushPayload:<#(NSDictionary *)payloads#> storeInHistory:<#(BOOL)shouldStore#> compressed:<#(BOOL)compressed#> withCompletion:<#(PNPublishCompletionBlock)block#>];
        */
        
    }




    
    
//    func pubNubSetState(){
//        weak var weakSelf = self
//        self.client?.setState(["foo":"bar"] , forUUID: myConfig?.uuid, onChannel: channel1, withCompletion: { (status) -> Void in
//            var strongSelf = weakSelf
//            handleStatus(strongSelf.status)
//        })
//        //^#
//    }
    
    func updateClientConfiguration(){
        // Set PubNub Configuration
        self.myConfig?.TLSEnabled = false
        self.myConfig?.uuid = randomString() as String
        self.myConfig?.origin = "pubsub.pubnub.com"
        self.myConfig?.authKey = self.authKey as! String
        
        // Presence Settings
        self.myConfig?.presenceHeartbeatValue = 120;
        self.myConfig?.presenceHeartbeatInterval = 60;
        
        // Cipher Key Settings
        //self.client.cipherKey = @"enigma";
        
        // Time Token Handling Settings
        self.myConfig?.keepTimeTokenOnListChange = true
        self.myConfig?.restoreSubscription = true
        self.myConfig?.catchUpOnSubscriptionRestore = true
    }
    
    func randomString()->NSString{
        var random = arc4random_uniform(74)
        var formatted = NSString(format:"%d", random) as NSString
        return formatted
    }
    
    func printClientConfiguration(){
        // Get PubNub Options
        println("TLSEnabled: \(self.myConfig?.TLSEnabled) ")
        //^# yes or no
        println("Origin: \(self.myConfig!.origin)")
        println("authKey: \(self.myConfig!.authKey)")
        println("UUID: \(self.myConfig!.uuid)");
        
        // Time Token Handling Settings
        println("keepTimeTokenOnChannelChange: \(self.myConfig?.keepTimeTokenOnListChange)" )
        //#^ y/n
        println("resubscribeOnConnectionRestore: \(self.myConfig?.restoreSubscription)")
        //#^ y/n
        println("catchUpOnSubscriptionRestore: \(self.myConfig?.catchUpOnSubscriptionRestore)")
        
        // Get Presence Options
        println("Heartbeat value: \(self.myConfig!.presenceHeartbeatValue)")
        println("Heartbeat interval: \(self.myConfig!.presenceHeartbeatInterval)")
        
        // Get CipherKey
        println("Cipher key: \(self.myConfig!.cipherKey)")
    }
    



    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

