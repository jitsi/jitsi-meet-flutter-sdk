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
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions

class WrapperJitsiMeetActivity : JitsiMeetActivity(), View.OnClickListener {
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
        initListeners()
        val jitsiLayout = findViewById<View>(R.id.jitsi_layout)
        ViewCompat.setOnApplyWindowInsetsListener(jitsiLayout) { view, insets ->
            applyInsets(view, insets)
        }
    }

    private fun initListeners() {
        findViewById<View>(R.id.getTopic).setOnClickListener(this)
        findViewById<View>(R.id.changeRoom).setOnClickListener(this)
        findViewById<View>(R.id.saveResults).setOnClickListener(this)
        findViewById<View>(R.id.bottomView).setOnClickListener(this)
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
        intentFilter.addAction("org.jitsi.meet.ENTER_PICTURE_IN_PICTURE")
        LocalBroadcastManager.getInstance(this)
            .registerReceiver(this.broadcastReceiver, intentFilter)
    }

    private fun onBroadcastReceived(intent: Intent?) {
        if (intent != null) {
            if (intent.action == "org.jitsi.meet.ENTER_PICTURE_IN_PICTURE") {
                enterPiP()
            } else {
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
    }

    override fun onDestroy() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(this.broadcastReceiver)
        super.onDestroy()
    }

    fun enterPiP() {
        jitsiView?.enterPictureInPicture()
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.getTopic -> {
                eventStreamHandler.handleGetTopicButtonTap()
            }
            R.id.changeRoom -> {
                eventStreamHandler.handleChangeRoomViewTap()
            }
            R.id.saveResults -> {
                eventStreamHandler.handleSaveResultsViewTap()
            }
            R.id.bottomView -> {
                eventStreamHandler.handleBottomViewTap()
            }
        }
    }

    private fun applyInsets(view: View, windowInsets: WindowInsetsCompat): WindowInsetsCompat {
        val insetTypeMask = systemBarsAndDisplayCutout()

        val insets = windowInsets.getInsets(insetTypeMask)

        view.updatePadding(bottom = insets.bottom)

        findViewById<View>(R.id.topGap).layoutParams.height = insets.top

        return WindowInsetsCompat.Builder()
            .setInsets(insetTypeMask, insets)
            .build()
    }

    private fun systemBarsAndDisplayCutout(): Int {
        return WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout()
    }
}
