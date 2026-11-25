package id.ac.um.mivvisecure

import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

object AuthApiClient {
    data class Account(val id: Long, val name: String, val email: String)
    data class Session(val accessToken: String, val expiresIn: Long, val user: Account)
    data class VerificationChallenge(val email: String, val expiresIn: Long)

    fun login(baseUrl: String, email: String, password: String): Session =
        sessionRequest(baseUrl, "/api/v1/auth/login", JSONObject().put("email", email).put("password", password))

    fun register(baseUrl: String, name: String, email: String, password: String): VerificationChallenge {
        val json = request(
            baseUrl,
            "/api/v1/auth/register",
            "POST",
            JSONObject().put("name", name).put("email", email).put("password", password)
        )
        return VerificationChallenge(json.getString("email"), json.optLong("expires_in", 0))
    }

    fun verifyEmail(baseUrl: String, email: String, code: String): Session =
        sessionRequest(
            baseUrl,
            "/api/v1/auth/verify-email",
            JSONObject().put("email", email).put("code", code)
        )

    fun resendVerification(baseUrl: String, email: String) {
        request(baseUrl, "/api/v1/auth/resend-verification", "POST", JSONObject().put("email", email))
    }

    fun requestPasswordReset(baseUrl: String, email: String) {
        request(baseUrl, "/api/v1/auth/password-reset/request", "POST", JSONObject().put("email", email))
    }

    fun confirmPasswordReset(baseUrl: String, email: String, code: String, newPassword: String) {
        request(
            baseUrl,
            "/api/v1/auth/password-reset/confirm",
            "POST",
            JSONObject().put("email", email).put("code", code).put("new_password", newPassword)
        )
    }

    fun logout(baseUrl: String, token: String) {
        request(baseUrl, "/api/v1/auth/logout", "POST", JSONObject(), token)
    }

    private fun sessionRequest(baseUrl: String, path: String, payload: JSONObject): Session {
        val json = request(baseUrl, path, "POST", payload)
        val user = json.getJSONObject("user")
        return Session(
            accessToken = json.getString("access_token"),
            expiresIn = json.optLong("expires_in", 0),
            user = Account(user.getLong("id"), user.getString("name"), user.getString("email"))
        )
    }

    private fun request(
        baseUrl: String,
        path: String,
        method: String,
        payload: JSONObject,
        bearerToken: String? = null
    ): JSONObject {
        val normalized = baseUrl.trim().trimEnd('/')
        require(normalized.startsWith("http://") || normalized.startsWith("https://")) {
            "Base URL API harus diawali http:// atau https://"
        }
        require(BuildConfig.DEBUG || normalized.startsWith("https://", ignoreCase = true)) {
            "Build rilis hanya dapat mengirim data akun melalui HTTPS. Atur URL API HTTPS di Pengaturan."
        }
        val connection = (URL(normalized + path).openConnection() as HttpURLConnection).apply {
            requestMethod = method
            connectTimeout = 10000
            readTimeout = 10000
            setRequestProperty("Accept", "application/json")
            if (bearerToken != null) setRequestProperty("Authorization", "Bearer $bearerToken")
            if (method == "POST") {
                doOutput = true
                setRequestProperty("Content-Type", "application/json; charset=utf-8")
            }
        }
        try {
            if (method == "POST") connection.outputStream.use { it.write(payload.toString().toByteArray(Charsets.UTF_8)) }
            val status = connection.responseCode
            val stream = if (status in 200..299) connection.inputStream else connection.errorStream
            val body = stream?.bufferedReader(Charsets.UTF_8)?.use { it.readText() }.orEmpty()
            if (status !in 200..299) {
                val message = try {
                    val detail = JSONObject(body).opt("detail")
                    when (detail) {
                        is String -> detail
                        null -> "API mengembalikan HTTP $status"
                        else -> detail.toString()
                    }
                } catch (_: Exception) {
                    "API mengembalikan HTTP $status"
                }
                throw IllegalStateException(message)
            }
            return JSONObject(body)
        } finally {
            connection.disconnect()
        }
    }
}
