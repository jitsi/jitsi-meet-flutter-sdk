package org.jitsi.jitsi_meet_flutter_sdk

import io.flutter.plugin.common.EventChannel
import java.io.Serializable

class JitsiMeetEventStreamHandler private constructor() : EventChannel.StreamHandler {
    companion object {
        val instance = JitsiMeetEventStreamHandler()
    }

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        this.eventSink = eventSink
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun onConferenceJoined(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "conferenceJoined", "data" to data))
    }

    fun onReadyToClose() {
        eventSink?.success(mapOf("event" to "readyToClose"))
    }

    fun onOpened() {
        eventSink?.success(mapOf("event" to "opened"))
    }

    fun onClosed() {
        eventSink?.success(mapOf("event" to "closed"))
    }
}