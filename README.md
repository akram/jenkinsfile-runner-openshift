# jenkinsfile-runner-openshift

A jenkinsfile container image with all the required plugins for OpenShift

## Prerequisites
Please install `yq` , an equivalent of `jq` but for yaml:
```
pip3 install yq
```


Jenkinsfile-runner is not serving any file. So, we need to provide `remoting.jar` as the kubernetes plugin
needs it to start jenkins agents. To make it available, we need to create a simple nginx server serving it 
it the same `namespace`:

```
oc new-app nginx-example~https://github.com/akram/jnlpJars.git --name=remoting-jar
```
The url is then referenced in `kubernetes-cloud.yml` as the `jenkinsUrl: http://remoting-jar:8080`

## Build and run locally

```
docker build -t jenkinsfile-runner-openshift .
docker run --rm -v $(pwd)/pipelines/Jenkinsfile:/workspace/Jenkinsfile -v $(pwd)/config:/usr/share/jenkins/ref/casc jenkinsfile-runner-openshift
```


## Build and run on OpenShift


### Building the jenkinsfile-runner-openshift image
```
oc new-build . --strategy=docker --name=jenkinsfile-runner-openshift
oc start-build jenkinsfile-runner-openshift
```

### Running a Jenfils pipeline in OpenShift without Jenkins

It is required that the `serviceAccount` used to run the pipeline has `edit` permissions in the current 
namespace so it can create `pods` for the different agent we use:

```
oc policy add-role-to-user edit -z default
```

And then, run the pod:

```
oc create configmap casc --from-file=$PWD/casc
oc create configmap jenkinsfile --from-file=$PWD/pipelines/Jenkinsfile

IMAGE=$(oc get is jenkinsfile-runner-openshift   -o template='{{ .status.dockerImageRepository  }}')
VOLUMES=$(cat << EOF
spec:
  containers:
  - name: jenkins-pipeline-run
    image: $IMAGE
    volumeMounts:
    - name: jenkinsfile
      mountPath: /workspace/Jenkinsfile
      subPath: Jenkinsfile
    - name: casc
      mountPath: /usr/share/jenkins/ref/casc
  volumes:
  - name: jenkinsfile
    configMap:
      name: jenkinsfile
  - name: casc
    configMap:
      name: casc
EOF
)
VOLUMES_JSON=$( echo "$VOLUMES" | yq . )
oc run jenkins-pipeline-run --image=$IMAGE --restart=Never  --overrides="$VOLUMES_JSON"
```
