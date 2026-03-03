plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.math"
    compileSdk = 36 // Eng so'nggi versiya, yaxshi tanlov

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.math"
        minSdk = flutter.minSdkVersion // Hive va Isar uchun 21 barqaror ishlaydi
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    @Suppress("UnstableApiUsage")
    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    buildTypes {
        release {
            // Hozircha debug kaliti bilan imzolab turadi (APK o'rnashishi uchun)
            signingConfig = signingConfigs.getByName("debug")

            // --- OPTIMIZATSIYA BOSHQIÇHI ---
            isMinifyEnabled = true      // Keraksiz kodlarni o'chiradi (Shake-off)
            isShrinkResources = true   // Keraksiz rasmlar va resurslarni o'chiradi
            
            // ProGuard qoidalari (R8)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
