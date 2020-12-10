#!/usr/bin/env groovy
import java.text.SimpleDateFormat

podTemplate( name: 'openshift', label: 'openshift-agents', showRawYaml: false, envVars: [
    envVar(key: 'PATH', value: '/opt/rh/rh-maven35/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'),
    envVar(key: 'MAVEN_ARGS_APPEND', value: '-Dcom.redhat.xpaas.repo.jbossorg')],
    containers: [ 
    containerTemplate(name: 'maven', image: 'registry.redhat.io/openshift4/ose-jenkins-agent-maven', ttyEnabled: true, command: 'cat', workingDir: '/tmp'),
    containerTemplate(name: 'nodejs', image: 'registry.redhat.io/openshift4/jenkins-agent-nodejs-10-rhel7', ttyEnabled: true, command: 'cat', workingDir: '/tmp')
    ]) { 
  node('openshift-agents') {
    stage('Get a Maven project') {
      container('maven') {
        //git url: 'https://github.com/akram/simple-java-ex.git'
        stage('Test Maven project') {
          sh """
            git clone https://github.com/akram/simple-java-ex.git
            cd simple-java-ex
            env
            export MAVEN_ARGS_APPEND=-Dcom.redhat.xpaas.repo.jbossorg
            mvn -B test
            """
        }
        stage('Build s2i image') {
          openshift.raw( "new-app --build-env=MAVEN_ARGS_APPEND=-Dcom.redhat.xpaas.repo.jbossorg jboss-eap73-openshift:7.3~https://github.com/akram/simple-java-ex.git " )
        }
        stage('Build OpenShift Image') {
          echo "Building OpenShift container image example"
            script {
              openshift.withCluster() {
                openshift.withProject() {
                  openshift.selector("bc", "simple-java-ex").startBuild("--follow=true")
                }
              }
            }          
        }       
      }
    }

    stage('Get a simple nodejs-ex project') {
      git url: 'https://github.com/akram/simple-nodejs-ex.git'
        container('nodejs') {
          stage('Build a simple nodejs app') {
            sh """
              npm install
              """
          }  
          openshift.withCluster() {
            openshift.withProject() {
              currentProject = openshift.project()
                def project = "test-" + new SimpleDateFormat("yyyy-MM-dd-HHmmss").format(new Date())
                echo "To allow jenkins to create projects from a pipeline, the following command must be run"
                echo "oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:$currentProject:jenkins"
                openshift.raw( "new-project $project" )
                // echo "Context project is $openshift.project()"
                // Project context has been set to the pipeline project
                currentProject = project
                echo "openshift.raw() commands will specify $currentProject as project"
                openshift.raw( "new-app nodejs~https://github.com/akram/simple-nodejs-ex.git" )
                echo "end"
            }
          }
        }
    }

  }
}
