#!/bin/sh
export JAVA_OPTS="${JAVA_OPTS:+$JAVA_OPTS}"
export JAVA_OPTS="${JAVA_OPTS} -Dhudson.TcpSlaveAgentListener.hostName=$(hostname -i)"
export JAVA_OPTS="${JAVA_OPTS} -Djenkins.model.Jenkins.slaveAgentPort=50000"
export JAVA_OPTS="${JAVA_OPTS} -Djenkins.model.Jenkins.slaveAgentPortEnforce=true"
export JAVA_OPTS="${JAVA_OPTS} -Dhudson.slaves.NodeProvisioner.initialDelay=1" # How long to wait after startup before starting to provision nodes from clouds
export JAVA_OPTS="${JAVA_OPTS} -Dhudson.slaves.ConnectionActivityMonitor.timeToPing=30000" # wait after startup to start checking agent connections, in milliseconds.

/app/bin/jenkinsfile-runner-launcher

