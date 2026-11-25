import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

val releaseSigningPropertiesFile = rootProject.file("keystore.properties")
val releaseSigningProperties = Properties().apply {
    if (releaseSigningPropertiesFile.exists()) {
        releaseSigningPropertiesFile.inputStream().use { load(it) }
    }
}
val releaseApiBaseUrl = providers.gradleProperty("MIVVI_RELEASE_API_BASE_URL").orElse("").get()
val releaseApiBaseUrlForBuildConfig = releaseApiBaseUrl
    .replace("\\", "\\\\")
    .replace("\"", "\\\"")

android {
    namespace = "id.ac.um.mivvisecure"
    compileSdk = 35

    defaultConfig {
        applicationId = "id.ac.um.mivvisecure"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        buildConfigField("String", "RELEASE_API_BASE_URL", "\"$releaseApiBaseUrlForBuildConfig\"")
    }

    buildFeatures {
        buildConfig = true
    }

    signingConfigs {
        create("release") {
            val storeFilePath = releaseSigningProperties.getProperty("storeFile")
            if (!storeFilePath.isNullOrBlank()) storeFile = rootProject.file(storeFilePath)
            storePassword = releaseSigningProperties.getProperty("storePassword")
            keyAlias = releaseSigningProperties.getProperty("keyAlias")
            keyPassword = releaseSigningProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            manifestPlaceholders["usesCleartextTraffic"] = "true"
        }
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("release")
            manifestPlaceholders["usesCleartextTraffic"] = "false"
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}

gradle.taskGraph.whenReady {
    if (allTasks.any { it.name.contains("Release", ignoreCase = true) }) {
        if (releaseApiBaseUrl.isBlank() || !releaseApiBaseUrl.startsWith("https://", ignoreCase = true)) {
            throw GradleException("Set MIVVI_RELEASE_API_BASE_URL to the production HTTPS API URL before building release.")
        }
        if (listOf("storeFile", "storePassword", "keyAlias", "keyPassword").any {
                releaseSigningProperties.getProperty(it).isNullOrBlank()
            }
        ) {
            throw GradleException("Release signing is not configured. Create keystore.properties from keystore.properties.example.")
        }
    }
}
