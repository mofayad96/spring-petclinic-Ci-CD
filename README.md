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

- CI/CD: Jenkins
- Containerization: Docker
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

Run Docker Compose for the CI/CD Stack
docker-compose -f docker-compose-ci.yml up -d

Jenkins Pipeline

The Jenkins pipeline includes the following stages:

Pull code from GitHub

SonarQube static code analysis

Build Docker image

Scan image with Trivy

Push Docker image to Docker Hub

Slack notifications for build status

Environment Variables

IMAGE_NAME – Docker image name (default: spring-petclinic-app)

IMAGE_TAG – Docker image tag (auto-set from Git commit)

SONARQUBE – Jenkins SonarQube server name

SLACK_TOKEN – Jenkins Slack bot token

Monitoring

Prometheus: http://localhost:9090

Grafana: http://localhost:3000
 (default credentials: admin/admin)
