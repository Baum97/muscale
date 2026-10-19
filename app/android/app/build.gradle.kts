import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload-Schlüssel für Google Play: lokal aus android/key.properties, in der CI aus Umgebungsvariablen
// (GitHub-Secrets). Fehlt beides, bleibt der Release-Build unsigniert – so baut auch F-Droid, das selbst signiert.
// Anleitung: docs/VEROEFFENTLICHUNG.md
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

fun signingValue(property: String, env: String): String? =
    keyProperties.getProperty(property) ?: System.getenv(env)

val uploadStoreFile = signingValue("storeFile", "MUSCALE_KEYSTORE_PATH")

android {
    namespace = "app.muscale.muscale"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Für geplante Erinnerungen (flutter_local_notifications).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "app.muscale.muscale"
        // Health Connect (Waagen) braucht mindestens Android 8.
        minSdk = maxOf(flutter.minSdkVersion, 26)
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Zwei Vertriebswege aus demselben Code (siehe docs/KONZEPT.md, Kapitel 11):
    // fdroid – Spendenlink, kein Google-Code · play – Trinkgeld über Google Play Billing (folgt).
    flavorDimensions += "store"
    productFlavors {
        create("fdroid") {
            dimension = "store"
        }
        create("play") {
            dimension = "store"
        }
    }

    signingConfigs {
        if (uploadStoreFile != null) {
            create("upload") {
                storeFile = file(uploadStoreFile)
                storePassword = signingValue("storePassword", "MUSCALE_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "MUSCALE_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "MUSCALE_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (uploadStoreFile != null) signingConfigs.getByName("upload") else null
        }
    }

    // F-Droid: keine Google-eigenen Abhängigkeits-Metadaten (verschlüsselter Block, den nur Google lesen kann).
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
