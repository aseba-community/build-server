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
securityRealm.createAccount("jenkins", "changeme")
jenkins.securityRealm = securityRealm
jenkins.slaveAgentPort = 5143

def xmlInput = { xml -> new ByteArrayInputStream(xml.getBytes("UTF-8")) }

import hudson.model.View
jenkins.addView(View.createViewFromXML(name, new ByteArrayInputStream("""<?xml version="1.0" encoding="UTF-8"?>
<com.smartcodeltd.jenkinsci.plugins.buildmonitor.BuildMonitorView plugin="build-monitor-plugin@1.6+build.159">
  <owner class="hudson" reference="../../.."/>
  <name>${name}</name>
  <filterExecutors>false</filterExecutors>
  <filterQueue>false</filterQueue>
  <properties class="hudson.model.View\$PropertyList"/>
  <jobNames>
    <comparator class="hudson.util.CaseInsensitiveComparator"/>
  </jobNames>
  <jobFilters/>
  <columns/>
  <includeRegex>.*</includeRegex>
  <recurse>false</recurse>
  <title>aseba-build-server</title>
  <config>
    <order class="com.smartcodeltd.jenkinsci.plugins.buildmonitor.order.ByName"/>
  </config>
</com.smartcodeltd.jenkinsci.plugins.buildmonitor.BuildMonitorView>""".getBytes("UTF-8"))))

import java.nio.file.Files
Files.deleteIfExists(jenkins.root.toPath().resolve("init.groovy"))
