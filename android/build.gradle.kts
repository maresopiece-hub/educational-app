allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Add Google Services plugin classpath so android/app can apply it and generate
// resources from google-services.json
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle plugin - ensure a reasonably recent version
        classpath("com.android.tools.build:gradle:8.1.0")
        // Google Services Gradle plugin used to process android/app/google-services.json
        classpath("com.google.gms:google-services:4.4.2")
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
