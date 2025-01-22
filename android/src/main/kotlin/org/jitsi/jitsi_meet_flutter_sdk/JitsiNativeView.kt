package org.jitsi.jitsi_meet_flutter_sdk

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.view.View
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.plugin.platform.PlatformView
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions
import org.jitsi.meet.sdk.JitsiMeetUserInfo
import org.jitsi.meet.sdk.JitsiMeetView
import org.jitsi.meet.sdk.BroadcastEvent
import java.net.URL

class JitsiNativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    private val jitsiMeetView: JitsiMeetView
    private val eventStreamHandler = JitsiMeetEventStreamHandler.instance
    private val broadcastReceiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent?.let { onBroadcastReceived(it) }
        }
    }

    private val applicationContext: Context = context.applicationContext

    override fun getView(): View {
        return jitsiMeetView
    }

    override fun dispose() {
        jitsiMeetView.dispose()
        LocalBroadcastManager.getInstance(applicationContext).unregisterReceiver(this.broadcastReceiver)
    }

    init {
        jitsiMeetView = JitsiMeetView(context)
        registerForBroadcastMessages()
        val params = creationParams as Map<String, Any>
        val roomUrl = params["roomUrl"] as String
        val options = this.fromUrl(roomUrl)
        jitsiMeetView.join(options)
    }

    private fun registerForBroadcastMessages() {
        val intentFilter = IntentFilter()
        for (eventType in BroadcastEvent.Type.values()) {
            intentFilter.addAction(eventType.action)
        }
        LocalBroadcastManager.getInstance(applicationContext).registerReceiver(broadcastReceiver, intentFilter)
    }
    private fun onBroadcastReceived(intent: Intent?) {
        if (intent != null) {
            val event = BroadcastEvent(intent)
            val data = event.data
            when (event.type.action!!) {
                BroadcastEvent.Type.CONFERENCE_JOINED.action -> eventStreamHandler.conferenceJoined(data)
                BroadcastEvent.Type.CONFERENCE_TERMINATED.action -> eventStreamHandler.conferenceTerminated(
                    data
                )

                BroadcastEvent.Type.CONFERENCE_WILL_JOIN.action -> eventStreamHandler.conferenceWillJoin(
                    data
                )

                BroadcastEvent.Type.PARTICIPANT_JOINED.action -> eventStreamHandler.participantJoined(data)
                BroadcastEvent.Type.PARTICIPANT_LEFT.action -> eventStreamHandler.participantLeft(data)
                BroadcastEvent.Type.AUDIO_MUTED_CHANGED.action -> eventStreamHandler.audioMutedChanged(data)
                BroadcastEvent.Type.VIDEO_MUTED_CHANGED.action -> eventStreamHandler.videoMutedChanged(data)
                BroadcastEvent.Type.ENDPOINT_TEXT_MESSAGE_RECEIVED.action -> eventStreamHandler.endpointTextMessageReceived(
                    data
                )

                BroadcastEvent.Type.SCREEN_SHARE_TOGGLED.action -> eventStreamHandler.screenShareToggled(
                    data
                )

                BroadcastEvent.Type.CHAT_MESSAGE_RECEIVED.action -> eventStreamHandler.chatMessageReceived(
                    data
                )

                BroadcastEvent.Type.CHAT_TOGGLED.action -> eventStreamHandler.chatToggled(data)
                BroadcastEvent.Type.PARTICIPANTS_INFO_RETRIEVED.action -> eventStreamHandler.participantsInfoRetrieved(
                    data
                )

                BroadcastEvent.Type.READY_TO_CLOSE.action -> eventStreamHandler.readyToClose()

                BroadcastEvent.Type.CUSTOM_OVERFLOW_MENU_BUTTON_PRESSED.action -> eventStreamHandler.customOverflowMenuButtonPressed(
                    data
                )

                else -> {}
            }
        }
    }

    private fun fromUrl(urlString: String): JitsiMeetConferenceOptions {
        val uri = Uri.parse(urlString)
        val domain = uri.host ?: throw IllegalArgumentException("Invalid URL: No host found")
        val roomName = uri.lastPathSegment ?: throw IllegalArgumentException("Invalid URL: No room name found")

        val builder = JitsiMeetConferenceOptions.Builder()
            .setRoom(roomName)
            .setServerURL(URL("https://$domain"))

        uri.queryParameterNames.forEach { key ->
            val value = uri.getQueryParameter(key) ?: return@forEach

            when {
                key.startsWith("userInfo.") -> {
                    val userInfo = JitsiMeetUserInfo()
                    when (key) {
                        "userInfo.displayName" -> userInfo.displayName = value
                        "userInfo.email" -> userInfo.email = value
                        "userInfo.avatar" -> userInfo.avatar = URL(value)
                    }
                    builder.setUserInfo(userInfo)
                }
                key.startsWith("config.") -> {
                    when (key) {
                        "config.startWithAudioMuted" -> builder.setConfigOverride("startWithAudioMuted", value.toBoolean())
                        "config.startWithVideoMuted" -> builder.setConfigOverride("startWithVideoMuted", value.toBoolean())
                        "config.disableInitialGUM" -> builder.setConfigOverride("disableInitialGUM", value.toBoolean())
                        "config.toolbarButtons" -> {
                            // Преобразуем List<String> в Array<String>
                            val buttons = value.split(",").map { it.trim() }.toTypedArray()
                            builder.setConfigOverride("toolbarButtons", buttons)
                        }
                    }
                }
                key.startsWith("featureFlags.") -> {
                    builder.setFeatureFlag(key.removePrefix("featureFlags."), value.toBoolean())
                }
                else -> {}
            }
        }

        return builder.build()
    }
}