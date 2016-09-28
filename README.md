# iOS_WatchProjects


###watchOS2

####Health Watch Example:
    App that gets heart beat from apple watch, can also stream data to iphone (obtained from HealthKit- NOT directly from sensor)
 
####Application Context:
    example of background mode communication process, application context. 

####Interactive Messaging:
    example of (Live Messaging) Interactive Messaging occurs between iphone and watch


####time Notification:
    example of notification process in apple watch

####Prime Numbers:
    App that gets heart beat from apple watch, can also stream data to iphone (obtained from HealthKit- NOT directly from sensor)


** Apple Watch Notes **
-Live Messaging (Interactive Messaging)
***When the watch session is init and started on app delegate:***
[Message from Watch to Phone]
(the phone has the app in the background) 
The Apple Watch is able to send message to phone

[Message from Phone to Watch]
(the watch does NOT have the watch app open)
The phone will recognize this - error sending message.


###watchOS3


#####App Launching


#####HealthKitWorkout
Make sure to update the plist with health kit share and update descriptions:

<key>NSHealthUpdateUsageDescription</key>
<string>testing health kit</string>
<key>NSHealthShareUsageDescription</key>
<string>testing health kit</string>



#####Heart Rate Streaming


###Apple Watch Interface Controller Lifecycle
awake(withContext context: Any?) // context from controller that did push or modal presentation. default does nothing

willActivate() // Called when watch interface is active and able to be updated. Can be called when interface is not visible.

didDeactivate() // Called when watch interface is no longer active and cannot be updated.

didAppear() // Called when watch interface is visible to user

willDisappear() // Called when watch interface is about to no longer be visible


###Xcode Issues
Problem: (No Paired Apple Watch)
Solution: Cloxe Xcode and remove directories inside the path ~/Library/Developer/Xcode/watchOS DeviceSupport/




