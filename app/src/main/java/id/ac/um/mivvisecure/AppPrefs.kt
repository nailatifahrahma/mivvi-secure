package id.ac.um.mivvisecure

import android.content.ComponentName
import android.content.Context
import android.provider.Settings

object AppPrefs {
    const val PREFS = "mivvi_settings"
    const val DEFAULT_API_URL = "http://10.0.2.2:8000"
    const val KEY_API_URL = "api_base_url"
    const val KEY_TRUSTED_SENDERS = "trusted_senders"
    const val KEY_INCLUDE_WHATSAPP = "include_whatsapp"
    const val KEY_INCLUDE_SMS = "include_sms"

    fun defaultApiBaseUrl(): String = if (BuildConfig.DEBUG) DEFAULT_API_URL else BuildConfig.RELEASE_API_BASE_URL.trimEnd('/')

    fun apiBaseUrl(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val saved = prefs.getString(KEY_API_URL, null)?.trim()?.trimEnd('/').orEmpty()
        if (saved.isBlank()) return defaultApiBaseUrl()

        // Older Android emulator builds saved host loopback, which points back to the emulator.
        if (BuildConfig.DEBUG && (saved.equals("http://127.0.0.1:8000", ignoreCase = true) ||
            saved.equals("http://localhost:8000", ignoreCase = true)
        )) {
            prefs.edit().putString(KEY_API_URL, DEFAULT_API_URL).apply()
            return DEFAULT_API_URL
        }
        return saved
    }

    fun trustedSenders(context: Context): Set<String> = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        .getString(KEY_TRUSTED_SENDERS, "").orEmpty()
        .lineSequence().map { it.trim() }.filter { it.isNotBlank() }.toSet()

    fun notificationAccessEnabled(context: Context): Boolean {
        val raw = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners") ?: return false
        return raw.split(":").any { flat -> ComponentName.unflattenFromString(flat)?.packageName == context.packageName }
    }

    fun includeWhatsApp(context: Context): Boolean = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        .getBoolean(KEY_INCLUDE_WHATSAPP, true)
    fun includeSms(context: Context): Boolean = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        .getBoolean(KEY_INCLUDE_SMS, true)
}
