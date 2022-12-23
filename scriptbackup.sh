#!/bin/bash





repoVersion=$(gh release list --repo rancher/rancher --exclude-drafts | grep 'Latest' | awk '{ print $1}')

serverVersion=$(kubectl --kubeconfig="local.yaml" get deploy rancher -n cattle-system -o jsonpath='{.spec.template.spec.containers[*].image}' | cut -d ":" -f2)

if [ "$repoVersion" != "$serverVersion" ]
    then
        ./scriptTetraPakBackUp.sh
        RancherRepo=$(helm repo list | grep 'rancher-latest')
        if [ -z "$RancherRepo" ]
            then
                helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

                helm repo update
            else
                helm repo update
            fi    
    helm --kubeconfig="local.yaml" upgrade --install rancher rancher-latest/rancher --namespace cattle-system --set hostname=rancher-cluster0-dns.westeurope.cloudapp.azure.com --set bootstrapPassword=admin --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=stefano.cintioli@icub.it --set letsEncrypt.ingress.class=nginx --set ingress.ingressClassName=nginx
fi
echo "la versione è aggiornata"
