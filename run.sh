#!/bin/bash
export JAVA_OPTS="${JAVA_OPTS:+$JAVA_OPTS }-Dhudson.TcpSlaveAgentListener.hostName=$host_addr"
/app/bin/jenkinsfile-runner -f /workspace/Jenkinsfile 
