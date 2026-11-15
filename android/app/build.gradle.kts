import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Chiave di firma: le pipeline scrivono android/key.properties (ignorato da
// git). Senza il file, le build release si firmano con la chiave di debug,
// così `flutter run --release` funziona anche senza chiavi.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "it.davidetarsi.frequenza"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Immutabile dopo il primo caricamento sul Play Store: il flavor dev
        // vi aggiunge ".dev", così le due versioni stanno sullo stesso telefono.
        applicationId = "it.davidetarsi.frequenza"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "app_environment"

    productFlavors {
        create("dev") {
            dimension = "app_environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Frequenza Dev")
        }
        create("prod") {
            dimension = "app_environment"
            resValue("string", "app_name", "Frequenza")
        }
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile") as String)
                storePassword = keystoreProperties.getProperty("storePassword")
                storeType = keystoreProperties.getProperty("storeType") ?: "JKS"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
