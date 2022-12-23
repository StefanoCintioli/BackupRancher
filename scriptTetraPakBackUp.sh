#!/bin/sh

check_status() {
    message=$(kubectl --kubeconfig="local.yaml" get backup default-location-recurring-backup -n cattle-resources-system -o jsonpath='{.status.conditions[].message}')
    if [ "$message" = "Completed" ]
        then
            echo "The backup is completed"
        else
            check_status    
    fi
}

main() {
    value=$(kubectl --kubeconfig="local.yaml" get deploy rancher-backup -n cattle-resources-system)
    if [ -z "$value" ]
        then
            echo "There's no rancher-backup operator"
            exit 1
        else
            echo "There is a rancher-backup operator"
            backupName=$(grep name backup.yaml | cut -d ":" -f2 | cut -d ' ' -f2)
            foundName=$(kubectl --kubeconfig="local.yaml" get backup -A --no-headers -o custom-columns=":metadata.name" | grep "$backupName")
            if [ -z "$foundName" ]
                then
                    echo "No backup with this name has been found"           
                    kubectl --kubeconfig="local.yaml" apply -f backup.yaml
                    check_status
                else
                    echo "The backup was found"
                    kubectl --kubeconfig="local.yaml" get backup "$foundName" -o yaml > backup.yaml
                    kubectl --kubeconfig="local.yaml" replace --force -f backup.yaml
                    check_status    
            fi
    fi
}

main
