package org.jitsi.jitsi_meet_flutter_sdk

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import org.jitsi.meet.sdk.BroadcastEvent
import org.jitsi.meet.sdk.JitsiMeetActivity
import android.app.KeyguardManager
import android.view.WindowManager
import android.os.Build
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions

class WrapperJitsiMeetActivity : JitsiMeetActivity() {
    private val eventStreamHandler = JitsiMeetEventStreamHandler.instance
    private val broadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            this@WrapperJitsiMeetActivity.onBroadcastReceived(intent)
        }
    }

    companion object {
        fun launch(context: Context, options: JitsiMeetConferenceOptions?) {
            val intent = Intent(context, WrapperJitsiMeetActivity::class.java)
            intent.action = "org.jitsi.meet.CONFERENCE"
            intent.putExtra("JitsiMeetConferenceOptions", options)
            if (context !is Activity) {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        showOnLockscreen()
        super.onCreate(savedInstanceState)
        registerForBroadcastMessages()
    }

    private fun showOnLockscreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    private fun registerForBroadcastMessages() {
        val intentFilter = IntentFilter()
        for (eventType in BroadcastEvent.Type.values()) {
            intentFilter.addAction(eventType.action)
        }
        LocalBroadcastManager.getInstance(this)
            .registerReceiver(this.broadcastReceiver, intentFilter)
    }

    private fun onBroadcastReceived(intent: Intent?) {
        if (intent != null) {
            val event = BroadcastEvent(intent)
            val data = event.data
            when (event.type!!) {
                BroadcastEvent.Type.CONFERENCE_JOINED -> eventStreamHandler.conferenceJoined(data)
                BroadcastEvent.Type.CONFERENCE_TERMINATED -> eventStreamHandler.conferenceTerminated(
                    data
                )

                BroadcastEvent.Type.CONFERENCE_WILL_JOIN -> eventStreamHandler.conferenceWillJoin(
                    data
                )

                BroadcastEvent.Type.PARTICIPANT_JOINED -> eventStreamHandler.participantJoined(data)
                BroadcastEvent.Type.PARTICIPANT_LEFT -> eventStreamHandler.participantLeft(data)
                BroadcastEvent.Type.AUDIO_MUTED_CHANGED -> eventStreamHandler.audioMutedChanged(data)
                BroadcastEvent.Type.VIDEO_MUTED_CHANGED -> eventStreamHandler.videoMutedChanged(data)
                BroadcastEvent.Type.ENDPOINT_TEXT_MESSAGE_RECEIVED -> eventStreamHandler.endpointTextMessageReceived(
                    data
                )

                BroadcastEvent.Type.SCREEN_SHARE_TOGGLED -> eventStreamHandler.screenShareToggled(
                    data
                )

                BroadcastEvent.Type.CHAT_MESSAGE_RECEIVED -> eventStreamHandler.chatMessageReceived(
                    data
                )

                BroadcastEvent.Type.CHAT_TOGGLED -> eventStreamHandler.chatToggled(data)
                BroadcastEvent.Type.PARTICIPANTS_INFO_RETRIEVED -> eventStreamHandler.participantsInfoRetrieved(
                    data
                )

                BroadcastEvent.Type.READY_TO_CLOSE -> eventStreamHandler.readyToClose()

                BroadcastEvent.Type.CUSTOM_OVERFLOW_MENU_BUTTON_PRESSED -> eventStreamHandler.customOverflowMenuButtonPressed(data)
                else -> {}
            }
        }
    }

    override fun onDestroy() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(this.broadcastReceiver)
        super.onDestroy()
    }
}
