import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Chiave di firma: le pipeline scrivono android/key.properties (ignorato da
// git). Il fallback debug è consentito solo al flavor dev. La release prod
// richiede sempre una configurazione di firma esplicita.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
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

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                keystoreProperties.getProperty("storeFile")?.takeIf { it.isNotBlank() }?.let {
                    storeFile = file(it)
                }
                storePassword = keystoreProperties.getProperty("storePassword")
                storeType = keystoreProperties.getProperty("storeType") ?: "JKS"
            }
        }
    }

    flavorDimensions += "app_environment"

    productFlavors {
        create("dev") {
            dimension = "app_environment"
            applicationIdSuffix = ".dev"
            signingConfig = signingConfigs.getByName(
                if (keystorePropertiesFile.exists()) "release" else "debug"
            )
            resValue("string", "app_name", "Frequenza Dev")
        }
        create("prod") {
            dimension = "app_environment"
            resValue("string", "app_name", "Frequenza")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

// An incomplete signing config can otherwise produce unsigned artifacts.
// Validate production inputs before packaging, without affecting dev/debug or
// Gradle sync. Never print property values (passwords) in an error.
val validateProdReleaseSigningInputs = tasks.register("validateProdReleaseSigningInputs") {
    group = "verification"
    description = "Checks that a production release has explicit signing credentials."
    doLast {
        check(keystorePropertiesFile.isFile) {
            "Production release requires android/key.properties; use flavor dev for local builds."
        }
        val required = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
        val missing = required.filter { keystoreProperties.getProperty(it).isNullOrBlank() }
        check(missing.isEmpty()) {
            "Production signing configuration is incomplete: ${missing.joinToString()}."
        }
        check(file(keystoreProperties.getProperty("storeFile")).isFile) {
            "Production signing keystore does not exist. Check storeFile in android/key.properties."
        }
    }
}

tasks.configureEach {
    if (name == "preProdReleaseBuild") dependsOn(validateProdReleaseSigningInputs)
}
