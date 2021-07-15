#import "ViewmodelPlugin.h"
#if __has_include(<viewmodel/viewmodel-Swift.h>)
#import <viewmodel/viewmodel-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "viewmodel-Swift.h"
#endif

@implementation ViewmodelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftViewmodelPlugin registerWithRegistrar:registrar];
}
@end
