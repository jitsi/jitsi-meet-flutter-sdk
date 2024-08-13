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

    fun conferenceJoined(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "conferenceJoined", "data" to data))
    }

    fun conferenceTerminated(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "conferenceTerminated", "data" to data))
    }

    fun conferenceWillJoin(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "conferenceWillJoin", "data" to data))
    }

    fun participantJoined(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "participantJoined", "data" to data))
    }

    fun participantLeft(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "participantLeft", "data" to data))
    }

    fun audioMutedChanged(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "audioMutedChanged", "data" to data))
    }

    fun videoMutedChanged(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "videoMutedChanged", "data" to data))
    }

    fun endpointTextMessageReceived(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "endpointTextMessageReceived", "data" to data))
    }

    fun screenShareToggled(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "screenShareToggled", "data" to data))
    }

    fun chatMessageReceived(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "chatMessageReceived", "data" to data))
    }

    fun chatToggled(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "chatToggled", "data" to data))
    }

    fun participantsInfoRetrieved(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "participantsInfoRetrieved", "data" to data))
    }

    fun readyToClose() {
        eventSink?.success(mapOf("event" to "readyToClose"))
    }

    fun onOpened() {
        eventSink?.success(mapOf("event" to "opened"))
    }

    fun customOverflowMenuButtonPressed(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "customOverflowMenuButtonPressed", "data" to data))
    }
}
