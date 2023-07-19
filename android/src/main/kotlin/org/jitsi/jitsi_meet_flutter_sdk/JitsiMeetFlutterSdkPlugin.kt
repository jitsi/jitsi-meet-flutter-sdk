package org.jitsi.jitsi_meet_flutter_sdk

import android.app.Activity
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions
import java.net.URL

/** JitsiMeetFlutterSdkPlugin */
class JitsiMeetFlutterSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var methodChannel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private val eventStreamHandler = JitsiMeetEventStreamHandler.instance
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "jitsi_meet_flutter_sdk")
    methodChannel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "jitsi_meet_flutter_sdk_events")
    eventChannel.setStreamHandler(eventStreamHandler)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {result.success("Android ${android.os.Build.VERSION.RELEASE}")}
      "join" -> join(call, result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    this.activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }
  private fun join(call: MethodCall, result: Result) {
    val options = JitsiMeetConferenceOptions.Builder().run {
      setRoom("testgabigabi")
      setServerURL(URL("https://meet.jit.si/"))
      build()
    }

    WrapperJitsiMeetActivity.launch(activity!!, options)
    result.success("Successfully joined meeting")
  }
}
