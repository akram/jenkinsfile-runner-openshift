FROM jenkins/jenkinsfile-runner
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN cd /app/jenkins && jar -cvf jenkins.war *
RUN java -jar /app/bin/jenkins-plugin-manager.jar --war /app/jenkins/jenkins.war --plugin-file /usr/share/jenkins/ref/plugins.txt && rm /app/jenkins/jenkins.war
COPY casc/cloud-kubernetes.yaml /usr/share/jenkins/ref/casc
COPY jenkinsfile-runner-launcher.sh /app/bin/jenkinsfile-runner-launcher.sh
ENTRYPOINT /app/bin/jenkinsfile-runner-launcher.sh

