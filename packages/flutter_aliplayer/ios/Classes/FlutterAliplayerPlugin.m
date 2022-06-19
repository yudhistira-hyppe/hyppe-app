#import "FlutterAliplayerPlugin.h"
#import "AliPlayerFactory.h"
#import "FlutterAliDownloaderPlugin.h"

@implementation FlutterAliplayerPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    AliPlayerFactory* factory =
    [[AliPlayerFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:factory withId:@"plugins.flutter_aliplayer"];
   
    [FlutterAliDownloaderPlugin registerWithRegistrar:registrar];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
