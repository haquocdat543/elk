# ELK stack
This is a demonstration of using ELK stack

## Start
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


