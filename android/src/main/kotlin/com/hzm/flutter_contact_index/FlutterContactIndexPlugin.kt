package com.hzm.flutter_contact_index

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterContactIndexPlugin */
class FlutterContactIndexPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private var channel: FlutterContactIndexHostImpl? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = FlutterContactIndexHostImpl(flutterPluginBinding.applicationContext)
    FlutterContactIndexHostApi.setUp(flutterPluginBinding.binaryMessenger, channel)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    FlutterContactIndexHostApi.setUp(binding.binaryMessenger, null)
    channel?.cleanup()
    channel = null
  }
}
