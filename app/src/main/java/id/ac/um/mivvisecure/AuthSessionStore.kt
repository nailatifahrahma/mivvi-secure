package id.ac.um.mivvisecure

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** Stores the revocable bearer token encrypted with an Android Keystore key. */
object AuthSessionStore {
    private const val PREFS = "mivvi_auth_session"
    private const val KEY_ALIAS = "mivvi_auth_session_key"
    private const val TOKEN_CIPHER = "token_cipher"
    private const val TOKEN_IV = "token_iv"
    private const val SESSION_EXPIRES_AT = "session_expires_at"
    private const val USER_EMAIL = "user_email"
    private const val USER_NAME = "user_name"

    fun save(context: android.content.Context, session: AuthApiClient.Session) {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, getKey())
        val encrypted = cipher.doFinal(session.accessToken.toByteArray(Charsets.UTF_8))
        context.getSharedPreferences(PREFS, android.content.Context.MODE_PRIVATE).edit()
            .putString(TOKEN_CIPHER, Base64.encodeToString(encrypted, Base64.NO_WRAP))
            .putString(TOKEN_IV, Base64.encodeToString(cipher.iv, Base64.NO_WRAP))
            .putLong(SESSION_EXPIRES_AT, System.currentTimeMillis() + session.expiresIn * 1000L)
            .putString(USER_EMAIL, session.user.email)
            .putString(USER_NAME, session.user.name)
            .apply()
    }

    fun token(context: android.content.Context): String? {
        val prefs = context.getSharedPreferences(PREFS, android.content.Context.MODE_PRIVATE)
        if (prefs.getLong(SESSION_EXPIRES_AT, 0L) <= System.currentTimeMillis()) {
            clear(context)
            return null
        }
        val encryptedText = prefs.getString(TOKEN_CIPHER, null) ?: return null
        val ivText = prefs.getString(TOKEN_IV, null) ?: return null
        return try {
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(Cipher.DECRYPT_MODE, getKey(), GCMParameterSpec(128, Base64.decode(ivText, Base64.NO_WRAP)))
            String(cipher.doFinal(Base64.decode(encryptedText, Base64.NO_WRAP)), Charsets.UTF_8)
        } catch (_: Exception) {
            clear(context)
            null
        }
    }

    fun userEmail(context: android.content.Context): String? =
        context.getSharedPreferences(PREFS, android.content.Context.MODE_PRIVATE).getString(USER_EMAIL, null)

    fun userName(context: android.content.Context): String? =
        context.getSharedPreferences(PREFS, android.content.Context.MODE_PRIVATE).getString(USER_NAME, null)

    fun clear(context: android.content.Context) {
        context.getSharedPreferences(PREFS, android.content.Context.MODE_PRIVATE).edit().clear().apply()
    }

    private fun getKey(): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (keyStore.getKey(KEY_ALIAS, null) as? SecretKey)?.let { return it }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        generator.init(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            ).setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setRandomizedEncryptionRequired(true)
                .build()
        )
        return generator.generateKey()
    }
}
