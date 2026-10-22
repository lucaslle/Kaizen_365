package fr.kaizen365.kaizen365

import android.app.PendingIntent
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetLaunchIntent

/** Shared helpers for the home screen widgets. The app writes every text through home_widget. */
object WidgetViews {
    fun openApp(context: Context): PendingIntent =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)

    fun openCheckin(context: Context): PendingIntent =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("kaizen365://checkin"))

    fun text(data: SharedPreferences, key: String, fallback: String = ""): String =
        data.getString(key, fallback) ?: fallback

    /** Status colors readable on the dark widget background. */
    fun statusColor(status: String): Int = when (status) {
        "done" -> Color.parseColor("#FFFCF6")
        "onTrack" -> Color.parseColor("#8FD1A5")
        "atRisk" -> Color.parseColor("#E8C27A")
        else -> Color.parseColor("#F0A08F")
    }
}
