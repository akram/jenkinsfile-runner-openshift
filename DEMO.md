```
oc new-build . --strategy=docker --name=jenkinsfile-runner-openshift
oc policy add-role-to-user edit -z default
oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:$(oc project -q):default:
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

