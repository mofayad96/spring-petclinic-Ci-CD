
# Spring Petclinic CI/CD

This repository contains a CI/CD pipeline for the Spring Petclinic application. It integrates Jenkins, Docker, SonarQube, Trivy, Prometheus, and Grafana to automate building, testing, scanning, and deployment.

---

## Features

- Automated code pull from GitHub.
- Static code analysis using SonarQube to ensure code quality.
- Builds a multi-stage Docker image for optimized deployment.
- Scans Docker images for critical vulnerabilities using Trivy.
- CI/CD pipeline managed with Jenkins, including Docker-in-Docker support.
- Monitoring using Prometheus and Grafana.
- Sends build status notifications to a Slack channel.

---

## Tech Stack

- CI/CD: Jenkins, Github Actions
- container orchestration: Kubernetes
- Containerization: Docker
- Infrastructure as Code (IaC): Terraform
- Cloud Platform: AWS
- Code Quality: SonarQube
- Security: Trivy
- Monitoring: Prometheus & Grafana
- Build Tool: Maven
- Application: Spring Boot (Spring Petclinic)

---

Craeting The VPC Steps



1: Create the VPC

```themoosalah@themoosalah-device:~$ aws ec2 create-vpc --cidr-block 10.0.0.0/16```

Step 2: Enable DNS Support and Hostnames

```themoosalah@themoosalah-device:~$ aws ec2 modify-vpc-attribute --vpc-id vpc-0f6ef4508bcc5849b --enable-dns-support "{\"Value\":true}"```
  

```themoosalah@themoosalah-device:~$ aws ec2 modify-vpc-attribute --vpc-id vpc-0f6ef4508bcc5849b --enable-dns-hostnames "{\"Value\":true}"```

Step 3: Create and Attach an Internet Gateway

```themoosalah@themoosalah-device:~$ aws ec2 create-internet-gateway```


Step 4: Create a Public Subnet

```themoosalah@themoosalah-device:~$ aws ec2 create-subnet --vpc-id vpc-0f6ef4508bcc5849b --cidr-block 10.0.1.0/24 --availability-zone eu-central-1a```

Step 5: Create a Public Route Table and Route to Internet Gateway


```aws ec2 create-route-table --vpc-id vpc-0f6ef4508bcc5849b```

```aws ec2 create-route --route-table-id rtb-00bfc75e3174d7c2a --destination-cidr-block 0.0.0.0/0 --gateway-id igw-05bbdadba377cdfd6```

```aws ec2 associate-route-table --subnet-id subnet-0336eade49f6e9092 --route-table-id rtb-00bfc75e3174d7c2a```


Step 6: Tag the VPC

```themoosalah@themoosalah-device:~$ aws ec2 create-tags --resources vpc-0f6ef4508bcc5849b --tags Key=Name,Value=petclinic_vpc```

Step 7: Create a Private Subnet

```themoosalah@themoosalah-device:~$ aws ec2 create-subnet --vpc-id vpc-0f6ef4508bcc5849b --cidr-block 10.0.2.0/24 --availability-zone eu-central-1b --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-Subnet}]'```

Step 8: Create a Private Route Table

```themoosalah@themoosalah-device:~$ aws ec2 create-route-table --vpc-id vpc-0f6ef4508bcc5849b --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private-RT}]'```


```themoosalah@themoosalah-device:~$ aws ec2 associate-route-table --subnet-id subnet-0a6163c98fa5d7370 --route-table-id rtb-0e0ac056432cc3006```