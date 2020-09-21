# jenkinsfile-runner-openshift

A jenkinsfile container image with all the required plugins for OpenShift

## Prerequisites
Please install `yq` , an equivalent of `jq` but for yaml:
```
pip3 install yq
```

### Principles
TBD

Jenkinsfile-runner needs kubernetes plugin and jenkins that supports JNLP4 for remoting.

## Build and run on OpenShift

### Building the jenkinsfile-runner-openshift image
```
oc new-build . --strategy=docker --name=jenkinsfile-runner-openshift
oc start-build jenkinsfile-runner-openshift
```

### Running a Jenkinsfile pipeline in OpenShift without Jenkins

It is required that the `serviceAccount` used to run the pipeline has `edit` permissions in the current 
namespace so it can create `pods` for the different agent we use:

```
oc policy add-role-to-user edit -z default
```

Our demo project creates other project. So, we also need the service account to have provisioner role:
```
oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:$(oc project -q):default
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
