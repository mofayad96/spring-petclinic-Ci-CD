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

## Setup

### Clone the repository

git clone https://github.com/mofayad96/spring-petclinic-ci-cd.git
cd spring-petclinic-ci-cd

Run Docker Compose for the Application
docker-compose -f docker-compose-petclinic.yml up -d

Run Docker Compose for the CI/CD jenkins
docker-compose -f docker-compose-jenkins-services.yml up -d

Jenkins Pipeline

The Jenkins pipeline includes the following stages:

Pull code from GitHub

SonarQube static code analysis
<img width="1899" height="904" alt="image" src="https://github.com/user-attachments/assets/f068a3ae-3f5b-47be-a3dd-02ae4da2906d" />



Build Docker image

Scan image with Trivy

Push Docker image to Docker Hub

<img width="961" height="655" alt="DOCKER-HUB-jenkinspipeline" src="https://github.com/user-attachments/assets/90168fa1-4ee2-4747-993a-89913b3291b1" />


Slack notifications for build status
<img width="1375" height="288" alt="Screenshot 2025-09-16 143016" src="https://github.com/user-attachments/assets/0013c3b7-cc9b-4c52-b633-d5ce4931b9fb" />


Environment Variables

IMAGE_NAME – Docker image name (default: spring-petclinic-app)

IMAGE_TAG – Docker image tag (auto-set from Git commit)

SONARQUBE – Jenkins SonarQube server name

SLACK_TOKEN – Jenkins Slack bot token

Monitoring

Prometheus: http://localhost:9090

Grafana: http://localhost:3000
 (default credentials: admin/admin)
