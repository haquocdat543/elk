# ELK stack
This is a demonstration of using ELK stack

## Prerequisites
* [git](https://git-scm.com/downloads)
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [config-profile](https://docs.aws.amazon.com/cli/latest/reference/configure/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [eksctl](https://eksctl.io/installation/)
## 1. Create
### 1. Initialize cloudformation
Replace `$stackname` and `$templatefile` to your custom
```
aws cloudformation deploy --stack-name $stackname --template-file $templatefile
```
### 2. Get output
```
aws cloudformation describe-stacks --query Stacks[].Outputs[*].[OutputKey,OutputValue] --output text
```
### 3. Update kubeconfig
Replace `$clusterName` to your custom
```
aws eks update-kubeconfig --name $clusterName
```
### 4. OIDC
Replace `$cluster` and `$region` to your custom
```
eksctl utils associate-iam-oidc-provider --cluster=$cluster --region $region --approve
```
### 5. Create EBS CNI Role
Replace `$cluster` to your custom
```
eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster $cluster --role-name AmazonEKS_EBS_CSI_DriverRole --role-only --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --force
```
### 6. Add addons
Replace `$cluster` and `YOUR_AWS_ACCOUNT` to your custom
```
aws eks create-addon --cluster-name $cluster --addon-name aws-ebs-csi-driver --service-account-role-arn arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/AmazonEKS_EBS_CSI_DriverRole
```
### 7. Create k8s resources
#### 1. Create namespace
```
kubectl create namespace prod
```
#### 2. Create elasticsearch
```
helm repo add elastic https://helm.elastic.co 
helm install elasticsearch elastic/elasticsearch
```
#### 3. create kibana
```
helm repo add elastic https://helm.elastic.co 
helm install kibana elastic/kibana
```
#### 4. create logstash
```
helm repo add elastic https://helm.elastic.co ; helm install logstash elastic/logstash
```
#### 5. create filebeat
```
helm repo add elastic https://helm.elastic.co 
helm install filebeat elastic/filebeat
```

## 2. Destroy
### 1. Delete k8s resources
```
kubectl delete namespace prod
```
### 2. Delete role
```
aws iam delete-role --role-name AmazonEKS_EBS_CSI_DriverRole
```
### 3. Delete cloudformation stack
Replace `$stackname` to your custom
```
aws cloudformation delete-stack --stack-name $stackname
```
```
aws cloudformation delete-stack --stack-name eksctl-EKSCluster-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa
```
