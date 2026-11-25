# MIVVI SECURE

**Your messages. Your safety. — Kenali risiko. Lindungi dirimu.**

MIVVI SECURE adalah prototipe aplikasi Android yang membantu pengguna mengenali indikasi phishing pada pesan SMS dan WhatsApp. Aplikasi menganalisis teks yang tersedia pada notifikasi atau teks yang dimasukkan secara manual, lalu menampilkan skor dan kategori risiko.

Metode deteksi yang digunakan adalah **Rule-Based Risk Scoring**. Sistem tidak menggunakan machine learning atau model AI. Analisis pesan dilakukan di perangkat Android. Backend FastAPI menyediakan konfigurasi aturan dan layanan akun untuk registrasi/login.

> **Status proyek:** source code Android dan backend API tersedia. APK debug tidak dilacak di repository; build lokal menghasilkan `app/build/outputs/apk/debug/app-debug.apk`.

## Daftar Isi

1. [Latar Belakang](#1-latar-belakang)
2. [Rumusan Masalah](#2-rumusan-masalah)
3. [Tujuan dan Manfaat](#3-tujuan-dan-manfaat)
4. [Konsep dan Ruang Lingkup](#4-konsep-dan-ruang-lingkup)
5. [Fitur Aplikasi](#5-fitur-aplikasi)
6. [Arsitektur dan Alur Kerja Sistem](#6-arsitektur-dan-alur-kerja-sistem)
7. [Sepuluh Proses Komputasi pada Perangkat Mobile](#7-sepuluh-proses-komputasi-pada-perangkat-mobile)
8. [Algoritma Rule-Based Risk Scoring](#8-algoritma-rule-based-risk-scoring)
9. [Preprocessing dan Ekstraksi Fitur](#9-preprocessing-dan-ekstraksi-fitur)
10. [Integrasi SMS, WhatsApp, dan Jaringan Wireless](#10-integrasi-sms-whatsapp-dan-jaringan-wireless)
11. [Rules API](#11-rules-api)
12. [Database dan Riwayat Analisis](#12-database-dan-riwayat-analisis)
13. [Panduan Halaman Aplikasi](#13-panduan-halaman-aplikasi)
14. [Teknologi dan Struktur Proyek](#14-teknologi-dan-struktur-proyek)
15. [Instalasi dan Menjalankan Aplikasi](#15-instalasi-dan-menjalankan-aplikasi)
16. [Pengujian dan Status Implementasi](#16-pengujian-dan-status-implementasi)
17. [Privasi, Keamanan, dan Batasan](#17-privasi-keamanan-dan-batasan)
18. [Pengembangan Selanjutnya](#18-pengembangan-selanjutnya)

---

## 1. Latar Belakang

Phishing melalui pesan singkat atau chat merupakan bentuk penipuan digital yang memanfaatkan pesan untuk mendorong korban melakukan tindakan tertentu, misalnya membuka tautan, mengirimkan kode OTP, atau memberikan informasi pribadi. Pesan dapat dibuat seolah-olah berasal dari bank, layanan digital, operator, atau instansi resmi. Pelaku juga dapat menggunakan kalimat mendesak, ancaman pemblokiran akun, hadiah palsu, dan tautan pendek untuk memengaruhi korban.

Pengguna tidak selalu dapat membedakan pesan asli dan pesan phishing secara manual. Oleh karena itu, MIVVI SECURE dirancang sebagai prototipe pendamping yang memeriksa sejumlah karakteristik pesan dan menyajikan tingkat risiko beserta alasan pendeteksiannya.

Contoh pesan uji:

> Info: Rek Anda TERBLOKIR. Segera verifikasi dan klik bit.ly/verif-akun24 dalam 1x24 jam agar tidak hangus. Masukkan kode OTP Anda.

Contoh tersebut memuat beberapa karakteristik yang dapat diperiksa, seperti kata kunci mencurigakan, domain tautan di luar whitelist, shortlink, pengirim yang belum dikenal, pola urgensi, dan permintaan data sensitif.

## 2. Rumusan Masalah

1. Bagaimana mengenali indikasi phishing pada pesan SMS dan WhatsApp?
2. Karakteristik apa saja yang dapat digunakan sebagai indikator risiko pesan?
3. Bagaimana menghitung skor dan mengelompokkan pesan ke dalam kategori AMAN, MENCURIGAKAN, atau PHISHING?
4. Bagaimana menjalankan proses analisis secara lokal pada perangkat mobile dengan memanfaatkan notifikasi yang diizinkan pengguna?

## 3. Tujuan dan Manfaat

### Tujuan

- Merancang prototipe deteksi phishing menggunakan pendekatan Rule-Based Risk Scoring.
- Memeriksa indikator berupa keyword, URL, shortlink, identitas pengirim, pola urgensi, dan permintaan data sensitif.
- Menghasilkan skor, kategori risiko, serta penjelasan indikator yang terdeteksi.
- Menjalankan proses analisis pada perangkat Android tanpa mengirim isi pesan ke backend.

### Manfaat yang diharapkan

- Membantu pengguna lebih waspada ketika menerima pesan yang memiliki karakteristik phishing.
- Memberikan alasan yang lebih jelas daripada sekadar label aman atau berbahaya.
- Menjadi prototipe awal untuk pembelajaran penerapan algoritma keamanan pada perangkat mobile.

MIVVI SECURE merupakan alat bantu identifikasi indikasi risiko, bukan pengganti kewaspadaan pengguna maupun verifikasi melalui kanal resmi.

## 4. Konsep dan Ruang Lingkup

Konsep utama MIVVI SECURE adalah **analisis berbasis aturan yang berjalan di perangkat**. Setiap pesan diperiksa berdasarkan enam indikator. Jika suatu indikator terpenuhi, bobotnya ditambahkan ke skor risiko. Skor akhir dibandingkan dengan ambang kategori.

Ruang lingkup implementasi saat ini:

- Platform: Android, dengan minimum API 26 (Android 8.0).
- Sumber pesan: teks yang dimasukkan melalui Analisis Manual dan pratinjau notifikasi dari aplikasi SMS/WhatsApp yang didukung.
- Metode: pencocokan pola dan perhitungan skor deterministik.
- Penyimpanan: SQLite lokal pada perangkat.
- Sinkronisasi: pengambilan konfigurasi aturan dari Rules API opsional.
- Autentikasi akun Android: registrasi dengan OTP email, login, pemulihan kata sandi dengan OTP email, sesi bearer yang dapat dicabut, dan logout menggunakan backend FastAPI.

Di luar ruang lingkup: membaca database privat WhatsApp, mengambil seluruh SMS melalui database sistem, mencegat isi pesan sebelum diterima aplikasi sumber, memblokir atau menghapus pesan otomatis, dan menjamin bahwa semua pesan yang dikategorikan AMAN benar-benar aman.

## 5. Fitur Aplikasi

### 5.1 Analisis Manual

Pengguna dapat menempelkan atau mengetik teks pesan, mengisi identitas pengirim secara opsional, lalu menjalankan analisis. Fitur ini berguna untuk menguji contoh pesan atau memeriksa teks yang diterima dari sumber lain.

### 5.2 Pemantauan Notifikasi

Dengan izin Notification Access yang diaktifkan sendiri oleh pengguna, aplikasi menerima event notifikasi dari paket SMS dan WhatsApp yang didukung. Aplikasi mencoba mengambil teks pratinjau yang disediakan Android. Jika isi pesan tidak tersedia, sistem hanya menyimpan metadata notifikasi dengan status konten tidak tersedia.

### 5.3 Hasil Analisis

Hasil menampilkan skor risiko, kategori, tingkat risiko, indikator yang terdeteksi, dan penjelasan singkat. Setiap indikator hanya menyumbang bobot satu kali per pesan.

### 5.4 Aktivitas Notifikasi dan Riwayat

Aktivitas menampilkan catatan notifikasi yang diterima. Riwayat menyimpan hasil analisis agar pengguna dapat melihat kembali pesan dan hasil sebelumnya. Data disimpan di database lokal.

### 5.5 Pengirim Tepercaya

Pengguna dapat mengelola daftar pengirim yang dianggap tepercaya. Identitas pengirim yang tersedia dibandingkan dengan daftar lokal tersebut. Daftar ini bukan verifikasi identitas resmi dan tidak otomatis membaca seluruh kontak perangkat.

### 5.6 Edukasi Keamanan

Halaman edukasi menyajikan materi pengenalan phishing, tautan mencurigakan, pola urgensi, dan permintaan data sensitif sebagai pendamping hasil analisis.

### 5.7 Pengaturan dan Sinkronisasi Aturan

Pengguna dapat memilih sumber notifikasi SMS/WhatsApp, mengelola pengirim tepercaya, mengatur alamat Rules API, dan menyinkronkan konfigurasi deteksi.

### 5.8 Login dan Registrasi

Login dan registrasi Android terhubung ke Rules API melalui `/api/v1/auth`. Akun baru harus memasukkan OTP enam digit yang dikirim ke email sebelum sesi dibuat. Halaman Forgot Password meminta OTP email; konfirmasi kode mengganti hash kata sandi dan mencabut sesi lama. Password disimpan sebagai hash scrypt di SQLite backend; token sesi disimpan terenkripsi menggunakan Android Keystore. Ikon akun pada header membuka halaman Akun Pribadi; login tetap opsional karena pengguna juga dapat melanjutkan sebagai tamu. Pengiriman OTP memerlukan konfigurasi SMTP di server (`MIVVI_SMTP_HOST`, `MIVVI_SMTP_PORT`, `MIVVI_SMTP_USER`, `MIVVI_SMTP_PASSWORD`, opsional `MIVVI_SMTP_FROM`).

Untuk emulator Android, base URL backend default adalah `http://10.0.2.2:8000`. Untuk ponsel fisik, gunakan alamat IP LAN komputer yang menjalankan backend.

## 6. Arsitektur dan Alur Kerja Sistem

### 6.1 Alur analisis notifikasi

```text
Notifikasi SMS / WhatsApp
          |
          v
NotificationListenerService
          |
          v
Filter paket dan preferensi sumber
          |
          v
Parsing metadata dan teks pratinjau
          |
          v
Preprocessing teks dan ekstraksi fitur
          |
          v
Rule-Based Risk Scoring
          |
          v
Klasifikasi berdasarkan threshold
          |
          v
Hasil pada aplikasi + penyimpanan SQLite lokal
```

Jika teks pratinjau tidak tersedia, proses analisis tidak dipaksakan. Sistem menyimpan catatan notifikasi tanpa membuat isi pesan atau skor palsu.

### 6.2 Alur analisis manual

```text
Pengguna memasukkan teks dan pengirim (opsional)
          |
          v
RuleBasedAnalyzer
          |
          v
Preprocessing dan pemeriksaan enam indikator
          |
          v
Perhitungan skor dan klasifikasi
          |
          v
Halaman hasil analisis
          |
          v
Penyimpanan riwayat lokal
```

### 6.3 Komponen utama

- `MainActivity`: antarmuka, navigasi, analisis manual, hasil, aktivitas, riwayat, edukasi, dan pengaturan.
- `NotificationMonitorService`: menerima dan memfilter notifikasi dari paket sumber yang didukung.
- `RuleBasedAnalyzer`: preprocessing, ekstraksi fitur, pencocokan aturan, penghitungan skor, dan klasifikasi.
- `RuleConfigStore`: memuat konfigurasi default atau konfigurasi yang telah disinkronkan.
- `ApiClient`: mengambil konfigurasi dari server.
- `LocalDatabase`: menyimpan dan membaca riwayat analisis menggunakan SQLite.
- `AppPrefs`: menyimpan preferensi sumber notifikasi, alamat API, dan daftar pengirim tepercaya.

## 7. Sepuluh Proses Komputasi pada Perangkat Mobile

Bagian ini merinci sepuluh proses komputasi yang dilakukan oleh aplikasi Android. Proses berikut dipetakan dari implementasi Kotlin yang tersedia, bukan klaim fitur yang belum dibuat.

### Proses 1 — Filter Sumber Notifikasi

- **Compute:** memeriksa package name notifikasi untuk menentukan apakah sumber termasuk aplikasi SMS atau WhatsApp yang didukung, lalu memeriksa preferensi sumber pengguna.
- **Algoritma:** pencocokan keanggotaan himpunan (set membership) dan pemeriksaan kondisi.
- **Cara kerja:** sistem memeriksa package name terhadap daftar paket SMS dan WhatsApp. Notifikasi dari sumber lain atau sumber yang dinonaktifkan pengguna dilewati. Ringkasan grup notifikasi juga dilewati.
- **Alasan:** membatasi pemrosesan pada sumber yang relevan dan menghindari analisis notifikasi aplikasi lain.

### Proses 2 — Parsing Notifikasi

- **Compute:** mengambil judul, subteks, teks, big text, waktu notifikasi, dan informasi pengirim yang tersedia.
- **Algoritma:** ekstraksi field berdasarkan prioritas sumber data notifikasi.
- **Cara kerja:** sistem mencoba memperoleh isi dari `MessagingStyle`, `EXTRA_BIG_TEXT`, atau `EXTRA_TEXT`. Pengirim diambil dari informasi pesan, judul, atau subteks sesuai ketersediaannya. Ringkasan seperti “2 new messages” tidak dianggap sebagai isi pesan.
- **Alasan:** format notifikasi setiap aplikasi dapat berbeda sehingga sistem perlu mengambil informasi yang benar-benar disediakan Android.

### Proses 3 — Normalisasi dan Tokenisasi Teks

- **Compute:** menyeragamkan teks sebelum pencocokan pola dan memecah teks menjadi token.
- **Algoritma:** case folding, normalisasi whitespace, substitusi karakter umum, dan pemisahan token menggunakan regular expression.
- **Cara kerja:** teks diubah menjadi huruf kecil, spasi berlebih dirapikan, dan substitusi terbatas seperti `kl1k` menjadi `klik` dilakukan pada pola karakter tertentu. Teks kemudian dipisahkan berdasarkan karakter selain huruf dan angka.
- **Alasan:** variasi huruf besar-kecil, spasi, dan penyamaran karakter sederhana tidak langsung menggagalkan pencocokan.

### Proses 4 — Pencocokan Keyword Mencurigakan

- **Compute:** mencari satu atau lebih keyword/pola frasa yang telah dikonfigurasi.
- **Algoritma:** Aho–Corasick multi-pattern string matching.
- **Cara kerja:** struktur trie dan failure link dibangun dari daftar keyword. Teks diperiksa untuk menemukan pola yang cocok. Hasil duplikat disaring sehingga indikator keyword hanya dihitung satu kali.
- **Alasan:** beberapa pola dapat dicari dalam satu alur pemindaian teks dan prosesnya deterministik.

### Proses 5 — Ekstraksi URL dan Hostname

- **Compute:** menemukan kandidat URL pada teks dan mengambil hostname dari URL yang valid.
- **Algoritma:** regular expression untuk ekstraksi URL dan parsing URI untuk memperoleh host.
- **Cara kerja:** pola URL seperti `https://...`, `www...`, dan domain dengan ekstensi yang didukung dicari. Karakter tanda baca di ujung tautan dibersihkan, kemudian host diambil dan diseragamkan.
- **Alasan:** pemeriksaan domain memerlukan hostname, bukan hanya keberadaan kata atau tautan dalam pesan.

### Proses 6 — Pemeriksaan Whitelist Domain dan Shortlink

- **Compute:** menentukan apakah host berada di whitelist domain resmi dan apakah host termasuk domain shortlink yang dikenal.
- **Algoritma:** pencocokan domain tepat atau subdomain terhadap daftar konfigurasi.
- **Cara kerja:** host dibandingkan dengan daftar domain resmi. Domain dianggap cocok jika sama persis atau merupakan subdomain yang valid. Host juga diperiksa terhadap daftar shortlink seperti `bit.ly` dan `tinyurl.com`.
- **Alasan:** tautan di luar whitelist dan shortlink merupakan indikator tambahan yang dapat meningkatkan skor risiko. Pemeriksaan ini bukan validasi reputasi URL secara online.

### Proses 7 — Normalisasi dan Pemeriksaan Pengirim

- **Compute:** menyeragamkan identitas pengirim dan membandingkannya dengan daftar pengirim tepercaya lokal.
- **Algoritma:** normalisasi string dan pencarian keanggotaan pada set.
- **Cara kerja:** huruf dibuat kecil, karakter pemisah dihapus, dan awalan nomor Indonesia `+62` atau `62` diseragamkan menjadi format `0`. Jika pengirim tersedia tetapi tidak ditemukan dalam daftar tepercaya, indikator pengirim tidak dikenal aktif. Jika identitas kosong, indikator tidak dihitung.
- **Alasan:** format nomor dapat berbeda, sedangkan pengirim yang tidak tersedia tidak boleh otomatis dianggap tidak dikenal.

### Proses 8 — Deteksi Pola Urgensi

- **Compute:** memeriksa frasa yang menunjukkan tekanan waktu atau dorongan untuk segera bertindak.
- **Algoritma:** pencocokan substring terhadap daftar pola urgensi setelah normalisasi.
- **Cara kerja:** sistem memeriksa pola seperti “segera”, “1x24 jam”, “batas waktu”, dan “sebelum terlambat”. Jika satu atau lebih pola ditemukan, indikator urgensi aktif satu kali.
- **Alasan:** pesan phishing sering menggunakan tekanan waktu untuk mendorong korban bertindak tanpa verifikasi.

### Proses 9 — Deteksi Permintaan Data Sensitif

- **Compute:** memeriksa pola yang berkaitan dengan OTP, PIN, password, kata sandi, nomor kartu, CVV, atau kode verifikasi.
- **Algoritma:** pencocokan substring terhadap daftar pola data sensitif.
- **Cara kerja:** teks yang telah dinormalisasi dibandingkan dengan daftar pola. Jika satu atau lebih pola terdeteksi, indikator data sensitif aktif satu kali.
- **Alasan:** permintaan informasi autentikasi atau keuangan merupakan sinyal risiko yang perlu diperhatikan pengguna.

### Proses 10 — Weighted Scoring dan Klasifikasi

- **Compute:** menjumlahkan bobot indikator aktif dan menentukan kategori akhir.
- **Algoritma:** weighted rule-based scoring dan threshold classification.
- **Cara kerja:** bobot setiap indikator yang terdeteksi dijumlahkan. Skor dibandingkan dengan ambang: di bawah 3 = AMAN, 3 sampai kurang dari 6 = MENCURIGAKAN, dan 6 atau lebih = PHISHING. Hasil berisi skor, kategori, tingkat risiko, rincian indikator, URL yang ditemukan, dan versi aturan.
- **Alasan:** metode ini sederhana, dapat dijelaskan, deterministik, dan sesuai untuk prototipe komputasi lokal.

**Catatan:** penyimpanan hasil ke SQLite dan penampilan pada antarmuka merupakan tahap keluaran/persistensi setelah proses analisis, bukan indikator tambahan dalam sepuluh proses di atas.

## 8. Algoritma Rule-Based Risk Scoring

### 8.1 Indikator dan bobot

| Indikator | Kondisi | Bobot |
|---|---|---:|
| Keyword mencurigakan | Terdapat keyword atau frasa dari daftar deteksi | +2 |
| URL di luar whitelist | Terdapat hostname yang tidak cocok dengan whitelist domain | +3 |
| Shortlink | Terdapat hostname yang cocok dengan daftar shortlink | +2 |
| Pengirim tidak dikenal | Identitas pengirim tersedia tetapi tidak ada di daftar tepercaya lokal | +2 |
| Pola urgensi | Terdapat pola yang mendorong tindakan segera | +1 |
| Permintaan data sensitif | Terdapat pola seperti OTP, PIN, password, atau data kartu | +3 |

### 8.2 Ambang klasifikasi

- **AMAN:** skor 0–2.
- **MENCURIGAKAN:** skor 3–5.
- **PHISHING:** skor 6 atau lebih.

### 8.3 Aturan penghitungan

Setiap indikator menyumbang bobot maksimal satu kali untuk satu pesan, walaupun beberapa pola dalam indikator yang sama ditemukan. Contohnya, beberapa keyword mencurigakan tetap menghasilkan +2, bukan kelipatan +2. Jika identitas pengirim tidak tersedia, indikator pengirim tidak dihitung.

### 8.4 Contoh perhitungan

Pesan contoh pada bagian latar belakang memenuhi keenam indikator:

- Keyword mencurigakan: +2
- URL di luar whitelist: +3
- Shortlink: +2
- Pengirim tidak dikenal: +2
- Pola urgensi: +1
- Permintaan data sensitif: +3

**Total skor = 2 + 3 + 2 + 2 + 1 + 3 = 13.** Karena 13 lebih besar atau sama dengan 6, hasilnya adalah **PHISHING (Risiko Tinggi)**.

Skor 13 adalah hasil maksimum dari keenam indikator default yang masing-masing dihitung satu kali.

### 8.5 Pseudocode

```text
INPUT: message, sender, trusted_senders
score = 0

normalize message and sender
extract URLs and hostnames

IF suspicious keyword found:
    score += 2
IF any URL host is outside official whitelist:
    score += 3
IF any URL host matches known shortlink list:
    score += 2
IF sender is available and not in trusted_senders:
    score += 2
IF urgency pattern found:
    score += 1
IF sensitive-data pattern found:
    score += 3

IF score >= 6:
    category = PHISHING
ELSE IF score >= 3:
    category = MENCURIGAKAN
ELSE:
    category = AMAN

OUTPUT: score, category, detected features, explanations
```

## 9. Preprocessing dan Ekstraksi Fitur

Preprocessing dilakukan agar teks lebih seragam sebelum diperiksa:

1. **Case folding:** mengubah huruf menjadi huruf kecil.
2. **Normalisasi spasi:** merapikan spasi atau baris baru berlebih.
3. **Normalisasi karakter terbatas:** mengganti beberapa substitusi umum di antara huruf, misalnya `kl1k` menjadi `klik`.
4. **Tokenisasi:** memisahkan teks menjadi token berdasarkan karakter nonhuruf dan nonangka.
5. **Ekstraksi URL:** mengambil kandidat tautan menggunakan regex, kemudian parsing host.
6. **Normalisasi pengirim:** menyeragamkan karakter identitas dan format awalan nomor Indonesia.

Pencocokan keyword menggunakan Aho–Corasick. Pola urgensi dan data sensitif diperiksa dengan pencocokan substring terhadap daftar konfigurasi. Metode ini berbasis aturan; ia tidak memahami konteks bahasa secara penuh. Karena itu, hasil dapat berupa false positive atau false negative.

## 10. Integrasi SMS, WhatsApp, dan Jaringan Wireless

### SMS

SMS diterima perangkat melalui layanan jaringan seluler. Pada implementasi ini, MIVVI SECURE tidak menjadi aplikasi SMS default dan tidak membaca database SMS melalui izin `READ_SMS` atau `RECEIVE_SMS`. Aplikasi memanfaatkan notifikasi dari aplikasi SMS yang didukung setelah pengguna memberikan Notification Access.

### WhatsApp

WhatsApp mengirimkan notifikasi melalui koneksi internet, baik data seluler maupun Wi-Fi. MIVVI SECURE memanfaatkan notifikasi WhatsApp/WhatsApp Business yang ditampilkan Android. Aplikasi tidak terhubung ke database privat WhatsApp dan tidak memakai companion bot atau sesi WhatsApp terpisah.

### Kaitan dengan Mobile & Wireless Computing

- SMS dan WhatsApp memanfaatkan jalur komunikasi wireless yang berbeda: layanan seluler untuk SMS dan koneksi data untuk WhatsApp.
- Event notifikasi diterima pada perangkat Android.
- Ekstraksi fitur, pencocokan aturan, penghitungan skor, dan klasifikasi dilakukan secara lokal di perangkat.
- Rules API hanya mendistribusikan konfigurasi aturan; API bukan jalur pengiriman pesan untuk dianalisis.
- Analisis lokal mengurangi ketergantungan pada koneksi internet saat proses pemeriksaan pesan. Sinkronisasi konfigurasi tetap membutuhkan jaringan.

### Izin Android

- `BIND_NOTIFICATION_LISTENER_SERVICE`: dideklarasikan oleh service dan diaktifkan pengguna melalui pengaturan Android.
- `INTERNET`: digunakan untuk sinkronisasi Rules API opsional.
- Aplikasi tidak meminta izin `READ_SMS`, `RECEIVE_SMS`, `READ_CONTACTS`, kamera, mikrofon, atau lokasi.

## 11. Rules API

Backend FastAPI menyediakan konfigurasi aturan dan endpoint autentikasi akun. API bukan mesin analisis pesan.

### Endpoint

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/api/v1/health` | Memeriksa status layanan |
| GET | `/api/v1/rules` | Mengambil konfigurasi aturan deteksi |
| POST | `/api/v1/auth/register` | Membuat akun menunggu verifikasi dan mengirim OTP email |
| POST | `/api/v1/auth/verify-email` | Memverifikasi OTP dan membuat sesi |
| POST | `/api/v1/auth/resend-verification` | Mengirim ulang OTP akun yang belum diverifikasi |
| POST | `/api/v1/auth/login` | Memverifikasi akun dan membuat sesi |
| POST | `/api/v1/auth/password-reset/request` | Meminta OTP reset kata sandi melalui email |
| POST | `/api/v1/auth/password-reset/confirm` | Mengganti kata sandi dengan OTP yang valid |
| GET | `/api/v1/auth/me` | Membaca profil akun dari token bearer |
| POST | `/api/v1/auth/logout` | Mencabut sesi bearer |

Konfigurasi berisi:

- `version`: versi aturan.
- `weights`: bobot keenam indikator.
- `thresholds`: batas kategori MENCURIGAKAN dan PHISHING.
- `keywords`: daftar keyword mencurigakan.
- `urgency_patterns`: daftar pola urgensi.
- `sensitive_patterns`: daftar pola data sensitif.
- `official_domains`: whitelist domain.
- `shortlink_domains`: daftar domain shortlink.

Android mengambil konfigurasi dengan request `GET /api/v1/rules`, mem-parsing JSON, lalu menyimpan konfigurasi di `SharedPreferences`. Jika API tidak tersedia atau konfigurasi gagal dibaca, aplikasi menggunakan aturan default lokal.

**Batas data:** API autentikasi menerima nama, email, dan password saat registrasi/login. Password disimpan sebagai hash. API tidak menerima isi pesan, nomor/identitas pengirim, payload notifikasi, atau riwayat analisis; konfigurasi aturan dikirim ke aplikasi.

## 12. Database dan Riwayat Analisis

Aplikasi menggunakan SQLite melalui `SQLiteOpenHelper` dengan nama database `mivvi_secure.db` dan tabel `analyses`. Kolom yang disimpan meliputi:

- ID catatan.
- Sumber pesan (SMS/WhatsApp/manual sesuai alur aplikasi).
- Identitas pengirim yang tersedia.
- Isi pesan jika tersedia.
- Waktu notifikasi/analisis.
- Skor dan kategori.
- Rincian fitur yang terdeteksi.
- Penanda data demo.
- Package name sumber notifikasi.

Database berada pada penyimpanan privat aplikasi. **Database lokal belum dienkripsi secara khusus oleh implementasi ini.** Pengguna dapat melihat dan menghapus riwayat melalui antarmuka aplikasi. Jangan gunakan pesan pribadi atau sensitif sebagai data demonstrasi publik.

## 13. Panduan Halaman Aplikasi

Nama dan pengelompokan layar pada implementasi Android dapat berbeda dari nomor halaman pada rancangan Figma. Beberapa halaman Figma diwujudkan sebagai state, dialog, atau bagian dari layar induk.

- **Welcome / Guest:** halaman awal untuk masuk sebagai tamu atau membuka autentikasi.
- **Login / Sign Up:** terhubung ke backend akun; akun baru dapat dibuat dari aplikasi dan login membuat sesi.
- **Forgot Password:** meminta OTP email dan mengganti kata sandi setelah kode diverifikasi; semua sesi lama dicabut.
- **Beranda:** ringkasan dan akses ke fitur utama.
- **Hubungkan Notifikasi:** petunjuk untuk membuka pengaturan Notification Access Android.
- **Analisis Manual:** input pesan dan pengirim opsional untuk diuji.
- **Hasil Analisis:** skor, kategori, rincian indikator, dan penjelasan.
- **Aktivitas Notifikasi:** daftar catatan notifikasi yang terdeteksi.
- **Riwayat Analisis:** daftar hasil yang tersimpan, termasuk akses detail.
- **Edukasi Keamanan:** materi edukasi dan dialog artikel.
- **Pengaturan:** preferensi sumber notifikasi, pengirim tepercaya, alamat API, dan sinkronisasi aturan.

## 14. Teknologi dan Struktur Proyek

### Teknologi

- **Kotlin:** bahasa pemrograman aplikasi Android.
- **Android SDK:** akses antarmuka Android, notifikasi, pengaturan, dan komponen aplikasi.
- **NotificationListenerService:** menerima event notifikasi setelah izin pengguna diberikan.
- **Aho–Corasick:** pencocokan banyak keyword.
- **Regular Expression (Regex):** normalisasi pola, ekstraksi URL, dan deteksi frasa.
- **SQLite:** penyimpanan lokal riwayat analisis.
- **SharedPreferences:** penyimpanan preferensi dan cache konfigurasi aturan.
- **Python + FastAPI:** backend untuk API aturan dan autentikasi akun.
- **JSON:** format konfigurasi aturan.

### Struktur repository

```text
MIVVI-SECURE/
├── app/
│   ├── build.gradle.kts
│   └── src/main/
│       ├── java/id/ac/um/mivvisecure/
│       │   ├── MainActivity.kt
│       │   ├── NotificationMonitorService.kt
│       │   ├── RuleBasedAnalyzer.kt
│       │   ├── RuleConfigStore.kt
│       │   ├── ApiClient.kt
│       │   ├── LocalDatabase.kt
│       │   └── AppPrefs.kt
│       ├── res/
│       └── AndroidManifest.xml
├── server/
│   ├── app/main.py
│   ├── config/rules.json
│   └── requirements.txt
├── docs/
│   ├── API.md
│   ├── ARCHITECTURE.md
│   └── PROTOTYPE_ALIGNMENT.md
├── tests/
│   └── RuleSmokeTest.kt
├── scripts/
│   ├── build-apk.sh
│   └── run-rule-tests.sh
└── .github/workflows/android-apk.yml
```

## 15. Instalasi dan Menjalankan Aplikasi

### Persyaratan

- Android Studio yang mendukung Android Gradle Plugin 8.7.3.
- JDK 17.
- Android SDK Platform 35 dan Android Build Tools yang sesuai.
- Gradle 8.9 (wrapper/toolchain sesuai konfigurasi proyek).
- Perangkat Android 8.0 (API 26) atau lebih baru, atau emulator.

### Build melalui Android Studio

1. Ekstrak repository.
2. Buka Android Studio, pilih **Open**, lalu pilih folder `MIVVI-SECURE`.
3. Pastikan Gradle JDK menggunakan JDK 17 dan SDK Platform 35 tersedia.
4. Jalankan **Sync Project with Gradle Files**.
5. Hubungkan perangkat Android dengan USB debugging aktif atau jalankan emulator.
6. Pilih konfigurasi `app`, kemudian tekan **Run**.
7. Untuk membuat APK, pilih **Build → Build Bundle(s) / APK(s) → Build APK(s)**.
8. Jika build berhasil, APK debug berada di `app/build/outputs/apk/debug/app-debug.apk`.

### Build APK melalui GitHub Actions

Repository menyertakan workflow `.github/workflows/android-apk.yml`.

1. Buat repository GitHub dan push seluruh source code.
2. Buka tab **Actions**.
3. Pilih workflow **Build MIVVI SECURE APK**.
4. Jalankan workflow melalui push ke branch yang dikonfigurasi atau pilih **Run workflow** jika tersedia.
5. Setelah proses berhasil, buka hasil workflow dan unduh artifact `MIVVI-SECURE-debug-apk`.

Artifact workflow adalah debug APK untuk pengujian, bukan paket rilis Play Store.

### Mengaktifkan akses notifikasi

1. Jalankan MIVVI SECURE.
2. Buka fitur **Hubungkan Notifikasi** atau Pengaturan.
3. Tekan tombol untuk membuka pengaturan akses notifikasi Android.
4. Cari **MIVVI SECURE Notification Access**, lalu aktifkan izin.
5. Kembali ke aplikasi dan pilih apakah sumber WhatsApp dan/atau SMS ingin dipantau.
6. Uji menggunakan pesan yang aman dan tidak memuat informasi pribadi.

Hanya isi yang benar-benar ditampilkan pada pratinjau notifikasi yang dapat dianalisis.

### Menjalankan Rules API (opsional)

Dari direktori proyek:

```bash
cd server
python -m venv .venv

# Windows PowerShell
.venv\Scripts\Activate.ps1

# macOS/Linux
source .venv/bin/activate

pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Uji endpoint:

```bash
curl http://127.0.0.1:8000/api/v1/health
curl http://127.0.0.1:8000/api/v1/rules
```

Dokumentasi interaktif FastAPI tersedia di `http://127.0.0.1:8000/docs`.

Untuk menghubungkan ponsel dan server, pastikan keduanya berada pada jaringan Wi-Fi/LAN yang sama. Jalankan server pada host `0.0.0.0`, izinkan port 8000 pada firewall, lalu masukkan alamat IP LAN komputer pada Pengaturan → Integrasi Data (API) di aplikasi. Untuk emulator Android, alamat host komputer biasanya diakses melalui `10.0.2.2`. Jika sinkronisasi gagal, aplikasi tetap menggunakan aturan lokal.

HTTP hanya digunakan untuk pengembangan pada jaringan lokal. Deployment publik memerlukan HTTPS serta pengamanan endpoint dan proses perubahan konfigurasi.

## 16. Pengujian dan Status Implementasi

### Menjalankan smoke test aturan

Dengan Kotlin compiler tersedia, jalankan:

```bash
./scripts/run-rule-tests.sh
```

Smoke test mencakup contoh skor 13 (PHISHING) dan pengujian ambang kategori AMAN serta MENCURIGAKAN.

### Status komponen

| Komponen | Status |
|---|---|
| Rule-based analyzer Kotlin | Diimplementasikan; smoke test aturan tersedia |
| Analisis manual | Diimplementasikan |
| SQLite untuk riwayat | Diimplementasikan |
| NotificationListenerService | Diimplementasikan; memerlukan izin Android dan pratinjau notifikasi yang terlihat |
| Sinkronisasi Rules API | Diimplementasikan |
| Android Login/Sign Up/OTP Email/Logout | Diimplementasikan; OTP memerlukan SMTP yang dikonfigurasi dan backend API aktif |
| Forgot Password via Email OTP | Diimplementasikan; SMTP server harus aktif |
| Enkripsi database lokal | Belum diimplementasikan |
| Auto-block / auto-delete pesan | Tidak diimplementasikan |
| Akses database privat WhatsApp | Tidak diimplementasikan |
| APK binary siap instalasi | Belum tersedia dari lingkungan pembuatan ini |

Status smoke test algoritma tidak sama dengan pengujian menyeluruh pada semua perangkat Android. Build APK, pemasangan fisik, kompatibilitas semua aplikasi SMS, dan perilaku notifikasi pada berbagai versi Android masih perlu diuji.

## 17. Privasi, Keamanan, dan Batasan

1. Akses notifikasi hanya aktif setelah pengguna mengizinkannya melalui pengaturan Android.
2. Aplikasi hanya memproses paket aplikasi yang tercantum dan dipilih pengguna.
3. Isi pesan dianalisis dari pratinjau notifikasi. Jika pratinjau disembunyikan, konten tidak tersedia dan tidak dibuat-buat.
4. Isi pesan dan riwayat disimpan di SQLite lokal agar dapat ditampilkan kembali.
5. Kode Rules API hanya mengambil konfigurasi aturan; tidak mengunggah isi pesan, identitas pengirim, payload notifikasi, atau riwayat analisis.
6. Database SQLite belum dienkripsi secara khusus. Perlindungan penyimpanan mengikuti mekanisme sandbox Android, tetapi hal itu bukan klaim enkripsi database aplikasi.
7. Whitelist domain bawaan merupakan daftar awal/contoh dan perlu diverifikasi serta diperbarui dari sumber resmi sebelum penggunaan lebih luas.
8. Daftar pengirim tepercaya bersifat lokal dan bergantung pada input pengguna; status tepercaya bukan bukti bahwa pengirim benar-benar resmi.
9. Sistem tidak melakukan pemeriksaan reputasi URL secara online, tidak membuka tautan, dan tidak menjamin deteksi seluruh variasi phishing.
10. Kategori AMAN berarti indikator yang dikonfigurasi tidak mencapai ambang risiko, bukan jaminan pesan tersebut aman.
11. Sistem tidak memblokir, menghapus, atau mencegah pesan masuk. Keputusan akhir tetap berada pada pengguna.

## 18. Pengembangan Selanjutnya

Pengembangan berikutnya yang dapat dipertimbangkan:

- Memperluas dan mengevaluasi daftar keyword, pola urgensi, pola data sensitif, whitelist, dan shortlink dari sumber tepercaya.
- Menguji dengan dataset pesan phishing dan pesan normal yang berlabel, kemudian mengukur accuracy, precision, recall, dan F1-score.
- Menambahkan pembatasan percobaan login dan audit sebelum backend dipublikasikan.
- Menambahkan perlindungan enkripsi untuk data riwayat lokal dan kebijakan retensi data.
- Menguji kompatibilitas NotificationListenerService pada berbagai perangkat, versi Android, dan aplikasi SMS.
- Mengkaji metode machine learning seperti Naive Bayes atau SVM sebagai pengembangan penelitian terpisah, setelah tersedia dataset berlabel yang memadai.
- Mengkaji integrasi layanan reputasi URL melalui API dengan memperhatikan privasi dan keamanan data.
- Menyediakan backend produksi ber-HTTPS dan melakukan audit keamanan sebelum autentikasi dipakai di luar lingkungan pengembangan.

Pengembangan tersebut merupakan rencana, bukan fitur yang sudah tersedia pada versi source code ini.

### Build rilis Android

Build rilis menolak API selain HTTPS dan menonaktifkan cleartext HTTP. Sebelum menjalankan `assembleRelease`, siapkan domain backend dengan sertifikat TLS tepercaya dan set Gradle property `MIVVI_RELEASE_API_BASE_URL`, misalnya di `%USERPROFILE%\\.gradle\\gradle.properties`. Salin `keystore.properties.example` menjadi `keystore.properties`, lalu isi kredensial signing key privat. File `.jks` dan `keystore.properties` diabaikan Git. Simpan keduanya di tempat aman; kehilangan key berarti tidak dapat memperbarui instalasi yang ditandatangani dengan key tersebut. Jangan membagikan file kunci atau kata sandinya.

Build debug tetap ditujukan untuk emulator/perangkat pengembangan dan dapat memakai HTTP. Repository ini belum menyediakan API produksi; jangan distribusikan build rilis sebelum URL HTTPS backend benar-benar aktif.

---

## Lisensi dan Penggunaan

Proyek ini merupakan prototipe akademik. Tinjau ulang aturan deteksi, whitelist, privasi, keamanan API, dan kompatibilitas perangkat sebelum digunakan di luar lingkungan pengujian. Gunakan data sintetis atau data yang telah dianonimkan untuk demonstrasi.
