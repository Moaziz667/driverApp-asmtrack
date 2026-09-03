allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// La sortie du build est deportee hors du depot : sous Windows, le chemin du projet est deja long
// et Gradle depasse la limite du systeme sur les fichiers intermediaires. D'ou un chemin court, a
// la racine du disque.
//
// Ce repli valait « C:/tmp/driverApp-build » quel que soit le systeme, une adresse qui n'existe que
// sous Windows : ailleurs le build echouait sur « Cannot convert URL to a file », a commencer par
// l'integration continue. La valeur Windows est conservee telle quelle, puisque c'est elle qui
// resout le probleme de longueur ; les autres systemes, qui ne l'ont pas, prennent /tmp.
//
// java.io.tmpdir aurait ete plus elegant, mais il pointe sous AppData\Local\Temp sur Windows, un
// chemin plus long que celui qu'on cherche justement a raccourcir.
val defautPortable: String =
    if (System.getProperty("os.name").startsWith("Windows")) "C:/tmp/driverApp-build"
    else "/tmp/driverApp-build"
val newBuildDir: Directory = rootProject.layout.projectDirectory
    .dir(providers.gradleProperty("driverApp.buildDir").orElse(defautPortable).get())
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

val flutterExpectedBuildDir: Directory = rootProject.layout.projectDirectory.dir("../build")

tasks.register<Copy>("copyOutputsForFlutterTool") {
    from(newBuildDir.dir("app/outputs"))
    into(flutterExpectedBuildDir.dir("app/outputs"))
}

project(":app").tasks.matching { it.name.startsWith("assemble") || it.name.startsWith("bundle") }.configureEach {
    finalizedBy(rootProject.tasks.named("copyOutputsForFlutterTool"))
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
    delete(flutterExpectedBuildDir)
}
