Malaa DevOps Exercise - Phase 1

What I Built

A secure private virtual network on AWS using Terraform and LocalStack locally on my machine without needing a real AWS account.

Tools I Used

- **Terraform** - to write infrastructure as code
- **LocalStack** - to simulate AWS locally on my machine
- **Docker** - to run LocalStack

How to Run

1. Start LocalStack

```bash
docker run -d --rm \
  -p 4566:4566 \
  --name localstack \
  localstack/localstack
```

2. Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

Project Structure

```
Malaa/
├── main.tf
├── providers.tf
└── modules/
    └── networking/
        ├── main.tf
        └── variables.tf
```

Network Architecture

<img width="1334" height="1180" alt="image" src="https://github.com/user-attachments/assets/4f67ff37-1fab-48b1-913c-cb0bb48f73a8" />




Resources Created

| Resource        | Description                              |
| --------------- | ---------------------------------------- |
| VPC             | Main network                             |
| Internet Gateway | Connection to the internet               |
| Elastic IP      | Static IP for NAT Gateway                |
| NAT Gateway     | Allows private subnets to reach internet |
| Public Subnet   | For the public Load Balancer             |
| DMZ Subnet      | For the Firewall                         |
| Servers Subnet  | For web servers                          |
| Database Subnet | For databases                            |
| Route Tables    | Controls traffic routing                 |
| Security Groups | Controls who can access what             |



Security Rules I Applied

| Component   | Ports      | Allowed From   |
| ----------- | ---------- | -------------- |
| Public LB   | 80, 443    | Anywhere       |
| DMZ         | 80, 443    | Public LB only |
| Servers     | 80, 443    | DMZ only       |
| Database    | 8080, 26257 | Servers only   |



Known Limitations

Load Balancers (ELB/ELBv2) are not supported in LocalStack Community edition, could not be applied locally due to license restrictions.

Reference: [LocalStack Coverage](https://docs.localstack.cloud/references/coverage)


=========================================

# Phase 2 - Kubernetes Applications

## What I Built

### 1. EKS Cluster

3 worker nodes (m5.xlarge)
Kubernetes version 1.31

### 2. PostgreSQL Database

Storage: 10Gi
Used for Retool backend

### 3. Retool

Internal application builder
Connected to PostgreSQL

### 4. Demo API

Custom Helm Chart
3 replicas
Simple HTTP echo service

### 5. Nginx Ingress

Routes traffic to services
Internal LoadBalancer

## Files

```
modules/eks/
├── main.tf
├── variables.tf
├── outputs.tf
└── helm-charts/
    └── demo-api/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            └── ingress.yaml
```

## Commands

```bash
terraform init   # Success
terraform plan   # Success
terraform apply  # Cannot test (LocalStack LoadBalancer issue)
```

---

# Phase 3 - Logging (ELK Stack)

## What I Built

### 1. Elasticsearch
- 3 replicas
- 30Gi storage per replica
- Stores all logs

### 2. Kibana
- Web UI for viewing logs
- Port 5601

### 3. Vector
- Collects logs from all pods
- Sends to Elasticsearch

## Files
```
modules/elk/
├── main.tf
└── outputs.tf
```

## How It Works

```
Pods → Vector → Elasticsearch → Kibana
Vector collects logs and adds:

App name
Namespace
Pod name
Container name
```

## Commands

```bash
terraform init   # Success
terraform plan   # Success
terraform apply  # Cannot test (LocalStack LoadBalancer issue)
```

## Known Issue

LocalStack does not fully support LoadBalancers

Init and Plan work
Cannot test Apply