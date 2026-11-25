package id.ac.um.mivvisecure

import android.app.Activity
import android.app.AlertDialog
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.text.method.PasswordTransformationMethod
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.HorizontalScrollView
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : Activity() {
    private val cosmic = Color.rgb(8, 10, 24)
    private val navy = Color.rgb(16, 22, 45)
    private val cardColor = Color.rgb(26, 33, 70)
    private val violet = Color.rgb(104, 82, 232)
    private val cyan = Color.rgb(99, 221, 232)
    private val pearl = Color.rgb(245, 245, 252)
    private val muted = Color.rgb(168, 176, 200)
    private val green = Color.rgb(45, 212, 191)
    private val amber = Color.rgb(245, 158, 11)
    private val red = Color.rgb(244, 63, 94)

    private var currentPage = "welcome"
    private var simulatedNotificationAccess = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.statusBarColor = cosmic
        window.navigationBarColor = cosmic
        if (AuthSessionStore.token(this) != null) showHome() else showWelcome()
    }

    override fun onResume() {
        super.onResume()
        if (currentPage == "home") showHome()
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    private fun pageWidth(): Int {
        val availableWidth = (resources.configuration.screenWidthDp * resources.displayMetrics.density).toInt()
        return minOf(availableWidth, dp(720))
    }

    private fun pagePadding(widthDp: Int = resources.configuration.screenWidthDp): Int = when {
        widthDp < 360 -> dp(16)
        widthDp >= 700 -> dp(28)
        else -> dp(20)
    }

    private fun gradientBackground(): GradientDrawable = GradientDrawable(
        GradientDrawable.Orientation.TL_BR, intArrayOf(cosmic, navy, Color.rgb(22, 25, 62))
    )

    private fun createPage(title: String, subtitle: String? = null, showNav: Boolean = true): LinearLayout {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            background = gradientBackground()
        }
        if (Build.VERSION.SDK_INT >= 35) {
            root.setOnApplyWindowInsetsListener { view, insets ->
                val bars = insets.getInsets(WindowInsets.Type.systemBars())
                view.setPadding(0, bars.top, 0, bars.bottom)
                insets
            }
        }
        val top = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pagePadding(), dp(12), pagePadding(), dp(8))
            setBackgroundColor(cosmic)
        }
        val brandRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }
        val brand = TextView(this).apply {
            text = "✦  MIVVI SECURE"
            setTextColor(cyan)
            textSize = 12f
            letterSpacing = 0.12f
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
        }
        brandRow.addView(brand)

        val telemetryTag = TextView(this).apply {
            text = "  // LOCAL V2.4"
            setTextColor(muted)
            textSize = if (resources.configuration.screenWidthDp < 360) 9f else 10f
            typeface = Typeface.MONOSPACE
            maxLines = 1
        }
        if (resources.configuration.screenWidthDp < 360) telemetryTag.visibility = View.GONE
        brandRow.addView(telemetryTag)

        brandRow.addView(View(this), LinearLayout.LayoutParams(0, dp(1), 1f))
        val accountIcon = TextView(this).apply {
            text = "👤"
            contentDescription = "Akun pribadi"
            textSize = 18f
            gravity = Gravity.CENTER
            isClickable = true
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(cardColor)
                setStroke(dp(1), Color.argb(120, 99, 221, 232))
            }
            setOnClickListener {
                if (AuthSessionStore.token(this@MainActivity) != null) showAccount()
                else showLogin()
            }
        }
        brandRow.addView(accountIcon, LinearLayout.LayoutParams(dp(40), dp(40)))
        top.addView(brandRow, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))

        root.addView(top, LinearLayout.LayoutParams(pageWidth(), ViewGroup.LayoutParams.WRAP_CONTENT))
        root.addView(View(this).apply {
            setBackgroundColor(Color.argb(90, 99, 221, 232))
        }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(1)))

        currentPage = when (title) {
            "Beranda" -> "home"
            "Akun Pribadi" -> "account"
            "Analisis Manual" -> "manual"
            "Aktivitas Notifikasi" -> "activities"
            "Riwayat Analisis" -> "history"
            "Edukasi Keamanan" -> "education"
            "Pengaturan" -> "settings"
            else -> currentPage
        }

        val scroll = ScrollView(this).apply {
            isFillViewport = true
            clipToPadding = false
            isVerticalScrollBarEnabled = false
        }
        val content = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pagePadding(), dp(4), pagePadding(), dp(28))
        }
        if (title.isNotBlank()) {
            text(
                content,
                title,
                if (resources.configuration.screenWidthDp >= 700) 27f else 23f,
                pearl,
                bold = true,
                top = 6,
                bottom = if (subtitle.isNullOrBlank()) 12 else 2
            ).maxLines = 3
        }
        if (!subtitle.isNullOrBlank()) {
            text(content, subtitle, 13f, muted, bottom = 12).maxLines = 4
        }
        scroll.addView(content, FrameLayout.LayoutParams(pageWidth(), ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER_HORIZONTAL))
        root.addView(scroll, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        if (showNav) root.addView(buildBottomNav())
        root.addOnLayoutChangeListener { _, left, _, right, _, _, _, _, _ ->
            val availableWidth = right - left
            if (availableWidth > 0) {
                val boundedWidth = minOf(availableWidth, dp(720))
                if (top.layoutParams.width != boundedWidth) {
                    top.layoutParams = top.layoutParams.apply { width = boundedWidth }
                }
                if (content.layoutParams.width != boundedWidth) {
                    content.layoutParams = content.layoutParams.apply { width = boundedWidth }
                }
                val horizontalPadding = pagePadding((availableWidth / resources.displayMetrics.density).toInt())
                if (content.paddingLeft != horizontalPadding) {
                    content.setPadding(horizontalPadding, dp(4), horizontalPadding, dp(28))
                }
            }
        }
        setContentView(root)
        return content
    }

    private fun buildBottomNav(): View {
        val bar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            setPadding(dp(4), dp(8), dp(4), dp(8))
            setBackgroundColor(Color.rgb(10, 14, 32))
        }
        val navItems = listOf(
            Triple("Beranda", "home", "🏠"),
            Triple("Aktivitas", "activities", "🔔"),
            Triple("Riwayat", "history", "📋"),
            Triple("Edukasi", "education", "🛡️"),
            Triple("Pengaturan", "settings", "⚙️")
        )
        navItems.forEach { (label, key, icon) ->
            val b = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setPadding(dp(2), dp(4), dp(2), dp(4))
                val isCurrent = currentPage == key
                val iconView = TextView(this@MainActivity).apply {
                    text = icon
                    textSize = 14f
                    gravity = Gravity.CENTER
                }
                val labelView = TextView(this@MainActivity).apply {
                    text = label
                    textSize = if (resources.configuration.screenWidthDp < 360) 8.5f else 10f
                    setAutoSizeTextTypeUniformWithConfiguration(8, 10, 1, TypedValue.COMPLEX_UNIT_SP)
                    gravity = Gravity.CENTER
                    setTextColor(if (isCurrent) cyan else muted)
                    typeface = Typeface.create("sans-serif", if (isCurrent) Typeface.BOLD else Typeface.NORMAL)
                    maxLines = 1
                    includeFontPadding = false
                }
                contentDescription = label
                addView(iconView)
                addView(labelView)
                setOnClickListener {
                    when (key) {
                        "home" -> showHome()
                        "activities" -> showActivities()
                        "history" -> showHistory()
                        "education" -> showEducation()
                        else -> showSettings()
                    }
                }
            }
            bar.addView(b, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        }
        return bar
    }

    private fun text(parent: LinearLayout, value: String, size: Float = 14f, color: Int = pearl,
                     bold: Boolean = false, top: Int = 0, bottom: Int = 6): TextView {
        val view = TextView(this).apply {
            text = value
            textSize = size
            setTextColor(color)
            typeface = Typeface.create(if (bold) "sans-serif-medium" else "sans-serif", if (bold) Typeface.BOLD else Typeface.NORMAL)
            setPadding(0, dp(top), 0, dp(bottom))
        }
        parent.addView(view)
        return view
    }

    private fun card(parent: LinearLayout, title: String? = null, description: String? = null,
                     borderColor: Int = Color.argb(70, 150, 160, 210)): LinearLayout {
        val box = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16), dp(14), dp(16), dp(14))
            background = GradientDrawable().apply {
                setColor(cardColor)
                cornerRadius = dp(16).toFloat()
                setStroke(dp(1), borderColor)
            }
        }
        val lp = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        lp.bottomMargin = dp(12)
        parent.addView(box, lp)
        if (title != null) text(box, title, 15f, pearl, true, bottom = 4)
        if (description != null) text(box, description, 12.5f, muted, bottom = 0)
        return box
    }

    private fun action(parent: LinearLayout, label: String, onClick: () -> Unit, primary: Boolean = true, danger: Boolean = false): Button {
        val b = Button(this).apply {
            text = label
            isAllCaps = false
            textSize = if (resources.configuration.screenWidthDp < 360) 13f else 14f
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            maxLines = 2
            gravity = Gravity.CENTER
            setTextColor(when {
                primary -> cosmic
                danger -> red
                else -> pearl
            })
            background = GradientDrawable().apply {
                when {
                    primary -> setColor(cyan)
                    danger -> {
                        setColor(Color.argb(40, 244, 63, 94))
                        setStroke(dp(1), Color.argb(120, 244, 63, 94))
                    }
                    else -> {
                        setColor(Color.rgb(38, 44, 76))
                        setStroke(dp(1), Color.argb(90, 160, 170, 220))
                    }
                }
                cornerRadius = dp(12).toFloat()
            }
            minHeight = dp(48)
            setPadding(dp(12), dp(8), dp(12), dp(8))
            setOnClickListener { onClick() }
        }
        val lp = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        lp.bottomMargin = dp(10)
        parent.addView(b, lp)
        return b
    }

    private fun input(parent: LinearLayout, hint: String, multiline: Boolean = false, password: Boolean = false,
                      email: Boolean = false, numeric: Boolean = false): EditText {
        val edit = EditText(this).apply {
            this.hint = hint
            setHintTextColor(muted)
            setTextColor(pearl)
            textSize = 13.5f
            setPadding(dp(12), dp(10), dp(if (password) 52 else 12), dp(10))
            background = GradientDrawable().apply {
                setColor(Color.rgb(15, 22, 44))
                cornerRadius = dp(10).toFloat()
                setStroke(dp(1), Color.argb(90, 160, 170, 220))
            }
            if (password) inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD
            else if (email) inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS
            else if (numeric) inputType = InputType.TYPE_CLASS_NUMBER
            else inputType = if (multiline) InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE
            else InputType.TYPE_CLASS_TEXT
            if (multiline) { minLines = 4; gravity = Gravity.TOP; setSingleLine(false) } else setSingleLine(true)
            if (password) transformationMethod = PasswordTransformationMethod.getInstance()
        }
        val lp = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, if (multiline) dp(120) else dp(48))
        lp.bottomMargin = dp(10)
        if (password) {
            val field = FrameLayout(this)
            field.addView(edit, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            val visibilityButton = ImageButton(this).apply {
                contentDescription = "Tampilkan kata sandi"
                setImageResource(R.drawable.ic_visibility)
                imageTintList = android.content.res.ColorStateList.valueOf(muted)
                scaleType = android.widget.ImageView.ScaleType.CENTER_INSIDE
                background = null
                setPadding(dp(12), dp(12), dp(12), dp(12))
            }
            visibilityButton.setOnClickListener {
                val wasVisible = edit.transformationMethod == null
                val start = edit.selectionStart.coerceIn(0, edit.length())
                val end = edit.selectionEnd.coerceIn(0, edit.length())
                edit.transformationMethod = if (wasVisible) PasswordTransformationMethod.getInstance() else null
                visibilityButton.setImageResource(if (wasVisible) R.drawable.ic_visibility else R.drawable.ic_visibility_off)
                visibilityButton.contentDescription = if (wasVisible) "Tampilkan kata sandi" else "Sembunyikan kata sandi"
                edit.setSelection(start, end)
            }
            field.addView(
                visibilityButton,
                FrameLayout.LayoutParams(dp(48), ViewGroup.LayoutParams.MATCH_PARENT, Gravity.END or Gravity.CENTER_VERTICAL)
            )
            parent.addView(field, lp)
        } else {
            parent.addView(edit, lp)
        }
        return edit
    }

    // =========================================================================
    // 1. WELCOME SCREEN
    // =========================================================================
    private fun showWelcome() {
        currentPage = "welcome"
        val body = createPage("Your messages. Your safety.", "Kenali risiko. Lindungi dirimu.", false)
        val hero = card(body, "Perlindungan Indikasi Phishing", "Analisis pesan SMS dan WhatsApp menggunakan Rule-Based Risk Scoring yang deterministik dan berjalan di perangkat.")
        text(hero, "CYBERSECURITY ASSISTANT NOTIFIKASI ANDROID", 9.5f, cyan, true, top = 10, bottom = 0)

        val telemetryBox = card(body, "Status Proteksi Perangkat", "Sistem memeriksa indikator phishing secara lokal tanpa transmisi cloud.")
        val row = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        telemetryBox.addView(row)
        statCell(row, "RULE ENGINE", "V4.2")
        statCell(row, "PRIVACY", "0% CLOUD")

        action(body, "Mulai Proteksi", { showHome() })
        action(body, "Sign In", { showLogin() }, false)
        action(body, "Create Account", { showSignup() }, false)
        action(body, "Panduan Akses Notifikasi", { showNotificationGuide() }, false)

        text(body, "PROTOTYPE 1.0 • RULE-BASED RISK SCORING • ZERO CLOUD LOGS", 9.5f, muted, top = 16)
    }

    private fun showLogin() {
        val body = createPage("Sign In", "Masuk ke akun MIVVI SECURE.", false)
        text(body, if (BuildConfig.DEBUG)
            "Login memerlukan koneksi ke server akun. Untuk emulator, gunakan base URL http://10.0.2.2:8000 di Pengaturan API."
        else
            "Login memerlukan server akun dengan HTTPS. Atur URL API HTTPS di Pengaturan API.", 11.5f, muted)
        val email = input(body, "Email address", email = true)
        val password = input(body, "Password", password = true)
        action(body, "Forgot Password?", { showForgotPassword() }, false)
        action(body, "Verify Email / Enter OTP", {
            val emailValue = email.text.toString().trim()
            if (validEmail(emailValue)) showVerifyEmail(emailValue)
            else showAuthError("Masukkan email akun yang menunggu verifikasi.")
        }, false)
        lateinit var signInButton: Button
        signInButton = action(body, "Sign In", {
            val emailValue = email.text.toString().trim()
            val passwordValue = password.text.toString()
            if (!validEmail(emailValue)) {
                showAuthError("Masukkan alamat email yang valid.")
            } else if (passwordValue.isBlank()) {
                showAuthError("Kata sandi wajib diisi.")
            } else {
                runAuthRequest(signInButton) {
                    AuthApiClient.login(authBaseUrl(), emailValue, passwordValue)
                }
            }
        })
        action(body, "Create Account", { showSignup() }, false)
        action(body, "Continue as Guest", { showHome() }, false)
    }

    private fun showSignup() {
        val body = createPage("Create Account", "Buat akun untuk pengalaman keamanan digitalmu.", false)
        val name = input(body, "Full name")
        val email = input(body, "Email address", email = true)
        val password = input(body, "Password (minimal 8 karakter)", password = true)
        val confirmPassword = input(body, "Confirm password", password = true)
        text(body, "Nama dan email disimpan di server akun. Kata sandi disimpan sebagai hash, bukan teks biasa.", 11.5f, muted)
        lateinit var registerButton: Button
        registerButton = action(body, "Create Account", {
            if (name.text.toString().trim().length < 2) showAuthError("Nama minimal 2 karakter.")
            else if (!validEmail(email.text.toString().trim())) showAuthError("Masukkan alamat email yang valid.")
            else if (password.text.length < 8) showAuthError("Kata sandi minimal 8 karakter.")
            else if (password.text.toString() != confirmPassword.text.toString()) showAuthError("Konfirmasi kata sandi tidak sama.")
            else {
                val nameValue = name.text.toString().trim()
                val emailValue = email.text.toString().trim()
                val passwordValue = password.text.toString()
                runRegistrationRequest(registerButton) {
                    AuthApiClient.register(authBaseUrl(), nameValue, emailValue, passwordValue)
                }
            }
        })
        action(body, "Already have an account? Sign In", { showLogin() }, false)
    }

    private fun runRegistrationRequest(button: Button, request: () -> AuthApiClient.VerificationChallenge) {
        val originalLabel = button.text.toString()
        button.isEnabled = false
        button.text = "Mengirim kode..."
        Thread {
            try {
                val challenge = request()
                runOnUiThread {
                    button.isEnabled = true
                    button.text = originalLabel
                    showVerifyEmail(challenge.email)
                }
            } catch (error: Exception) {
                runOnUiThread {
                    button.isEnabled = true
                    button.text = originalLabel
                    showAuthError(error.message ?: "Kode verifikasi belum dapat dikirim.")
                }
            }
        }.start()
    }

    private fun showVerifyEmail(emailAddress: String) {
        val body = createPage("Verifikasi Email", "Masukkan kode 6 digit yang dikirim ke $emailAddress.", false)
        text(body, "Kode berlaku 10 menit. Periksa folder spam jika email belum terlihat.", 11.5f, muted)
        val code = input(body, "Kode OTP 6 digit", numeric = true)
        lateinit var verifyButton: Button
        verifyButton = action(body, "Verifikasi & Masuk", {
            val codeValue = code.text.toString().trim()
            if (!codeValue.matches(Regex("^\\d{6}$"))) showAuthError("Masukkan kode OTP 6 digit.")
            else runAuthRequest(verifyButton) {
                AuthApiClient.verifyEmail(authBaseUrl(), emailAddress, codeValue)
            }
        })
        lateinit var resendButton: Button
        resendButton = action(body, "Kirim Ulang Kode", {
            val originalLabel = resendButton.text.toString()
            resendButton.isEnabled = false
            resendButton.text = "Mengirim..."
            Thread {
                try {
                    AuthApiClient.resendVerification(authBaseUrl(), emailAddress)
                    runOnUiThread {
                        resendButton.isEnabled = true
                        resendButton.text = originalLabel
                        Toast.makeText(this, "Kode verifikasi dikirim ulang.", Toast.LENGTH_LONG).show()
                    }
                } catch (error: Exception) {
                    runOnUiThread {
                        resendButton.isEnabled = true
                        resendButton.text = originalLabel
                        showAuthError(error.message ?: "Kode belum dapat dikirim ulang.")
                    }
                }
            }.start()
        }, false)
        action(body, "Kembali ke Sign In", { showLogin() }, false)
    }

    private fun showAccount() {
        val body = createPage("Akun Pribadi", "Profil dan sesi akun MIVVI SECURE.")
        val token = AuthSessionStore.token(this)
        if (token == null) {
            card(body, "Mode Tamu", "Belum ada akun yang masuk pada perangkat ini.")
            action(body, "Sign In", { showLogin() })
            action(body, "Create Account", { showSignup() }, false)
            return
        }

        val name = AuthSessionStore.userName(this).orEmpty()
        val email = AuthSessionStore.userEmail(this).orEmpty()
        val profileCard = card(body, "Profil Akun", name, Color.argb(100, 99, 221, 232))
        text(profileCard, email, 12.5f, muted, bottom = 0)
        card(body, "Verifikasi Email", "Terverifikasi")
        card(body, "Sesi", "Akun ini sedang masuk pada perangkat ini.")
        text(body, "Informasi akun disimpan oleh server akun. Riwayat pesan dan analisis tetap tersimpan lokal di perangkat.", 11.5f, muted)
        action(body, "Keluar dari Akun", { signOutFromAccount() }, false)
    }

    private fun signOutFromAccount() {
        val token = AuthSessionStore.token(this)
        Thread {
            val remoteLogoutSucceeded = if (token == null) true else try {
                AuthApiClient.logout(authBaseUrl(), token)
                true
            } catch (_: Exception) { false }
            AuthSessionStore.clear(this)
            runOnUiThread {
                val message = if (remoteLogoutSucceeded) "Sesi berhasil diakhiri."
                else "Token lokal dihapus; sesi server dapat berlaku sampai kedaluwarsa."
                Toast.makeText(this, message, Toast.LENGTH_LONG).show()
                showWelcome()
            }
        }.start()
    }

    private fun validEmail(value: String): Boolean =
        android.util.Patterns.EMAIL_ADDRESS.matcher(value).matches()

    private fun authBaseUrl(): String = AppPrefs.apiBaseUrl(this)

    private fun showAuthError(message: String) {
        AlertDialog.Builder(this).setTitle("Tidak dapat melanjutkan").setMessage(message)
            .setPositiveButton("Mengerti", null).show()
    }

    private fun runAuthRequest(button: Button, request: () -> AuthApiClient.Session) {
        val originalLabel = button.text.toString()
        button.isEnabled = false
        button.text = "Menghubungkan..."
        Thread {
            try {
                val session = request()
                AuthSessionStore.save(this, session)
                runOnUiThread {
                    button.isEnabled = true
                    button.text = originalLabel
                    Toast.makeText(this, "Berhasil masuk sebagai ${session.user.email}", Toast.LENGTH_LONG).show()
                    showHome()
                }
            } catch (error: Exception) {
                runOnUiThread {
                    button.isEnabled = true
                    button.text = originalLabel
                    showAuthError(error.message ?: "Periksa koneksi dan konfigurasi server akun.")
                }
            }
        }.start()
    }

    private fun showForgotPassword() {
        val body = createPage("Forgot Password", "Masukkan email akun untuk pemulihan kata sandi.", false)
        val email = input(body, "Email address", email = true)
        lateinit var requestButton: Button
        requestButton = action(body, "Kirim Kode Reset", {
            val emailValue = email.text.toString().trim()
            if (!validEmail(emailValue)) {
                showAuthError("Masukkan alamat email yang valid.")
            } else {
                val originalLabel = requestButton.text.toString()
                requestButton.isEnabled = false
                requestButton.text = "Meminta kode..."
                Thread {
                    try {
                        AuthApiClient.requestPasswordReset(authBaseUrl(), emailValue)
                        runOnUiThread {
                            requestButton.isEnabled = true
                            requestButton.text = originalLabel
                            showResetPassword(emailValue)
                        }
                    } catch (error: Exception) {
                        runOnUiThread {
                            requestButton.isEnabled = true
                            requestButton.text = originalLabel
                            showAuthError(error.message ?: "Kode reset belum dapat dikirim.")
                        }
                    }
                }.start()
            }
        })
        action(body, "Back to Sign In", { showLogin() }, false)
    }

    private fun showResetPassword(emailAddress: String) {
        val body = createPage("Reset Kata Sandi", "Jika email terdaftar, kode reset sudah dikirim ke $emailAddress.", false)
        text(body, "Kode berlaku 10 menit. Setelah berhasil, semua sesi akun lama akan dicabut.", 11.5f, muted)
        val code = input(body, "Kode reset 6 digit", numeric = true)
        val newPassword = input(body, "Kata sandi baru (minimal 8 karakter)", password = true)
        val confirmPassword = input(body, "Ulangi kata sandi baru", password = true)

        lateinit var resetButton: Button
        resetButton = action(body, "Ubah Kata Sandi", {
            val codeValue = code.text.toString().trim()
            val passwordValue = newPassword.text.toString()
            if (!codeValue.matches(Regex("^\\d{6}$"))) showAuthError("Masukkan kode reset 6 digit.")
            else if (passwordValue.length < 8) showAuthError("Kata sandi minimal 8 karakter.")
            else if (passwordValue != confirmPassword.text.toString()) showAuthError("Konfirmasi kata sandi tidak sama.")
            else {
                val originalLabel = resetButton.text.toString()
                resetButton.isEnabled = false
                resetButton.text = "Memperbarui..."
                Thread {
                    try {
                        AuthApiClient.confirmPasswordReset(authBaseUrl(), emailAddress, codeValue, passwordValue)
                        runOnUiThread {
                            resetButton.isEnabled = true
                            resetButton.text = originalLabel
                            Toast.makeText(this, "Kata sandi diubah. Silakan masuk kembali.", Toast.LENGTH_LONG).show()
                            showLogin()
                        }
                    } catch (error: Exception) {
                        runOnUiThread {
                            resetButton.isEnabled = true
                            resetButton.text = originalLabel
                            showAuthError(error.message ?: "Kata sandi belum dapat diubah.")
                        }
                    }
                }.start()
            }
        })

        action(body, "Kirim Ulang Kode", {
            Thread {
                try {
                    AuthApiClient.requestPasswordReset(authBaseUrl(), emailAddress)
                    runOnUiThread {
                        Toast.makeText(this, "Jika akun terdaftar, kode reset akan dikirim.", Toast.LENGTH_LONG).show()
                    }
                } catch (error: Exception) {
                    runOnUiThread { showAuthError(error.message ?: "Kode reset belum dapat dikirim ulang.") }
                }
            }.start()
        }, false)
        action(body, "Kembali ke Sign In", { showLogin() }, false)
    }

    // =========================================================================
    // 2. ONBOARDING / PERMISSION GUIDE (Panduan Akses Notifikasi)
    // =========================================================================
    private fun showNotificationGuide() {
        val body = createPage("Akses Notifikasi", "Panduan aktivasi izin listener notifikasi pada Android.")
        val statusCard = card(body, "Status Akses Notifikasi",
            if (simulatedNotificationAccess || AppPrefs.notificationAccessEnabled(this))
                "Status: Terhubung (Mode Listener Aktif). MIVVI SECURE dapat membaca pratinjau pesan SMS & WhatsApp."
            else
                "Status: Belum Terhubung. Berikan izin agar sistem dapat mendeteksi pratinjau pesan masuk."
        )
        text(statusCard, if (simulatedNotificationAccess || AppPrefs.notificationAccessEnabled(this)) "STATUS: AKTIF" else "STATUS: NONAKTIF",
            10.5f, if (simulatedNotificationAccess || AppPrefs.notificationAccessEnabled(this)) green else amber, true, top = 8)

        text(body, "PROTOKOL AKTIVASI // 5 TAHAP", 12f, cyan, true, top = 8, bottom = 6)
        val steps = listOf(
            "Tahap 01: Buka Pengaturan Android" to "Buka menu Pengaturan (Settings) > Aplikasi & Notifikasi.",
            "Tahap 02: Pilih Akses Khusus / Notifikasi" to "Masuk ke menu Akses Aplikasi Khusus, lalu ketuk 'Akses Notifikasi'.",
            "Tahap 03: Temukan MIVVI SECURE" to "Cari aplikasi MIVVI SECURE dalam daftar listener yang tersedia.",
            "Tahap 04: Aktifkan Sakelar Izin" to "Berikan izin akses notifikasi jika kamu memahami dan menyetujuinya.",
            "Tahap 05: Kembali ke MIVVI SECURE" to "Aplikasi akan mendeteksi status akses secara lokal tanpa perlu restart."
        )
        steps.forEach { (title, desc) -> card(body, title, desc) }

        action(body, "Buka Pengaturan Android", { openNotificationAccess() }, false)
        action(body, "Simulasikan Izin (Demo Toggle)", {
            simulatedNotificationAccess = !simulatedNotificationAccess
            Toast.makeText(this, "Simulasi akses diubah: $simulatedNotificationAccess", Toast.LENGTH_SHORT).show()
            showNotificationGuide()
        }, false)
        action(body, "Kembali ke Beranda", { showHome() })
    }

    // =========================================================================
    // 3. BERANDA (HOME)
    // =========================================================================
    private fun showHome() {
        val body = createPage("Beranda", "Kenali risiko. Lindungi dirimu.")
        val isEnabled = simulatedNotificationAccess || AppPrefs.notificationAccessEnabled(this)

        if (AuthSessionStore.token(this) != null) {
            card(body, "Akun Terhubung", AuthSessionStore.userEmail(this).orEmpty())
        }

        val shield = card(body, if (isEnabled) "Sistem Pemantau Aktif" else "Sistem Pemantau Belum Aktif",
            if (isEnabled) "Memeriksa pola teks mencurigakan (URL pendek, urgensi palsu, impersonasi bank) secara privat di perangkat tanpa mengirim data ke server."
            else "Aktifkan akses notifikasi agar MIVVI SECURE dapat menganalisis pesan SMS dan WhatsApp yang masuk.",
            if (isEnabled) Color.argb(100, 45, 212, 191) else Color.argb(100, 245, 158, 11)
        )
        text(shield, if (isEnabled) "STATUS: PEMANTAUAN AKTIF [DEMO]" else "STATUS: BUTUH IZIN NOTIFIKASI",
            10.5f, if (isEnabled) green else amber, true, top = 8, bottom = 0)

        // Standar Tingkat Risiko Card
        val scaleCard = card(body, "Standar Tingkat Risiko", "Klasifikasi skor deterministik berdasarkan bobot indikator:")
        val scaleRow = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        scaleCard.addView(scaleRow)
        statCell(scaleRow, "AMAN", "< 3", green)
        statCell(scaleRow, "MENCURIGAKAN", "3–5", amber)
        statCell(scaleRow, "PHISHING", "≥ 6", red)

        // Ringkasan Aktivitas
        val total = dbCount()
        val high = dbHighRisk()
        val stats = card(body, "Ringkasan Aktivitas", "Data dihitung dari analisis lokal pada perangkat ini.")
        val row = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        stats.addView(row)
        statCell(row, "TOTAL ANALISIS", total.toString(), cyan)
        statCell(row, "PHISHING", high.toString(), red)

        action(body, "Analisis Pesan Manual", { showManual() })
        action(body, "Lihat Aktivitas Notifikasi", { showActivities() }, false)

        text(body, "Aktivitas Terbaru", 16f, pearl, true, top = 12, bottom = 4)
        val latest = dbRecent(3)
        if (latest.isEmpty()) {
            text(body, "Belum ada aktivitas. Coba analisis pesan manual atau aktifkan simulasi pesan.", 12.5f, muted)
        } else {
            latest.forEach { record -> recordCard(body, record) }
        }

        text(body, "RULE ENGINE V4.2.1 • ZERO CLOUD LOGS • 0 LATENSI", 9.5f, muted, top = 14)
    }

    private fun statCell(parent: LinearLayout, label: String, value: String, color: Int = cyan) {
        val horizontal = parent.orientation == LinearLayout.HORIZONTAL
        val cell = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = if (horizontal) Gravity.CENTER_HORIZONTAL else Gravity.START
            setPadding(0, dp(6), 0, 0)
        }
        val params = if (horizontal) LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        else LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        parent.addView(cell, params)
        text(cell, value, if (resources.configuration.screenWidthDp < 360) 20f else 22f, color, true, bottom = 1)
            .gravity = if (horizontal) Gravity.CENTER else Gravity.START
        text(cell, label, if (resources.configuration.screenWidthDp < 360) 8.5f else 9.5f, muted, true, bottom = 0)
            .apply {
                gravity = if (horizontal) Gravity.CENTER else Gravity.START
                maxLines = 2
            }
    }

    // =========================================================================
    // 4. ANALISIS MANUAL & SCANNING TRANSITION
    // =========================================================================
    private var selectedSource = "SMS"

    private fun showManual(prefill: String? = null, prefillSender: String? = null) {
        val body = createPage("Analisis Manual", "Periksa isi pesan yang ingin kamu analisis.")
        val tips = card(body, "Tips Privasi", "Jika isi pesan tidak tersedia pada notifikasi atau pratinjau disembunyikan WhatsApp, kamu dapat menempelkan teks pesan di sini untuk memeriksa indikator risiko.")
        text(tips, "ISOLASI SANDBOX LOKAL", 9.5f, cyan, true, top = 6, bottom = 0)

        text(body, "SUMBER PESAN", 11.5f, muted, true, top = 8, bottom = 4)
        val sourceRow = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        body.addView(sourceRow, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))

        val btnSms = Button(this)
        val btnWa = Button(this)
        listOf(btnSms, btnWa).forEach {
            it.isAllCaps = false
            it.textSize = 12f
            it.maxLines = 2
            it.minHeight = dp(48)
        }
        fun updateSourceButtons() {
            btnSms.apply {
                text = "SMS (Pesan)"
                setTextColor(if (selectedSource == "SMS") cosmic else pearl)
                background = GradientDrawable().apply {
                    setColor(if (selectedSource == "SMS") cyan else Color.rgb(38, 44, 76))
                    cornerRadius = dp(10).toFloat()
                }
            }
            btnWa.apply {
                text = "WhatsApp"
                setTextColor(if (selectedSource == "WHATSAPP") cosmic else pearl)
                background = GradientDrawable().apply {
                    setColor(if (selectedSource == "WHATSAPP") cyan else Color.rgb(38, 44, 76))
                    cornerRadius = dp(10).toFloat()
                }
            }
        }
        btnSms.setOnClickListener { selectedSource = "SMS"; updateSourceButtons() }
        btnWa.setOnClickListener { selectedSource = "WHATSAPP"; updateSourceButtons() }
        updateSourceButtons()
        val halfLp = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f).apply { marginEnd = dp(6) }
        val halfLp2 = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f).apply { marginStart = dp(6) }
        sourceRow.addView(btnSms, halfLp)
        sourceRow.addView(btnWa, halfLp2)

        text(body, "PENGIRIM (OPSIONAL)", 11.5f, muted, true, top = 10, bottom = 4)
        val senderInput = input(body, "Contoh: 0812xxxx atau Bank BNI")
        if (!prefillSender.isNullOrBlank()) senderInput.setText(prefillSender)

        text(body, "ISI PESAN", 11.5f, muted, true, top = 8, bottom = 4)
        val messageInput = input(body, "Tempel atau ketik isi pesan di sini...", multiline = true)
        if (!prefill.isNullOrBlank()) messageInput.setText(prefill)

        val charCount = text(body, "READY FOR SCAN: ${messageInput.text?.length ?: 0} / 1000 karakter", 10.5f, muted, bottom = 8)
        messageInput.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                val len = s?.length ?: 0
                charCount.text = "READY FOR SCAN: $len / 1000 karakter"
            }
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
        })

        // Text tools row (Tempel Teks & Bersihkan)
        val toolRow = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        body.addView(toolRow)
        val btnPaste = Button(this).apply {
            text = "Tempel Teks"
            textSize = 12f
            isAllCaps = false
            setTextColor(pearl)
            background = GradientDrawable().apply { setColor(Color.rgb(35, 42, 72)); cornerRadius = dp(8).toFloat() }
            setOnClickListener {
                val clip = (getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager).primaryClip
                if (clip != null && clip.itemCount > 0) {
                    messageInput.setText(clip.getItemAt(0).text)
                } else Toast.makeText(this@MainActivity, "Clipboard kosong", Toast.LENGTH_SHORT).show()
            }
        }
        val btnClear = Button(this).apply {
            text = "Bersihkan"
            textSize = 12f
            isAllCaps = false
            setTextColor(muted)
            background = GradientDrawable().apply { setColor(Color.rgb(35, 42, 72)); cornerRadius = dp(8).toFloat() }
            setOnClickListener { messageInput.setText(""); senderInput.setText("") }
        }
        val tLp = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply { marginEnd = dp(6) }
        val tLp2 = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply { marginStart = dp(6) }
        btnPaste.minHeight = dp(44)
        btnClear.minHeight = dp(44)
        toolRow.addView(btnPaste, tLp)
        toolRow.addView(btnClear, tLp2)

        var isDemo = false
        action(body, "Coba Contoh Phishing (Demo Skor 13)", {
            messageInput.setText("Rekening Anda diblokir. Segera verifikasi akun hari ini melalui https://bit.ly/verifikasi-aman dan kirim kode OTP/PIN.")
            senderInput.setText("Pengirim Tidak Dikenal")
            isDemo = true
        }, false)

        // Heuristic Overview Card
        val checksCard = card(body, "Indikator Aturan Heuristik (6 Checks)",
            "Keyword bahaya (+2) • Domain tak resmi (+3) • Shortlink (+2) • Pengirim baru (+2) • Urgensi waktu (+1) • Minta sensitif (+3)")
        text(checksCard, "DETERMINISTIK • MAKSIMUM SKOR 13", 9.5f, cyan, true, top = 6, bottom = 0)

        action(body, "Analisis Risiko", {
            val content = messageInput.text.toString().trim()
            if (content.isBlank()) {
                Toast.makeText(this, "Isi pesan belum dimasukkan.", Toast.LENGTH_SHORT).show()
                return@action
            }
            showScanningAnimation(content, senderInput.text.toString(), selectedSource, isDemo)
        })
        action(body, "Kembali ke Beranda", { showHome() }, false)
    }

    private fun showScanningAnimation(content: String, sender: String, source: String, isDemo: Boolean) {
        val body = createPage("Memeriksa Pesan...", "Evaluasi heuristik berbasis aturan sedang berlangsung.", false)
        val scanCard = card(body, "DEEP SYSTEM SCAN", "MIVVI SECURE memeriksa 6 indikator deterministik secara lokal.")
        text(scanCard, "[VERIFIED 01] Normalisasi teks (Unicode & Case)", 11f, green, top = 4)
        text(scanCard, "[VERIFIED 02] Ekstraksi tautan & token URL", 11f, green, top = 2)
        text(scanCard, "[VERIFIED 03] Pencocokan kata kunci mencurigakan", 11f, green, top = 2)
        text(scanCard, "[PROCESSING 04] Pemeriksaan pengirim & pola urgensi", 11f, amber, top = 2)
        text(scanCard, "[PENDING 05] Perhitungan total skor risiko rule-based", 11f, muted, top = 2)
        text(scanCard, "[PENDING 06] Klasifikasi akhir (Aman / Curiga / Phishing)", 11f, muted, top = 2)

        action(body, "Selesai Memeriksa → Lihat Hasil", {
            val result = RuleBasedAnalyzer(RuleConfigStore.load(this)).analyze(content, sender, AppPrefs.trustedSenders(this))
            val id = LocalDatabase(this).use { it.insert(source, sender, content, System.currentTimeMillis(), result, isDemo) }
            showResult(content, sender, source, result, id, isDemo)
        })

        // Auto transition after 600ms
        Handler(Looper.getMainLooper()).postDelayed({
            if (currentPage == "welcome" || currentPage == "home") return@postDelayed
            val result = RuleBasedAnalyzer(RuleConfigStore.load(this)).analyze(content, sender, AppPrefs.trustedSenders(this))
            val id = LocalDatabase(this).use { it.insert(source, sender, content, System.currentTimeMillis(), result, isDemo) }
            showResult(content, sender, source, result, id, isDemo)
        }, 600)
    }

    // =========================================================================
    // 5. HASIL ANALISIS (DETAIL ANCAMAN)
    // =========================================================================
    private fun showResult(message: String, sender: String, source: String, result: AnalysisResult, recordId: Long, demo: Boolean) {
        val body = createPage("Detail Ancaman", "Hasil evaluasi Rule-Based Risk Scoring")
        val statusColor = when (result.category) { "PHISHING" -> red; "MENCURIGAKAN" -> amber; else -> green }

        val banner = card(body, "${result.category} • ${result.level}", "Kalkulasi Telemetri Heuristik", statusColor)
        text(banner, result.score.toString(), 46f, statusColor, true, top = 4, bottom = 0)
        text(banner, "SKOR RISIKO (MAX 13)", 10f, muted, true, bottom = 4)
        text(banner, "Skala Ambang Batas: 0–2 Aman • 3–5 Curiga • 6+ Phishing", 10.5f, muted, bottom = 0)

        if (demo) text(body, "DEMO — contoh pesan sintetis", 10.5f, amber, true, bottom = 6)

        val sourceCard = card(body, "Informasi Pesan", "Platform: $source  •  Pengirim: ${if (sender.isBlank()) "Tidak Dikenal" else sender}")
        text(sourceCard, message, 12f, pearl, top = 8, bottom = 0)

        text(body, "Mengapa pesan ini berisiko? (${result.features.count { it.detected }} Terdeteksi)", 15f, pearl, true, top = 8, bottom = 4)
        result.features.forEach { feature ->
            val row = card(body,
                "${if (feature.detected) "●" else "○"}  ${feature.label}   ${if (feature.detected) "+${feature.points}" else "+0"}",
                feature.explanation,
                if (feature.detected) statusColor else Color.argb(40, 150, 160, 210)
            )
            text(row, if (feature.detected) "TERDETEKSI (+${feature.points})" else "TIDAK TERDETEKSI (+0)",
                9.5f, if (feature.detected) statusColor else muted, true, top = 6, bottom = 0)
        }

        val advice = when (result.category) {
            "PHISHING" -> "1. Jangan membuka tautan atau mengunduh berkas apapun dari pesan ini.\n2. Jangan pernah membagikan OTP, PIN, atau kata sandi.\n3. Lakukan verifikasi mandiri hanya melalui aplikasi perbankan resmi atau call center terverifikasi."
            "MENCURIGAKAN" -> "1. Periksa kembali keaslian domain dan identitas pengirim.\n2. Jangan terburu-buru mengikuti instruksi dalam pesan.\n3. Hubungi pengirim melalui kanal alternatif."
            else -> "Tidak ditemukan indikator mencurigakan kuat berdasarkan aturan saat ini. Tetap berhati-hati sebelum membuka tautan atau membagikan informasi pribadi."
        }
        card(body, "Yang Sebaiknya Kamu Lakukan", advice)

        action(body, "Analisis Pesan Manual Lain", { showManual() })
        action(body, "Kembali ke Beranda", { showHome() }, false)
        action(body, "Lihat Riwayat Analisis", { showHistory() }, false)
    }

    // =========================================================================
    // 6. AKTIVITAS NOTIFIKASI
    // =========================================================================
    private var activityFilter: String? = null

    private fun showActivities() {
        val body = createPage("Aktivitas Notifikasi", "Notifikasi pesan yang tersedia untuk dianalisis.")

        // Filter Tabs: Semua, SMS, WhatsApp, Perlu Diperiksa
        val tabScroll = HorizontalScrollView(this).apply { isFillViewport = false }
        val tabRow = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        tabScroll.addView(tabRow)
        body.addView(tabScroll, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(44)).apply { bottomMargin = dp(8) })

        val tabs = listOf(
            "Semua" to null,
            "SMS" to "SMS",
            "WhatsApp" to "WHATSAPP",
            "Perlu Diperiksa" to "PERLU_DIPERIKSA"
        )
        tabs.forEach { (label, value) ->
            val isSelected = activityFilter == value
            val b = Button(this).apply {
                text = label
                textSize = 11.5f
                isAllCaps = false
                setTextColor(if (isSelected) cosmic else pearl)
                background = GradientDrawable().apply {
                    setColor(if (isSelected) cyan else Color.rgb(35, 42, 70))
                    cornerRadius = dp(8).toFloat()
                }
                setOnClickListener {
                    activityFilter = value
                    showActivities()
                }
            }
            val lp = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, dp(36)).apply { marginEnd = dp(6) }
            tabRow.addView(b, lp)
        }

        val records = LocalDatabase(this).use { db ->
            when (activityFilter) {
                null -> db.recent(100)
                "PERLU_DIPERIKSA" -> db.queryFiltered(category = "PERLU_DIPERIKSA")
                else -> db.queryFiltered(source = activityFilter)
            }
        }

        if (records.isEmpty()) {
            val empty = card(body, "Belum ada notifikasi", "Notifikasi akan muncul setelah event SMS atau WhatsApp terdeteksi atau dianalisis.")
            text(empty, "STATUS ALIRAN DATA: STANDBY", 9.5f, cyan, true, top = 6, bottom = 0)
            action(body, "Mulai Analisis Manual", { showManual() })
        } else {
            records.forEach { record ->
                recordCard(body, record) {
                    if (record.body.isBlank()) showHiddenContentDetail(record)
                    else showRecordDetail(record)
                }
            }
        }
    }

    // =========================================================================
    // 7. PESAN BELUM TERSEDIA (HIDDEN CONTENT DIAGNOSTIC)
    // =========================================================================
    private fun showHiddenContentDetail(record: AnalysisRecord) {
        val body = createPage("Pesan Belum Tersedia", "[STATUS: INDETERMINATE] TELEMETRY_CODE_404_PAYLOAD")
        val warningCard = card(body, "Konten Notifikasi Tersembunyi",
            "Beberapa notifikasi hanya menampilkan ringkasan, seperti '3 pesan baru' atau nama kontak pengirim saja. MIVVI SECURE tidak dapat menentukan skor risiko tanpa teks pesan yang memadai.",
            amber
        )
        text(warningCard, "PRINSIP INTEGRITAS DATA: TIDAK MEMBUAT SKOR PALSU", 9.5f, amber, true, top = 8, bottom = 0)

        card(body, "Metadata Notifikasi", "Platform: ${record.source}\nPengirim: ${record.sender.ifBlank { "Tidak tersedia" }}\nWaktu: ${formatTime(record.receivedAt)}")

        text(body, "Yang Bisa Kamu Lakukan (3 Rekomendasi)", 14f, pearl, true, top = 8, bottom = 4)
        card(body, "STEP 01: Buka Aplikasi Pesan Terkait", "Buka WhatsApp atau SMS secara langsung untuk membaca isi percakapan secara utuh.")
        card(body, "STEP 02: Periksa Pengaturan Pratinjau", "Aktifkan opsi 'Tampilkan pratinjau pesan di layar kunci' pada setelan Android atau WhatsApp.")
        card(body, "STEP 03: Masukkan Teks Secara Manual", "Salin teks atau tautan yang dicurigai dari chat, lalu gunakan modul Analisis Manual.")

        action(body, "Gunakan Analisis Manual", { showManual(prefillSender = record.sender) })
        action(body, "Panduan Akses Notifikasi", { showNotificationGuide() }, false)
        action(body, "Kembali ke Aktivitas", { showActivities() }, false)
    }

    // =========================================================================
    // 8. RIWAYAT ANALISIS
    // =========================================================================
    private var historyCategoryFilter: String? = null
    private var historySearchQuery: String? = null

    private fun showHistory() {
        val body = createPage("Riwayat Analisis", "Periksa kembali hasil analisis yang tersimpan di memori lokal.")

        // Search Input
        val search = input(body, "Cari pengirim atau isi pesan...")
        if (!historySearchQuery.isNullOrBlank()) search.setText(historySearchQuery)
        search.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                historySearchQuery = s?.toString()?.trim()
            }
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
        })

        // Filter chips: Semua, Aman, Mencurigakan, Phishing
        val tabScroll = HorizontalScrollView(this).apply { isFillViewport = false }
        val tabRow = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        tabScroll.addView(tabRow)
        body.addView(tabScroll, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(44)).apply { bottomMargin = dp(8) })

        val chips = listOf(
            "Semua" to null,
            "Aman" to "AMAN",
            "Mencurigakan" to "MENCURIGAKAN",
            "Phishing" to "PHISHING"
        )
        chips.forEach { (label, value) ->
            val isSelected = historyCategoryFilter == value
            val b = Button(this).apply {
                text = label
                textSize = 11.5f
                isAllCaps = false
                setTextColor(if (isSelected) cosmic else pearl)
                background = GradientDrawable().apply {
                    setColor(if (isSelected) cyan else Color.rgb(35, 42, 70))
                    cornerRadius = dp(8).toFloat()
                }
                setOnClickListener {
                    historyCategoryFilter = value
                    showHistory()
                }
            }
            val lp = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, dp(36)).apply { marginEnd = dp(6) }
            tabRow.addView(b, lp)
        }

        val records = LocalDatabase(this).use { db ->
            db.queryFiltered(category = historyCategoryFilter, query = historySearchQuery)
        }

        if (records.isEmpty()) {
            val empty = card(body, "Belum ada riwayat", "Hasil analisis yang disimpan akan muncul di sini secara lokal dan terlindungi.")
            text(empty, "0% CLOUD LEAK • PENYIMPANAN PRIVAT", 9.5f, cyan, true, top = 6, bottom = 0)
            action(body, "Mulai Analisis Manual", { showManual() })
        } else {
            records.forEach { record -> recordCard(body, record) { showRecordDetail(record) } }
            action(body, "Hapus Seluruh Riwayat", {
                AlertDialog.Builder(this).setTitle("Hapus seluruh riwayat?")
                    .setMessage("Tindakan ini menghapus seluruh data analisis dari database lokal dan tidak dapat dibatalkan.")
                    .setNegativeButton("Batal", null)
                    .setPositiveButton("Hapus") { _, _ ->
                        LocalDatabase(this).use { it.clear() }
                        Toast.makeText(this, "Riwayat dihapus.", Toast.LENGTH_SHORT).show()
                        showHistory()
                    }.show()
            }, false, danger = true)
        }
    }

    private fun showRecordDetail(record: AnalysisRecord) {
        if (record.body.isBlank()) {
            showHiddenContentDetail(record)
            return
        }
        val result = RuleBasedAnalyzer(RuleConfigStore.load(this)).analyze(record.body, record.sender, AppPrefs.trustedSenders(this))
        val body = createPage("Detail Riwayat", "Catatan hasil analisis tersimpan dari memori lokal.")
        val statusColor = when (result.category) { "PHISHING" -> red; "MENCURIGAKAN" -> amber; else -> green }

        val banner = card(body, "${result.category} • ${result.level}", "Ambang Batas: 0–2 Aman | 3–5 Curiga | 6+ Phishing", statusColor)
        text(banner, result.score.toString(), 46f, statusColor, true, top = 4, bottom = 0)
        text(banner, "SKOR RISIKO ${result.score}/13", 10f, muted, true, bottom = 4)

        val meta = card(body, "Informasi Pesan", "Sumber: ${record.source} • Waktu: ${formatTime(record.receivedAt)}\nPengirim: ${record.sender.ifBlank { "Tidak Dikenal" }}")
        text(meta, record.body, 12f, pearl, top = 8, bottom = 0)

        text(body, "Aturan Heuristik Terpicu (${result.features.count { it.detected }} Rules)", 14f, pearl, true, top = 8, bottom = 4)
        result.features.forEach { feature ->
            val row = card(body,
                "${if (feature.detected) "●" else "○"} ${feature.label} (+${if (feature.detected) feature.points else 0} Poin)",
                feature.explanation,
                if (feature.detected) statusColor else Color.argb(40, 150, 160, 210)
            )
            text(row, if (feature.detected) "TERDETEKSI (+${feature.points})" else "TIDAK TERDETEKSI (+0)",
                9.5f, if (feature.detected) statusColor else muted, true, top = 4, bottom = 0)
        }

        action(body, "Analisis Ulang Pesan Ini", { showManual(record.body, record.sender) })
        action(body, "Hapus dari Riwayat (Konfirmasi)", {
            AlertDialog.Builder(this).setTitle("Hapus catatan ini?")
                .setMessage("Catatan analisis ini akan dihapus dari riwayat lokal perangkat.")
                .setNegativeButton("Batal", null)
                .setPositiveButton("Hapus") { _, _ ->
                    LocalDatabase(this).use { it.delete(record.id) }
                    Toast.makeText(this, "Catatan dihapus.", Toast.LENGTH_SHORT).show()
                    showHistory()
                }.show()
        }, false, danger = true)
        action(body, "Kembali ke Riwayat", { showHistory() }, false)
    }

    // =========================================================================
    // 9. EDUKASI KEAMANAN & DETAIL EDUKASI (5 LANGKAH)
    // =========================================================================
    private fun showEducation() {
        val body = createPage("Edukasi Keamanan", "Kenali pola phishing. Sedikit lebih waspada, jauh lebih terlindungi.")

        val featured = card(body, "5 Langkah Sebelum Membuka Tautan",
            "Pedoman praktis mengenali rekayasa sosial dan tautan berbahaya dalam genggaman. Disertai simulasi checklist keselamatan.",
            cyan
        )
        text(featured, "MODUL EDUKASI UNGGULAN → BACA & SIMULASI", 10f, cyan, true, top = 8, bottom = 0)
        featured.setOnClickListener { showEducationSteps() }

        text(body, "3 Tanda Pesan yang Patut Diwaspadai", 15f, pearl, true, top = 8, bottom = 4)
        val indicators = listOf(
            "Tautan Tidak Dikenal [SEC_01]" to "Periksa alamat domain dan jangan membuka tautan dari pengirim tidak dikenal.",
            "Tekanan untuk Segera Bertindak [SEC_02]" to "Waspadai pesan yang mengancam pemblokiran akun atau batas waktu mendesak (1x24 jam).",
            "Permintaan Data Rahasia [SEC_03]" to "Jangan pernah membagikan OTP, PIN, atau kata sandi melalui pesan yang mencurigakan."
        )
        indicators.forEach { (title, desc) -> card(body, title, desc) }

        // Real-Time Sample Intercept Card
        val sampleCard = card(body, "Simulasi Pesan Intercept [BANK-PUSAT-NOT]",
            "PENTING: Rekening Anda terdeteksi akses ilegal! Kami akan membekukan saldo dalam 1x24 jam. Segera verifikasi via bit.ly/aman-bank-id dan kirim Kode OTP.",
            red
        )
        text(sampleCard, "THREAT SCORE: 13/13 (PHISHING) • BUKA DI ANALISIS MANUAL →", 9.5f, red, true, top = 8, bottom = 0)
        sampleCard.setOnClickListener {
            showManual(
                "PENTING: Rekening Anda terdeteksi akses ilegal! Kami akan membekukan saldo dalam 1x24 jam. Segera verifikasi via bit.ly/aman-bank-id dan kirim Kode OTP.",
                "BANK-PUSAT-NOT"
            )
        }

        action(body, "Pusat Bantuan & FAQ", { showHelpFaq() }, false)
        action(body, "Metode Deteksi & Batasan", { showDetectionMethods() }, false)
    }

    private fun showEducationSteps() {
        val body = createPage("Detail Edukasi", "5 Langkah Sebelum Membuka Tautan • Modul Edukasi 4 Menit")
        val steps = listOf(
            Triple("Langkah 01: Periksa Domain Secara Teliti",
                "Bandingkan alamat web dengan domain resmi institusi. Waspadai huruf pengganti visual atau typo tipis seperti bca-klik.com vs bca.co.id.",
                "Rekomendasi: Jangan klik sebelum memeriksa nama host utama."),
            Triple("Langkah 02: Waspadai Shortlink Tak Terduga",
                "Layanan penyingkat tautan (seperti bit.ly, s.id, atau tinyurl) kerap dimanfaatkan pelaku untuk menyembunyikan alamat target berbahaya.",
                "Rekomendasi: Bank resmi tidak menggunakan pemendek link publik cuma-cuma."),
            Triple("Langkah 03: Jangan Panik Ancaman Waktu",
                "Pelaku sengaja menciptakan ilusi urgensi buatan seperti 'dalam 1x24 jam akun dibekukan' guna melumpuhkan nalar kritis.",
                "Rekomendasi: Tarik napas, beri jeda 3 menit, lalu hubungi kanal resmi."),
            Triple("Langkah 04: Pantang Berikan OTP, PIN & Sandi",
                "One Time Password (OTP) adalah gerbang otentikasi mutlak. Bank maupun institusi mana pun tidak pernah meminta kode ini melalui chat.",
                "Rekomendasi: Anggap siapa pun yang meminta OTP adalah pelaku kejahatan."),
            Triple("Langkah 05: Verifikasi Mandiri Kanal Resmi",
                "Jangan mempercayai nomor telepon atau tautan customer support yang ditulis langsung di dalam teks pengirim.",
                "Rekomendasi: Buka manual aplikasi mobile banking resmi di ponselmu.")
        )
        steps.forEach { (title, desc, rec) ->
            val c = card(body, title, desc)
            text(c, rec, 11f, cyan, top = 6, bottom = 0)
        }

        text(body, "Sebelum Kamu Klik... (Checklist Keselamatan)", 14f, pearl, true, top = 8, bottom = 4)
        val checks = listOf(
            "Domain sesuai alamat resmi institusi",
            "Bukan tautan singkat (shortlink) tersembunyi",
            "Tidak ada paksaan batas waktu darurat",
            "Tidak meminta OTP, kata sandi, atau data kartu"
        )
        checks.forEach { chkText ->
            val cb = CheckBox(this).apply { text = chkText; setTextColor(pearl); textSize = 12.5f }
            body.addView(cb)
        }

        action(body, "Coba Simulasi Analisis", { showManual() })
        action(body, "Kembali ke Edukasi", { showEducation() }, false)
    }

    // =========================================================================
    // 10. PUSAT BANTUAN & FAQ
    // =========================================================================
    private fun showHelpFaq() {
        val body = createPage("Pusat Bantuan", "Kenali cara kerja, privasi, dan batasan MIVVI SECURE.")
        val faqs = listOf(
            "Q.01 Apakah MIVVI SECURE membaca seluruh chat WhatsApp saya?" to
                "Tidak. Aplikasi hanya membaca teks pratinjau notifikasi yang ditampilkan Android setelah izin diberikan pengguna. Aplikasi tidak memiliki akses ke database obrolan privat WhatsApp.",
            "Q.02 Mengapa isi notifikasi kadang tidak tersedia?" to
                "Jika pengguna menyembunyikan pratinjau pesan di layar kunci atau dalam aplikasi WhatsApp, Android hanya menyediakan metadata ringkasan. MIVVI SECURE tidak menebak isi pesan yang tersembunyi.",
            "Q.03 Apakah skor tinggi membuktikan pesan pasti penipuan hukum?" to
                "Tidak. Skor risiko merupakan indikator heuristik berbasis aturan untuk meningkatkan kewaspadaan, bukan vonis mutlak hukum.",
            "Q.04 Apakah aplikasi memblokir pesan secara otomatis?" to
                "Tidak. Prototipe ini tidak memblokir atau menghapus pesan secara sepihak tanpa izin eksplisit pengguna.",
            "Q.05 Bagaimana skor risiko dihitung?" to
                "Skor dihitung dari akumulasi 6 indikator deterministik: Keyword (+2), URL di luar whitelist (+3), Shortlink (+2), Pengirim tidak dikenal (+2), Urgensi (+1), dan Permintaan data sensitif (+3). Maksimum skor adalah 13.",
            "Q.06 Di mana riwayat analisis disimpan?" to
                "Riwayat disimpan secara lokal di database SQLite perangkat Anda. Tidak ada pengiriman data pesan ke cloud pihak ketiga."
        )
        faqs.forEach { (q, a) ->
            val c = card(body, q, a)
            text(c, "ARSIP TERVERIFIKASI", 9.5f, cyan, true, top = 6, bottom = 0)
        }
        action(body, "Pelajari Metode Deteksi", { showDetectionMethods() }, false)
        action(body, "Lihat Kebijakan Privasi & Data", { showPrivacyData() }, false)
        action(body, "Kembali ke Pengaturan", { showSettings() })
    }

    // =========================================================================
    // 11. PRIVASI DAN DATA
    // =========================================================================
    private fun showPrivacyData() {
        val body = createPage("Privasi dan Data", "Kamu berhak memahami informasi yang diproses aplikasi.")
        card(body, "1.0 // SUMBER INFORMASI", "Aplikasi hanya membaca data yang diekspos melalui Android Notification Listener setelah izin diberikan oleh pengguna. Fitur Analisis Manual disediakan sebagai alternatif.")
        card(body, "2.0 // INFORMASI YANG DIPROSES (5 ATTRIBUTES)", "1. Teks Notifikasi (push alert sistem)\n2. Pengirim (nomor atau nama tampilan)\n3. Sumber Aplikasi (paket SMS / WhatsApp)\n4. Waktu Diterima (timestamp lokal)\n5. Indikator Aturan (skor risiko lokal)")
        card(body, "3.0 // RIWAYAT ANALISIS & PENYIMPANAN", "Penyimpanan Lokal: Data diisolasi di SQLite privat perangkat. Tidak ada transmisi isi pesan ke cloud eksternal atau database pihak ketiga.")
        card(body, "4.0 // BATASAN DETEKSI & TANGGUNG JAWAB", "Skor risiko tinggi merupakan indikator anomali berdasarkan kata kunci dan pola, bukan pembuktian hukum mutlak. Evaluasi bergantung pada kejelasan cuplikan notifikasi.")
        card(body, "5.0 // KONTROL PRIVASI PENGGUNA", "Pengguna dapat mengelola filter sumber notifikasi, mengubah pengirim tepercaya, dan menghapus seluruh riwayat kapan saja.")

        action(body, "Kembali ke Pengaturan", { showSettings() })
    }

    // =========================================================================
    // 12. TENTANG & METODE DETEKSI (DENGAN SIMULATOR BOBOT 6 ATURAN INTERAKTIF)
    // =========================================================================
    private fun showDetectionMethods() {
        val body = createPage("Metode Deteksi", "Transparansi cara kerja Rule-Based Risk Scoring tanpa algoritma terselubung.")
        val headerCard = card(body, "Sistem Penilaian Deterministik", "Sistem memeriksa 6 indikator statis dan menjumlahkan bobot risiko secara modular:")

        // Interactive 6 rules simulation checkboxes
        val rules = listOf(
            Triple("Keyword mencurigakan", 2, "Kata kunci 'TERBLOKIR', 'hadiah', 'verifikasi'"),
            Triple("URL di luar whitelist resmi", 3, "Domain tidak terdaftar di direktori resmi"),
            Triple("Penggunaan tautan singkat", 2, "Shortlink obscuration (bit.ly, s.id, tinyurl)"),
            Triple("Pengirim tak terverifikasi", 2, "Nomor baru / bukan pengirim tepercaya"),
            Triple("Tekanan urgensi waktu", 1, "Frasa psikologis ('1x24 jam', 'segera')"),
            Triple("Permintaan data sensitif", 3, "Eksfiltrasi kredensial (OTP, PIN, Password)")
        )

        val checkBoxes = mutableListOf<Pair<CheckBox, Int>>()
        val scoreDisplay = TextView(this).apply {
            textSize = 24f
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            setTextColor(green)
            setPadding(0, dp(6), 0, dp(4))
        }
        val formulaDisplay = TextView(this).apply {
            textSize = 12f
            typeface = Typeface.MONOSPACE
            setTextColor(muted)
            setPadding(0, 0, 0, dp(8))
        }

        fun updateLiveSimulator() {
            var total = 0
            val parts = mutableListOf<String>()
            checkBoxes.forEach { (cb, pts) ->
                if (cb.isChecked) {
                    total += pts
                    parts += "+$pts"
                } else {
                    parts += "+0"
                }
            }
            val status = when {
                total >= 6 -> "PHISHING (Risiko Tinggi)"
                total >= 3 -> "MENCURIGAKAN (Risiko Sedang)"
                else -> "AMAN (Risiko Rendah)"
            }
            val color = when {
                total >= 6 -> red
                total >= 3 -> amber
                else -> green
            }
            scoreDisplay.text = "SKOR: $total • $status"
            scoreDisplay.setTextColor(color)
            formulaDisplay.text = "Formula: ${parts.joinToString(" ")} = $total / 13"
        }

        rules.forEach { (label, points, desc) ->
            val cb = CheckBox(this).apply {
                text = "$label (+$points Poin)\n$desc"
                setTextColor(pearl)
                textSize = 12.5f
                setPadding(dp(4), dp(4), dp(4), dp(6))
                setOnCheckedChangeListener { _, _ -> updateLiveSimulator() }
            }
            headerCard.addView(cb)
            checkBoxes.add(cb to points)
        }

        headerCard.addView(scoreDisplay)
        headerCard.addView(formulaDisplay)
        updateLiveSimulator()

        val btnRow = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        val bAll = Button(this).apply {
            text = "Pilih Semua (Skor 13)"
            textSize = 11.5f
            isAllCaps = false
            maxLines = 2
            minHeight = dp(48)
            gravity = Gravity.CENTER
            setTextColor(cosmic)
            background = GradientDrawable().apply { setColor(cyan); cornerRadius = dp(8).toFloat() }
            setOnClickListener { checkBoxes.forEach { it.first.isChecked = true } }
        }
        val bReset = Button(this).apply {
            text = "Reset (Skor 0)"
            textSize = 11.5f
            isAllCaps = false
            maxLines = 2
            minHeight = dp(48)
            gravity = Gravity.CENTER
            setTextColor(pearl)
            background = GradientDrawable().apply { setColor(Color.rgb(38, 44, 76)); cornerRadius = dp(8).toFloat() }
            setOnClickListener { checkBoxes.forEach { it.first.isChecked = false } }
        }
        val bLp = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply { marginEnd = dp(6) }
        val bLp2 = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply { marginStart = dp(6) }
        btnRow.addView(bAll, bLp)
        btnRow.addView(bReset, bLp2)
        headerCard.addView(btnRow)

        // Threshold explanation card
        card(body, "Ambang Batas Klasifikasi",
            "• AMAN: Skor 0–2 (Risiko rendah, pola pesan wajar)\n" +
            "• MENCURIGAKAN: Skor 3–5 (Ada indikator anomali, perlu verifikasi)\n" +
            "• PHISHING: Skor ≥6 (Risiko kritis, indikasi kuat rekayasa sosial)\n\n" +
            "Maksimum skor adalah 13 apabila keenam indikator terpenuhi bersamaan.")

        action(body, "Buka Pusat Bantuan & FAQ", { showHelpFaq() }, false)
        action(body, "Kembali ke Pengaturan", { showSettings() })
    }

    // =========================================================================
    // 13. PENGATURAN (SETTINGS)
    // =========================================================================
    private fun showSettings() {
        val body = createPage("Pengaturan", "Atur pengalaman dan keamanan aplikasimu.")

        val isEnabled = simulatedNotificationAccess || AppPrefs.notificationAccessEnabled(this)
        val accessCard = card(body, "Akses Notifikasi Android",
            if (isEnabled) "Akses listener notifikasi aktif [Mode Demo / OS Connected]."
            else "Akses listener notifikasi belum diizinkan. Aktifkan agar sistem dapat membaca pratinjau pesan.",
            if (isEnabled) green else amber
        )
        action(body, "Panduan & Pengaturan Akses Android", { showNotificationGuide() }, false)

        text(body, "SUMBER NOTIFIKASI", 14f, pearl, true, top = 8, bottom = 4)
        val prefs = getSharedPreferences(AppPrefs.PREFS, MODE_PRIVATE)
        val wa = CheckBox(this).apply { text = "WhatsApp Messenger & Business"; setTextColor(pearl); isChecked = prefs.getBoolean(AppPrefs.KEY_INCLUDE_WHATSAPP, true) }
        val sms = CheckBox(this).apply { text = "Aplikasi SMS Bawaan"; setTextColor(pearl); isChecked = prefs.getBoolean(AppPrefs.KEY_INCLUDE_SMS, true) }
        body.addView(wa); body.addView(sms)

        text(body, "PENGIRIM TEPERCAYA", 14f, pearl, true, top = 8, bottom = 4)
        text(body, "Masukkan satu identitas/nomor per baris. Pengirim di luar daftar mendapat indikator (+2).", 11.5f, muted)
        val trusted = input(body, "Contoh:\n08123456789\nBank Mandiri Resmi", multiline = true)
        trusted.setText(prefs.getString(AppPrefs.KEY_TRUSTED_SENDERS, ""))

        text(body, "INTEGRASI DATA (RULES API)", 14f, pearl, true, top = 8, bottom = 4)
        text(body, if (BuildConfig.DEBUG)
            "Base URL untuk aturan dan akun. Emulator Android memakai http://10.0.2.2:8000; ponsel memakai alamat IP LAN komputer. Isi pesan tidak dikirim ke API."
        else
            "Base URL API produksi. Build rilis hanya menerima HTTPS. Isi pesan tidak dikirim ke API.", 11.5f, muted)
        val apiUrl = input(body, if (BuildConfig.DEBUG) AppPrefs.DEFAULT_API_URL else "https://api.example.com")
        apiUrl.setText(AppPrefs.apiBaseUrl(this))

        action(body, "Simpan Pengaturan & Sinkronkan Aturan", {
            prefs.edit()
                .putBoolean(AppPrefs.KEY_INCLUDE_WHATSAPP, wa.isChecked)
                .putBoolean(AppPrefs.KEY_INCLUDE_SMS, sms.isChecked)
                .putString(AppPrefs.KEY_TRUSTED_SENDERS, trusted.text.toString())
                .putString(AppPrefs.KEY_API_URL, apiUrl.text.toString().trim())
                .apply()
            val url = apiUrl.text.toString().trim()
            if (url.isBlank()) {
                Toast.makeText(this, "Pengaturan tersimpan. Aturan lokal digunakan.", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Menghubungkan ke API...", Toast.LENGTH_SHORT).show()
                Thread {
                    try {
                        val response = ApiClient.fetchRules(url)
                        RuleConfigStore.save(this, response.raw)
                        runOnUiThread {
                            Toast.makeText(this, "Aturan API ${response.config.version} berhasil disinkronkan!", Toast.LENGTH_LONG).show()
                        }
                    } catch (e: Exception) {
                        runOnUiThread {
                            Toast.makeText(this, "Gagal sinkron API: ${e.message}. Aturan lokal tetap aktif.", Toast.LENGTH_LONG).show()
                        }
                    }
                }.start()
            }
        })

        text(body, "NAVIGASI INFORMASI & DOKUMENTASI", 14f, pearl, true, top = 10, bottom = 4)
        action(body, "Tentang & Metode Deteksi (Simulator Bobot)", { showDetectionMethods() }, false)
        action(body, "Pusat Bantuan & FAQ", { showHelpFaq() }, false)
        action(body, "Privasi dan Penggunaan Data", { showPrivacyData() }, false)

        action(body, "Hapus Semua Riwayat Analisis Lokal", {
            AlertDialog.Builder(this).setTitle("Hapus seluruh riwayat?")
                .setMessage("Tindakan ini menghapus seluruh riwayat analisis dari database lokal.")
                .setNegativeButton("Batal", null)
                .setPositiveButton("Hapus") { _, _ ->
                    LocalDatabase(this).use { it.clear() }
                    Toast.makeText(this, "Riwayat lokal berhasil dibersihkan.", Toast.LENGTH_SHORT).show()
                }.show()
        }, false, danger = true)

        text(body, "MIVVI SECURE • PROTOTYPE 1.0 • ANDROID EDITION", 9.5f, cyan, top = 14)
    }

    private fun openNotificationAccess() {
        try {
            startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
        } catch (_: Exception) {
            Toast.makeText(this, "Pengaturan Akses Notifikasi tidak dapat dibuka pada emulator/perangkat ini.", Toast.LENGTH_LONG).show()
        }
    }

    // =========================================================================
    // HELPER CARDS & DATABASE
    // =========================================================================
    private fun recordCard(parent: LinearLayout, record: AnalysisRecord, onClick: (() -> Unit)? = null) {
        val color = when (record.category) { "PHISHING" -> red; "MENCURIGAKAN" -> amber; else -> green }
        val box = card(parent, "${record.source} • ${record.category}", record.sender.ifBlank { "Pengirim tidak tersedia" })
        val stamp = SimpleDateFormat("dd MMM yyyy, HH:mm", Locale("id", "ID")).format(Date(record.receivedAt))
        text(box, if (record.body.isBlank()) "Konten notifikasi tidak tersedia (Pratinjau privat)" else record.body.take(120), 12f, muted, top = 4)
        text(box, "Skor ${record.score}/13 • $stamp${if (record.isDemo) " • DEMO" else ""}", 9.5f, color, true, bottom = 0)
        box.setOnClickListener {
            if (onClick != null) onClick()
            else {
                if (record.body.isBlank()) showHiddenContentDetail(record)
                else showRecordDetail(record)
            }
        }
        box.isClickable = true
    }

    private fun formatTime(time: Long): String = SimpleDateFormat("dd MMM yyyy, HH:mm", Locale("id", "ID")).format(Date(time))
    private fun dbCount(): Int = LocalDatabase(this).use { it.count() }
    private fun dbHighRisk(): Int = LocalDatabase(this).use { it.highRiskCount() }
    private fun dbRecent(limit: Int): List<AnalysisRecord> = LocalDatabase(this).use { it.recent(limit) }
}
