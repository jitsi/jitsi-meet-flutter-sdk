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
import org.jitsi.meet.sdk.JitsiMeetUserInfo
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
    val serverURL = if (call.argument<String?>("serverURL") != null) URL(call.argument<String?>("serverURL")) else null
    val room: String? = call.argument("room")
    val token: String? = call.argument("token")
    val featureFlags = call.argument<HashMap<String, Any?>>("featureFlags")
    val configOverrides = call.argument<HashMap<String, Any?>>("configOverrides")
    val rawUserInfo = call.argument<HashMap<String, String?>>("userInfo")
    val displayName = rawUserInfo?.get("displayName")
    val email = rawUserInfo?.get("email")
    val avatar = if (rawUserInfo?.get("avatar") != null) URL(rawUserInfo.get("avatar")) else null
    val userInfo = JitsiMeetUserInfo().apply {
      if (displayName != null) this.displayName = displayName
      if (email != null) this.email = email
      if (avatar != null) this.avatar = avatar
    }

    val options = JitsiMeetConferenceOptions.Builder().run {
      if (serverURL != null) setServerURL(serverURL)
      if (room != null) setRoom(room)
      if (token != null) setToken(token)

      configOverrides?.forEach { (key, value) ->
        when (value) {
          is Boolean -> setConfigOverride(key, value)
          is Int -> setConfigOverride(key, value)
          is Array<*> -> setConfigOverride(key, value as Array<out String>)
          else -> setConfigOverride(key, value.toString())
        }
      }
      featureFlags?.forEach { (key, value) ->
        when (value) {
          is Boolean -> setFeatureFlag(key, value)
          is Int -> setFeatureFlag(key, value)
          else -> setFeatureFlag(key, value.toString())
        }
      }
      if (userInfo != null) setUserInfo(userInfo)
      build()
    }

    WrapperJitsiMeetActivity.launch(activity!!, options)
    result.success("Successfully joined meeting")
  }
}
