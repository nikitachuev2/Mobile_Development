plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.auth_app"
    compileSdk = flutter.compileSdkVersion

    // Используем нужную версию NDK (из сообщения Gradle)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Уникальный Application ID
        applicationId = "com.example.auth_app"

        // Минимальная поддерживаемая версия Android — 21,
        // чтобы csounddart и NDK работали корректно
        minSdk = 21

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Пока подписываем debug-ключом, чтобы flutter run --release работал
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
