#!/usr/bin/groovy

import jenkins.model.Jenkins

def jenkins = Jenkins.instance

import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
jenkins.authorizationStrategy = new FullControlOnceLoggedInAuthorizationStrategy()

def updateCenter = jenkins.updateCenter
updateCenter.updateAllSites()
def plugins = [ "git-client", "github", "build-monitor-plugin" ]
	.collect { updateCenter.getPlugin(it) }
	.grep { it.installed == null }
	.plus(updateCenter.updates)
import hudson.model.UpdateCenter.RestartJenkinsJob
if (!plugins.empty) {
	plugins.each { it.deploy() }
	new RestartJenkinsJob(updateCenter, updateCenter.coreSource).submit()
	return
}

import hudson.security.HudsonPrivateSecurityRealm
def securityRealm = new HudsonPrivateSecurityRealm(false, false, null)
securityRealm.createAccount("jenkins", "jenkins")
jenkins.securityRealm = securityRealm

def xmlInput = { xml -> new ByteArrayInputStream(xml.getBytes("UTF-8")) }

import hudson.model.FreeStyleProject
import hudson.tasks.Builder
import hudson.Launcher
import hudson.model.AbstractBuild
import hudson.model.TaskListener
import hudson.model.View

[
	enki: [
		git: "https://github.com/enki-community/enki.git",
		github: "https://github.com/enki-community/enki/",
	],
	dashel: [
		git: "https://github.com/aseba-community/dashel.git",
		github: "https://github.com/aseba-community/dashel/",
	],
	aseba: [
		git: "https://github.com/aseba-community/aseba.git",
		github: "https://github.com/aseba-community/aseba/",
	],
].each {
	def name = it.key
	def props = it.value

	def view = View.createViewFromXML(name, xmlInput("""<?xml version="1.0" encoding="UTF-8"?>
<com.smartcodeltd.jenkinsci.plugins.buildmonitor.BuildMonitorView plugin="build-monitor-plugin@1.6+build.150">
  <name>${name}</name>
  <filterExecutors>false</filterExecutors>
  <filterQueue>false</filterQueue>
  <properties class="hudson.model.View\$PropertyList"/>
  <jobNames>
    <comparator class="hudson.util.CaseInsensitiveComparator"/>
  </jobNames>
  <jobFilters/>
  <columns/>
  <recurse>false</recurse>
  <order class="com.smartcodeltd.jenkinsci.plugins.buildmonitor.order.ByName"/>
</com.smartcodeltd.jenkinsci.plugins.buildmonitor.BuildMonitorView>"""))
	jenkins.addView(view)

	[
		"ubuntu-precise-amd64": "/srv/linux/jenkins/deb-machine.sh precise amd64",
		"ubuntu-precise-i386": "/srv/linux/jenkins/deb-machine.sh precise i386",
		"ubuntu-trusty-amd64": "/srv/linux/jenkins/deb-machine.sh trusty amd64",
		"ubuntu-trusty-i386": "/srv/linux/jenkins/deb-machine.sh trusty i386",
		"ubuntu-vivid-amd64": "/srv/linux/jenkins/deb-machine.sh vivid amd64",
		"ubuntu-vivid-i386": "/srv/linux/jenkins/deb-machine.sh vivid i386",
	].each {
		def machine = it.key
		def command = it.value

		def projectName = "${name}.${machine}"
		def existing = jenkins.getItem(projectName)
		if (existing != null)
			jenkins.remove(existing)

		def project = jenkins.createProjectFromXML(projectName, xmlInput("""<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <com.coravy.hudson.plugins.github.GithubProjectProperty plugin="github@1.13.0">
      <projectUrl>${props.github}</projectUrl>
    </com.coravy.hudson.plugins.github.GithubProjectProperty>
  </properties>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@2.4.0">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>${props.git}</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/master</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions>
      <hudson.plugins.git.extensions.impl.RelativeTargetDirectory>
        <relativeTargetDir>source</relativeTargetDir>
      </hudson.plugins.git.extensions.impl.RelativeTargetDirectory>
      <hudson.plugins.git.extensions.impl.LocalBranch>
        <localBranch>master</localBranch>
      </hudson.plugins.git.extensions.impl.LocalBranch>
    </extensions>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers>
    <hudson.triggers.SCMTrigger>
      <spec>H/15 * * * *</spec>
      <ignorePostCommitHooks>false</ignorePostCommitHooks>
    </hudson.triggers.SCMTrigger>
  </triggers>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>${command}</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>"""))
		view.add(project)
	}

}

import java.nio.file.Files
Files.deleteIfExists(jenkins.root.toPath().resolve("init.groovy"))
