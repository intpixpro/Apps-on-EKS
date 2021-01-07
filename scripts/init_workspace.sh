#!/bin/bash

# region="USER INPUT"
read -p "Enter region: " region
# cluster name="USER INPUT"
read -p "Enter cluster name: " cluster_name

#echo $email
#export notify_email=$email

#get kubeconfig from EKS cluster
get_eks_kubeconfig () {
    aws eks --region $region update-kubeconfig --name $cluster_name
}

create_namespace () {
    projectNs=`kubectl get ns project | sed -n 2p | awk '{print $1}'`

    if [ "$projectNs" == "project" ]; then
        echo "Namespace project already exists"
    else
        kubectl create ns project
    fi

    monitoringNs=`kubectl get ns monitoring | sed -n 2p | awk '{print $1}'`

    if [ "$monitoringNs" == "monitoring" ]; then
        echo "Namespace monitoring already exists"
    else
        kubectl create ns monitoring
    fi
}

#import gpg key to be able to decrypt helm secrets
import_gpg_key () {
    gpg --import gpg-key/private.key
}

get_eks_kubeconfig

import_gpg_key

create_namespace