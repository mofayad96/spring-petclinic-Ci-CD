# Recommended Updates for Spring Petclinic CI/CD

## Executive Summary
The repository already shows breadth across Docker, Kubernetes, Terraform, AWS, SonarQube, and Trivy. To make it stronger for hiring, the next step is to reduce the demo feel and increase production credibility: remove Jenkins references, harden security, use managed cloud services, and make CI/CD and observability more realistic.

## 1. Architecture
What is weak:
- The application is still effectively a single-instance deployment.
- The AWS infrastructure is tied to one EC2 host and one public subnet.
- The Helm chart has inconsistencies between the service and ingress configuration.

Recommended updates:
- Move the runtime to Amazon EKS or ECS Fargate.
- Put the database on Amazon RDS instead of a containerized MySQL instance.
- Standardize the Helm chart so service name, port, and ingress match.
- Add separate values files for dev, staging, and production.

Why this helps hiring:
- Shows you can design real deployment topology, not just containerize an app.

## 2. Scalability
What is weak:
- Replicas are set to 1.
- Autoscaling is disabled.
- CPU/memory requests and limits are not defined.

Recommended updates:
- Enable Horizontal Pod Autoscaler.
- Add resource requests and limits.
- Add rolling update strategy and PodDisruptionBudget.
- Use managed node groups or ECS autoscaling.

Why this helps hiring:
- Demonstrates you understand capacity, resilience, and safe scaling.

## 3. Security
What is weak:
- AWS credentials are long-lived secrets in CI.
- The EC2 security group allows broad public access.
- Kubernetes secrets are committed in the repo.
- Container and pod security hardening is minimal.

Recommended updates:
- Use GitHub OIDC to assume an AWS role.
- Move secrets to AWS Secrets Manager or External Secrets Operator.
- Drop root privileges in containers and Kubernetes pods.
- Restrict public access behind an ALB or VPN.
- Add image signing with cosign and policy checks with Conftest or OPA.

Why this helps hiring:
- Security is a strong filter in real DevOps interviews.

## 4. CI/CD
What is weak:
- The GitHub Actions workflow is manually triggered.
- Tests are skipped before packaging.
- Terraform apply runs in the same pipeline with auto-approve.
- Deployment is not versioned or promoted through environments.

Recommended updates:
- Add PR validation workflow.
- Run unit tests, integration tests, and package builds separately.
- Tag Docker images by Git commit SHA.
- Add staging and production environments with approvals.
- Consider GitOps with Argo CD or blue/green deployment with CodeDeploy.

Why this helps hiring:
- Shows disciplined release engineering, traceability, and rollback readiness.

## 5. Monitoring & Observability
What is weak:
- Prometheus only scrapes itself and node-exporter.
- There are no alert rules, dashboards, or tracing.
- Logging is not centralized.

Recommended updates:
- Add Micrometer Prometheus metrics for the Spring app.
- Create Grafana dashboards for app and infrastructure health.
- Add Alertmanager routing to Slack or PagerDuty.
- Add centralized logging with Loki or CloudWatch.
- Add OpenTelemetry tracing with Jaeger or Tempo.

Why this helps hiring:
- Shows the system can be operated, not just deployed.

## 6. Infrastructure as Code
What is weak:
- Terraform hard-codes VPC and subnet IDs.
- The infrastructure is not modularized.
- Remote state exists but locking and environment separation are not shown.

Recommended updates:
- Convert Terraform to reusable modules.
- Use variables, outputs, and environment-specific folders.
- Add remote state locking with DynamoDB.
- Run tfsec, Checkov, or TFLint in CI.

Why this helps hiring:
- Modular IaC is a standard expectation in stronger DevOps roles.

## 7. Cloud Usage
What is weak:
- AWS use is limited to EC2, IAM, S3, SSM, and a manual deployment flow.
- There is no evidence of managed compute, managed database, or managed ingress.

