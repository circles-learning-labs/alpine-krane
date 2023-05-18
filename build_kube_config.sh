#!/bin/bash
export UPPER_TARGET_ENV=`echo ${TARGET_ENV} | tr '[:lower:]' '[:upper:]'`
export TMP=AWS_ACCESS_KEY_ID_${UPPER_TARGET_ENV}
export AWS_ACCESS_KEY_ID=${!TMP}
export TMP=AWS_SECRET_ACCESS_KEY_${UPPER_TARGET_ENV}
export AWS_SECRET_ACCESS_KEY=${!TMP}
export AWS_DEFAULT_REGION=us-east-1

export conf_file=/tmp/krane_cluster_config.tfstate

aws s3 cp s3://circles-${TARGET_ENV}-terraform-state/eks_base/terraform.tfstate ${conf_file}

export CLUSTER_NAME=`jq -r '.outputs.cluster_name.value' ${conf_file}`
export CLUSTER_SERVER=`jq -r '.outputs.endpoint.value' ${conf_file}`

jq -r '.outputs.eks_ca_crt.value' ${conf_file} > /tmp/eks_ca.crt

kubectl config set-credentials aws-${TARGET_ENV} --exec-api-version=client.authentication.k8s.io/v1beta1 --exec-command=aws --exec-arg=eks --exec-arg=get-token --exec-arg=--cluster-name=${CLUSTER_NAME}
kubectl config set-cluster circles-${TARGET_ENV} --server=${CLUSTER_SERVER} --embed-certs --certificate-authority=/tmp/eks_ca.crt
kubectl config set-context circles-${TARGET_ENV} --cluster=${CLUSTER_NAME} --user=aws-${TARGET_ENV}
