
## Quick Start

### Local Development

1. Build and run the Docker container:
   ```bash
   docker build -t currency-converter .
   docker run -p 8000:8000 -e EXCHANGE_RATE_API_KEY=your-key currency-converter

2. Access the application at http://localhost:8000


Kubernetes Deployment
1. Install the Helm chart:

bash
helm install currency-converter ./helm/currency-converter \
  --set apiKey=your-exchange-rate-api-key

2. Access the service:

bash
kubectl port-forward svc/currency-converter 8000:80
Open http://localhost:8000



Infrastructure Provisioning
1. Initialize Terraform:

bash
 cd terraform
 terraform init
2. Deploy to AWS:

bash
terraform apply -var="exchange_rate_api_key=your-key"


CI/CD Pipeline:
Triggered on push to main branch.