Recommended updates:
- Use ECR for image storage.
- Use RDS for the database.
- Use ALB in front of the app.
- Add CloudWatch logs and alarms.
- Prefer EKS or ECS for runtime management.

Why this helps hiring:
- Makes the project look like an AWS-native platform, not a lab exercise.

## 8. Remove Jenkins References
What to update:
- Remove Jenkins mentions from the README and any public project summary.
- Present GitHub Actions as the primary CI/CD system.
- Keep Jenkins only if you can show a clear operational reason for it.

Why this helps hiring:
- A cleaner story is easier to understand and stronger in screening.

## 9. Priority Order
If you only do a few things, do these first:
1. Move to GitHub Actions only and remove Jenkins references.
2. Fix Terraform to use modules, variables, and safer AWS networking.
3. Move secrets to a managed secret store and adopt OIDC.
4. Add real app metrics, dashboards, and alerts.
5. Deploy to EKS or ECS with a proper rollout strategy.

## 10. Execution Plan (Argo CD + AWS)
This plan assumes you keep Helm and use Argo CD for GitOps delivery.

Week 1: Foundation and CI hygiene
- Clean workflows and enforce pull request checks.
- Add jobs for unit tests, integration tests, and security scans.
- Tag images with commit SHA and push to Amazon ECR.
- Outcome: every change is validated and traceable to an immutable image.

Week 2: Terraform refactor
- Split Terraform into modules: network, compute, iam, observability, and app platform.
- Replace hard-coded IDs with variables and environment tfvars files.
- Add remote state locking with DynamoDB.
- Outcome: reproducible infrastructure across dev, staging, and prod.

Week 3: Kubernetes hardening
- Keep Helm chart and fix service and ingress consistency.
- Add requests/limits, pod security context, probes, and PodDisruptionBudget.
- Enable HPA with sensible min/max values.
- Outcome: safer, scalable runtime behavior in cluster.

Week 4: Argo CD GitOps deployment
- Install Argo CD in cluster and create Application manifests for the Helm chart.
- Use separate values files per environment.
- Configure automatic sync in dev and manual approval gate for production.
- Outcome: auditable Git-driven releases with easy rollback.

Week 5: Secrets and identity
- Replace static AWS keys in CI with GitHub OIDC and IAM role assumption.
- Move application and database secrets to AWS Secrets Manager.
- Integrate Kubernetes secrets with External Secrets Operator.
- Outcome: reduced credential risk and enterprise-grade secret flow.

Week 6: Observability and alerting
- Expose application metrics via Actuator and Prometheus scrape config.
- Add Grafana dashboards for app latency, error rate, CPU, memory, and pod restarts.
- Add Alertmanager rules with Slack notifications for SLO breaches.
- Outcome: measurable reliability and faster incident response.

Week 7: Release strategy
- Add canary or blue-green deployment using Argo Rollouts.
- Define rollback triggers based on failed health checks and error budgets.
- Outcome: lower deployment risk and production confidence.

Week 8: Portfolio and hiring proof
- Document architecture diagram, runbook, incident playbook, and deployment flow.
- Add metrics in README: deployment frequency, lead time, change failure rate, MTTR.
- Outcome: recruiter-ready evidence of impact, not just tooling.

Deliverables checklist
1. GitHub Actions pipeline with quality, security, and deploy gates.
2. Modular Terraform with multi-environment support.
3. Argo CD Application manifests managing Helm releases.
4. Hardened Kubernetes workloads and autoscaling.
5. Observable platform with alerts and dashboards.
6. README and CV bullets updated with measurable outcomes.

## 11. Recruiter Signal in 10 Seconds
What stands out most:
- Spring Boot application delivered through GitHub Actions.
- Docker, Terraform, AWS, Kubernetes, SonarQube, Trivy, Prometheus, and Grafana.
- Security and observability are present, not just mentioned.
- The deployment path is production-oriented and repeatable.
