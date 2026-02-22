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

Load Balancers (ELB/ELBv2) are not supported in LocalStack Community edition. The Terraform code is correct and will work on real AWS, but could not be applied locally due to license restrictions.

Reference: [LocalStack Coverage](https://docs.localstack.cloud/references/coverage)
