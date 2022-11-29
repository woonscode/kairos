## AWS_SECRET_ACCESS_KEY + AWS_ACCESS_KEY_ID environment variable must be set
# Update kubeeconfig file to interact with kubectl
aws eks update-kubeconfig --name "kairos"

# Run each command in a separate terminal and access the URL as needed

# Get auth token for eks-admin SA to use for admin permissions in Kubernetes Dashboard and copy paste into Web UI
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

# View Kubernetes Dashboard on localhost
kubectl proxy
# URL for Kubernetes Dashboard
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/workloads?namespace=_all

# View Prometheus server on localhost
kubectl -n monitoring port-forward svc/prometheus-k8s 9090
# URL for Prometheus server
# http://localhost:9090

# View AlertManager server on localhost
kubectl -n monitoring port-forward svc/alertmanager-main 9093
# URL for AlertManager server
# http://localhost:9093

# View Grafana server on localhost
kubectl -n monitoring port-forward svc/grafana 3000
# URL for Grafana server, default credentials are username: admin, password: admin but changed credentials to username: admin, password: kairos
# http://localhost:3000