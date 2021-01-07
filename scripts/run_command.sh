#!/bin/bash

grafana_portforward() {
    export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}") && wait
    echo "Pod name: $POD_NAME"

    kubectl --namespace monitoring port-forward --address 0.0.0.0 $POD_NAME 3000 &

    pass=$(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode) ; echo "Grafana credentials: admin | $pass"
}

prometheus_portforward() {
    export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace monitoring port-forward --address 0.0.0.0 $POD_NAME 9090 &
}

alertmanager_portforward() {
    export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=alertmanager" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace monitoring port-forward --address 0.0.0.0 $POD_NAME 9093 &
}

run_app_load_on_app() {
    export APP_POD=$(kubectl get pods --namespace project -l "app=kanban-app,group=backend" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace project exec -it $APP_POD -- /bin/sh -c "for i in {1..3}; do dd if=/dev/zero of=/dev/null; done"
}

gpg_agent_reload() {
    GPG_TTY=$(tty)
    export GPG_TTY
}

"$@"