android {
    // 1. Set the namespace to match your AndroidManifest.xml exactly
    namespace = "com.example.regen" // Replace with your confirmed package name

    compileSdkVersion 34 // Use 34 for modern compatibility

    defaultConfig {
        // 2. This must also match your package name
        applicationId = "com.example.regen" 
        
        // 3. QR Scanner and Firebase need 21 or higher
        minSdkVersion 23 
        targetSdkVersion 34
        
        versionCode flutterVersionCode
        versionName flutterVersionName
    }

    // Recommended for large projects with multiple plugins
    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}