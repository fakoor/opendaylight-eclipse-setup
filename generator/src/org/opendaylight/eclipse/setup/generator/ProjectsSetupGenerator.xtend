package org.opendaylight.eclipse.setup.generator

import com.google.common.base.Charsets
import com.google.common.io.Files
import java.io.File

class ProjectsSetupGenerator {

    def generateProjectSetup(String projectName) '''
        <?xml version="1.0" encoding="UTF-8"?>
        <!-- This file is auto.generated by ProjectsSetupGenerator, please do not hand-edit it! -->
        <setup:Project
            xmi:version="2.0"
            xmlns:xmi="http://www.omg.org/XMI"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:git="http://www.eclipse.org/oomph/setup/git/1.0"
            xmlns:maven="http://www.eclipse.org/oomph/setup/maven/1.0"
            xmlns:predicates="http://www.eclipse.org/oomph/predicates/1.0"
            xmlns:setup="http://www.eclipse.org/oomph/setup/1.0"
            xmlns:setup.workingsets="http://www.eclipse.org/oomph/setup/workingsets/1.0"
            xmlns:workingsets="http://www.eclipse.org/oomph/workingsets/1.0"
            xsi:schemaLocation="http://www.eclipse.org/oomph/setup/git/1.0 http://git.eclipse.org/c/oomph/org.eclipse.oomph.git/plain/setups/models/Git.ecore http://www.eclipse.org/oomph/setup/maven/1.0 http://git.eclipse.org/c/oomph/org.eclipse.oomph.git/plain/setups/models/Maven.ecore http://www.eclipse.org/oomph/predicates/1.0 http://git.eclipse.org/c/oomph/org.eclipse.oomph.git/plain/setups/models/Predicates.ecore http://www.eclipse.org/oomph/setup/workingsets/1.0 http://git.eclipse.org/c/oomph/org.eclipse.oomph.git/plain/setups/models/SetupWorkingSets.ecore"
            name="«projectName»">
          <setupTask
              xsi:type="git:GitCloneTask"
              id="git.clone.opendaylight.«validId(projectName)»"
              remoteURI="«projectName».git"
              location="${installation.location/git/}«projectName»">
            <annotation
                source="http://www.eclipse.org/oomph/setup/InducedChoices">
              <detail
                  key="inherit">
                <value>opendaylight.gerrit.remoteURIs</value>
              </detail>
              <detail
                  key="target">
                <value>remoteURI</value>
              </detail>
            </annotation>
            <description>git clone «projectName»</description>
          </setupTask>
          <setupTask
              xsi:type="setup.workingsets:WorkingSetTask">
            <workingSet
                name="«projectName»">
              <predicate
                  xsi:type="predicates:AndPredicate">
                <operand
                    xsi:type="predicates:LocationPredicate"
                    pattern="${git.clone.opendaylight.«validId(projectName)».location}.*"/>
                <operand
                    xsi:type="predicates:NotPredicate">
                  <operand
                      xsi:type="predicates:NamePredicate"
                      pattern="(.*-aggregator$)|(.*-features$)|(.*-artifacts$)|(.*-karaf$)|(.*-parent$)"/>
                </operand>
              </predicate>
            </workingSet>
            <workingSet
                name="«projectName»-build">
              <predicate
                  xsi:type="predicates:AndPredicate">
                <operand
                    xsi:type="predicates:LocationPredicate"
                    pattern="${git.clone.opendaylight.«validId(projectName)».location}.*"/>
                <operand
                    xsi:type="predicates:NamePredicate"
                    pattern="(.*-aggregator$)|(.*-features$)|(.*-artifacts$)|(.*-karaf$)|(.*-parent$)"/>
              </predicate>
            </workingSet>
          </setupTask>
          <setupTask
              xsi:type="maven:MavenImportTask"
              id="import.maven"
              projectNameTemplate="[groupId].[artifactId]">
            <sourceLocator
                rootFolder="${git.clone.opendaylight.«validId(projectName)».location}"
                locateNestedProjects="true"/>
          </setupTask>
          <stream name="master"/>
          <logicalProjectContainer
              xsi:type="setup:ProjectCatalog"
              href="«IF projectName.contains("/")»../..«ELSE»..«ENDIF»/org.opendaylight.projects.setup#/"/>
        </setup:Project>
    '''

    def validId(String variableName) {
        if (variableName.contains("/"))
            variableName.replace('/', '_')
        else
            variableName
    }

    def writeProjectSetup(String projectName) {
        val projectSetupText = generateProjectSetup(projectName)
        val projectSetupFile = new File("../projects/" + projectName + ".setup")
        projectSetupFile.parentFile.mkdirs
        Files.write(projectSetupText, projectSetupFile, Charsets.UTF_8)
    }

    def writeAllProjectsSetup(File projectsListFile) {
        for (line : Files.readLines(projectsListFile, Charsets.UTF_8)) {
            val trimline = line.trim()
            if (!trimline.startsWith(("#")) && trimline.length > 0) {
               writeProjectSetup(trimline)
               println('''  <project href="projects/«trimline».setup#/"/>''')
            }
        }
    }

    def static void main(String[] args) {
        val generateProjectSetup = new ProjectsSetupGenerator()
        // generateProjectSetup.writeProjectSetup("lispflowmapping")
        generateProjectSetup.writeAllProjectsSetup(new File("projects.txt"))
    }

}
