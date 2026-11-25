package id.ac.um.mivvisecure

import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

object ApiClient {
    data class SyncResult(val config: RuleConfig, val raw: JSONObject)

    /** Fetches rule configuration only. Message text and sender identifiers are never uploaded. */
    fun fetchRules(baseUrl: String): SyncResult {
        val normalized = baseUrl.trim().trimEnd('/')
        require(normalized.startsWith("http://") || normalized.startsWith("https://")) {
            "URL API harus diawali http:// atau https://"
        }
        require(BuildConfig.DEBUG || normalized.startsWith("https://", ignoreCase = true)) {
            "Build rilis hanya dapat terhubung ke API melalui HTTPS. Atur URL API HTTPS di Pengaturan."
        }
        val connection = (URL("$normalized/api/v1/rules").openConnection() as HttpURLConnection).apply {
            requestMethod = "GET"
            connectTimeout = 7000
            readTimeout = 7000
            setRequestProperty("Accept", "application/json")
        }
        try {
            val code = connection.responseCode
            val stream = if (code in 200..299) connection.inputStream else connection.errorStream
            val body = stream?.bufferedReader(Charsets.UTF_8)?.use { it.readText() }.orEmpty()
            if (code !in 200..299) throw IllegalStateException("API mengembalikan HTTP $code: ${body.take(240)}")
            val json = JSONObject(body)
            val config = RuleConfigStore.fromJson(json)
            return SyncResult(config, json)
        } finally {
            connection.disconnect()
        }
    }
}
