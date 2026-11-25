package id.ac.um.mivvisecure

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/** Reads only notifications from supported SMS/WhatsApp packages after the user grants Android access. */
class NotificationMonitorService : NotificationListenerService() {
    private val whatsappPackages = setOf("com.whatsapp", "com.whatsapp.w4b")
    private val smsPackages = setOf(
        "com.google.android.apps.messaging",
        "com.samsung.android.messaging",
        "com.android.mms",
        "com.android.messaging",
        "com.miui.mms",
        "com.coloros.mms",
        "com.oppo.messaging",
        "com.oneplus.mms",
        "com.motorola.messaging"
    )

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if ((sbn.notification.flags and Notification.FLAG_GROUP_SUMMARY) != 0) return
        val pkg = sbn.packageName ?: return
        val isWhatsapp = pkg in whatsappPackages
        val isSms = pkg in smsPackages
        if (!isWhatsapp && !isSms) return
        if (isWhatsapp && !AppPrefs.includeWhatsApp(this)) return
        if (isSms && !AppPrefs.includeSms(this)) return

        val extras = sbn.notification.extras
        val title = extras?.getCharSequence(Notification.EXTRA_TITLE)?.toString()?.trim().orEmpty()
        val subText = extras?.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()?.trim().orEmpty()
        val bigText = extras?.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()?.trim().orEmpty()
        val text = extras?.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.trim().orEmpty()
        val messagingStyle = Notification.Builder.recoverBuilder(this, sbn.notification).style
            as? Notification.MessagingStyle
        val latestMessage = messagingStyle?.messages?.lastOrNull()
        var body = when {
            latestMessage?.text?.isNotBlank() == true -> latestMessage.text.toString().trim()
            bigText.isNotBlank() -> bigText
            text.isNotBlank() -> text
            else -> ""
        }
        // Avoid classifying notification summaries such as "2 new messages" as the actual message body.
        if (Regex("(?i)^\\d+\\s+(new messages?|pesan baru)$").matches(body.trim())) body = ""
        val genericTitles = setOf("whatsapp", "whatsapp business", "messages", "google messages", "samsung messages")
        val styleSender = latestMessage?.sender?.toString()?.trim().orEmpty()
        val sender = when {
            styleSender.isNotBlank() -> styleSender
            title.isNotBlank() && title.lowercase() !in genericTitles -> title
            subText.isNotBlank() -> subText
            else -> ""
        }
        val source = if (isWhatsapp) "WHATSAPP" else "SMS"
        val analysis = if (body.isNotBlank()) RuleBasedAnalyzer(RuleConfigStore.load(this))
            .analyze(body, sender, AppPrefs.trustedSenders(this)) else null

        // Notification previews may be hidden by Android or by the source app's privacy settings.
        // In that case a metadata-only history entry is saved; no content is fabricated.
        try {
            LocalDatabase(this).use { db ->
                db.insert(source, sender, body, sbn.postTime, analysis, false, pkg)
            }
        } catch (_: Exception) {
            // A notification listener must not crash the source app if local persistence fails.
        }
    }
}
