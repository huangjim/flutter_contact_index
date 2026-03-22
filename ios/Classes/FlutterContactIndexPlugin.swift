import Flutter
import UIKit

public class FlutterContactIndexPlugin: NSObject, FlutterPlugin {
    
    private static var api: FlutterContactIndexHostImpl? = nil
    public static func register(with registrar: FlutterPluginRegistrar) {
        api = FlutterContactIndexHostImpl()
        FlutterContactIndexHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(),
            api: api
        )
    }
    
    public static func unregister(with registrar: FlutterPluginRegistrar) {
        // 注销 FlutterContactIndexHostApiSetup 实例，传入 nil 会清除消息处理程序
        FlutterContactIndexHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(),
            api: nil
        )
        api = nil
    }
}
