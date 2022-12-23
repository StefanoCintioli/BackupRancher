#!/bin/sh

check_status() {
    message=$(kubectl get backup default-location-recurring-backup -n cattle-resources-system -o jsonpath='{.status.conditions[].message}')
    if [ "$message" = "Completed" ]
        then
            echo "The backup is completed"
        else
            check_status    
    fi
}

main() {
    value=$(kubectl get deploy rancher-backup -n cattle-resources-system)
    if [ -z "$value" ]
        then
            echo "There's no rancher-backup operator"
            exit 1
        else
            echo "There is a rancher-backup operator"
            backupName=$(grep name backup.yaml | cut -d ":" -f2 | cut -d ' ' -f2)
            foundName=$(kubectl get backup -A --no-headers -o custom-columns=":metadata.name" | grep "$backupName")
            if [ -z "$foundName" ]
                then
                    echo "No backup with this name has been found"           
                    kubectl apply -f backup.yaml
                    check_status
                else
                    echo "The backup was found"
                    kubectl get backup "$foundName" -o yaml > backup.yaml
                    kubectl replace --force -f backup.yaml
                    check_status    
            fi
    fi
}

main
