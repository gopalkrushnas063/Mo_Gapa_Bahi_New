import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.krishnatechworld.mogapabahi"
    compileSdk = 35  // Updated to 35 for plugin compatibility
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Updated from 11
        targetCompatibility = JavaVersion.VERSION_17  // Updated from 11
    }

    kotlinOptions {
        jvmTarget = "17"  // Updated from 11
    }

    defaultConfig {
        applicationId = "com.krishnatechworld.mogapabahi"
        minSdk = 24
        targetSdk = 34  // Can keep at 34 for Play Store compliance
        versionCode = 9
        versionName = "1.0.2"
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            storeFile = file("../app/mogapabahi.jks")
            storePassword = "752019"
            keyAlias = "mogapabahi"
            keyPassword = "752019"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildFeatures {
        buildConfig = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core-ktx:1.12.0")  // Added for better Kotlin support
}