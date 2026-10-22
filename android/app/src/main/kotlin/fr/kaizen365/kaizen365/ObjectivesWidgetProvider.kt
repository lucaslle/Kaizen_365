package fr.kaizen365.kaizen365

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** Objectives widget (4×4): up to five objectives with their progress and status. */
class ObjectivesWidgetProvider : HomeWidgetProvider() {
    private val rows = listOf(
        Row(R.id.objective_row_0, R.id.objective_title_0, R.id.objective_status_0, R.id.objective_pct_0, R.id.objective_bar_0),
        Row(R.id.objective_row_1, R.id.objective_title_1, R.id.objective_status_1, R.id.objective_pct_1, R.id.objective_bar_1),
        Row(R.id.objective_row_2, R.id.objective_title_2, R.id.objective_status_2, R.id.objective_pct_2, R.id.objective_bar_2),
        Row(R.id.objective_row_3, R.id.objective_title_3, R.id.objective_status_3, R.id.objective_pct_3, R.id.objective_bar_3),
        Row(R.id.objective_row_4, R.id.objective_title_4, R.id.objective_status_4, R.id.objective_pct_4, R.id.objective_bar_4),
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val count = widgetData.getInt("objectiveCount", 0)
        val views = RemoteViews(context.packageName, R.layout.objectives_widget).apply {
            setTextViewText(R.id.objectives_year, WidgetViews.text(widgetData, "year", "Kaizen 365"))
            setTextViewText(R.id.objectives_score, WidgetViews.text(widgetData, "score", "–"))
            setTextViewText(R.id.objectives_empty, WidgetViews.text(widgetData, "emptyObjectives"))
            setViewVisibility(R.id.objectives_empty, if (count == 0) View.VISIBLE else View.GONE)
            rows.forEachIndexed { i, row ->
                setViewVisibility(row.container, if (i < count) View.VISIBLE else View.GONE)
                if (i < count) {
                    val status = WidgetViews.text(widgetData, "objective${i}Status")
                    setTextViewText(row.title, WidgetViews.text(widgetData, "objective${i}Title"))
                    setTextViewText(row.status, WidgetViews.text(widgetData, "objective${i}StatusLabel"))
                    setTextColor(row.status, WidgetViews.statusColor(status))
                    setTextViewText(row.percent, WidgetViews.text(widgetData, "objective${i}Percent"))
                    setProgressBar(row.bar, 100, widgetData.getInt("objective${i}Progress", 0), false)
                }
            }
            setOnClickPendingIntent(R.id.objectives_root, WidgetViews.openApp(context))
        }
        appWidgetIds.forEach { appWidgetManager.updateAppWidget(it, views) }
    }

    private data class Row(val container: Int, val title: Int, val status: Int, val percent: Int, val bar: Int)
}
