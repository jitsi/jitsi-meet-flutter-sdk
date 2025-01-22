package org.jitsi.jitsi_meet_flutter_sdk

import android.app.Activity
import androidx.annotation.NonNull
import android.content.Intent
import android.os.Bundle
import androidx.localbroadcastmanager.content.LocalBroadcastManager

import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.jitsi.meet.sdk.BroadcastIntentHelper
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions
import org.jitsi.meet.sdk.JitsiMeetUserInfo
import org.jitsi.meet.sdk.BroadcastAction
import org.jitsi.meet.sdk.*
import java.net.URL

/** JitsiMeetPlugin */
class JitsiMeetPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var methodChannel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private val eventStreamHandler = JitsiMeetEventStreamHandler.instance
  private var activity: Activity? = null
  private lateinit var viewFactory: JitsiNativeViewFactory

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "jitsi_meet_flutter_sdk")
    methodChannel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "jitsi_meet_flutter_sdk_events")
    eventChannel.setStreamHandler(eventStreamHandler)


    viewFactory = JitsiNativeViewFactory()
    flutterPluginBinding.platformViewRegistry.registerViewFactory("JitsiNativeView", viewFactory)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {result.success("Android ${android.os.Build.VERSION.RELEASE}")}
      "hangUp" -> hangUp(call, result)
      "setAudioMuted" -> setAudioMuted(call, result)
      "setVideoMuted" -> setVideoMuted(call, result)
      "sendEndpointTextMessage" -> sendEndpointTextMessage(call, result)
      "toggleScreenShare" -> toggleScreenShare(call, result)
      "openChat" -> openChat(call, result)
      "sendChatMessage" -> sendChatMessage(call, result)
      "closeChat" -> closeChat(call, result)
      "retrieveParticipantsInfo" -> retrieveParticipantsInfo(call, result)
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

  private fun hangUp(call: MethodCall, result: Result) {
    val hangUpBroadcastIntent = BroadcastIntentHelper.buildHangUpIntent();
    LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(hangUpBroadcastIntent)
    result.success("Succesfullly hung up")
  }

  private fun setAudioMuted(call: MethodCall, result: Result) {
    val muted = call.argument<Boolean>("muted") ?: false
    val audioMuteBroadcastIntent: Intent = BroadcastIntentHelper.buildSetAudioMutedIntent(muted)
    LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(audioMuteBroadcastIntent)
    result.success("Successfully set audio $muted")
  }

  private fun setVideoMuted(call: MethodCall, result: Result) {
    val muted = call.argument<Boolean>("muted") ?: false
    val videoMuteBroadcastIntent: Intent = BroadcastIntentHelper.buildSetVideoMutedIntent(muted)
    LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(videoMuteBroadcastIntent)
    result.success("Successfully set video $muted")
  }

  private fun sendEndpointTextMessage(call: MethodCall, result: Result) {
    val to = call.argument<String?>("to")
    val message = call.argument<String>("message")
    val sendEndpointTextMessageBroadcastIntent: Intent = BroadcastIntentHelper.buildSendEndpointTextMessageIntent(to, message)
    LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(sendEndpointTextMessageBroadcastIntent)
    result.success("Successfully send endpoint text message $to")
  }

  private fun toggleScreenShare(call: MethodCall, result: Result) {
    val enabled = call.argument<Boolean>("enabled") ?: false
    val toggleScreenShareIntent: Intent = BroadcastIntentHelper.buildToggleScreenShareIntent(enabled)
    LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(toggleScreenShareIntent)
    result.success("Successfully toggled screen share $enabled")
  }

  private fun openChat(call: MethodCall, result: Result) {
    val to = call.argument<String?>("to")
    val openChatIntent: Intent = BroadcastIntentHelper.buildOpenChatIntent(to)
    LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(openChatIntent)
    result.success("Successfully opened chat $to")
  }

  private fun sendChatMessage(call: MethodCall, result: Result) {
    val to = call.argument<String?>("to")
    val message = call.argument<String>("message")
    val sendChatMessageIntent: Intent = BroadcastIntentHelper.buildSendChatMessageIntent(to, message)
    LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(sendChatMessageIntent)
    result.success("Successfully sent chat message $to")

  }

  private fun closeChat(call: MethodCall, result: Result) {
    val closeChatIntent: Intent = BroadcastIntentHelper.buildCloseChatIntent()
    LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(closeChatIntent)
    result.success("Successfully closed chat")
  }

  private fun retrieveParticipantsInfo(call: MethodCall, result: Result) {
    val retrieveParticipantsInfoIntent: Intent = Intent("org.jitsi.meet.RETRIEVE_PARTICIPANTS_INFO");
    LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(retrieveParticipantsInfoIntent)
    result.success("Successfully retrieved participants info")
  }

}
