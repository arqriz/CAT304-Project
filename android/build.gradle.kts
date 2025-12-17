allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
/// android/build.gradle.kts

subprojects {
    afterEvaluate {
        if (hasProperty("android")) {
            // We use 'configure' on the "android" extension to access its properties
            configure<com.android.build.gradle.BaseExtension> {
                // If the namespace is not set, we assign the project group as the namespace
                // Note: Older AGP versions use 'namespace' as a simple property
                if (namespace == null) {
                    namespace = project.group.toString()
                }
            }
        }
    }
}