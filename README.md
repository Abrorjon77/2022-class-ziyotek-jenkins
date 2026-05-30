# 2022 Class Ziyotek — Jenkins + Terraform CI/CD

A Jenkins-driven Terraform project that automatically provisions AWS infrastructure on every git push. Jenkins pulls the code, runs Terraform to create the infrastructure, and deploys a static website to an S3 bucket.

---

## What This Project Does

```
Git Push → Jenkins Pipeline → Terraform init → Terraform apply → S3 Static Website live
```

On every push to the repository, Jenkins:
1. Initializes Terraform and verifies AWS/Terraform versions
2. Runs `terraform apply` to create all AWS infrastructure
3. Uploads `assets/index.html` to an S3 static website bucket

---

## Repository Structure

```
.
├── Jenkinsfile                  # Jenkins pipeline definition (3 stages)
├── README.md                    # This file
├── FIXES.md                     # List of bugs fixed from original repo
├── test.txt                     # Test file used to trigger pipeline runs
├── assets/
│   └── index.html               # Static HTML page deployed to S3
└── terraform/
    ├── provider.tf              # AWS provider + S3 remote backend config
    ├── vpc.tf                   # VPC, subnets, security group
    ├── s3.tf                    # S3 bucket, website hosting, file upload
    ├── iam.tf                   # IAM role, policy, instance profile for EC2
    ├── data.tf                  # AMI lookup, region, account ID data sources
    └── variables.tf             # All input variables with defaults
```

---

## File Definitions

### Root Files

| File | Description |
|------|-------------|
| `Jenkinsfile` | Defines the 3-stage Jenkins pipeline: **Prep** (checks aws/terraform versions), **Build** (runs `terraform init`), **Deploy** (runs `terraform apply -auto-approve`). |
| `assets/index.html` | The static HTML page titled "Terramino" that gets uploaded to S3 and served as a public website. Edit this file to change what the website shows. |
| `test.txt` | A simple text file used to trigger new pipeline runs by making a small commit and push. |
| `FIXES.md` | Documents all bugs that were identified and fixed from the original repository. |

---

### `terraform/provider.tf`

Configures the AWS provider and the Terraform remote backend.

- Sets AWS region to `us-east-1`
- Tags **all** resources with `owner = "Abrorjon"` automatically via `default_tags`
- Uses an **S3 remote backend** to store Terraform state

**⚠️ You must change this before running:**
```hcl
terraform {
  backend "s3" {
    bucket = "YOUR_TERRAFORM_STATE_BUCKET"  # ← replace with your S3 bucket name
    key    = "tfstate"
    region = "us-east-1"
  }
}
```

---

### `terraform/vpc.tf`

Creates the AWS network infrastructure:

| Resource | Value |
|----------|-------|
| VPC | CIDR `172.26.0.0/16`, tagged `ziytek-class` |
| Subnet 1 | `172.26.10.0/24` in `us-east-1a` |
| Subnet 2 | `172.26.20.0/24` in `us-east-1b` |
| Security Group | Allows **all inbound and outbound traffic** (`0.0.0.0/0`) |

> ⚠️ The security group allows all traffic — fine for learning, tighten for production.

---

### `terraform/s3.tf`

Creates the S3 static website:

| Resource | Description |
|----------|-------------|
| `aws_s3_bucket` | Bucket named `{bucket_name}-{AWS_account_id}` — account ID makes it globally unique |
| `aws_s3_bucket_policy` | Makes all objects in the bucket publicly readable (`s3:GetObject`) |
| `aws_s3_bucket_website_configuration` | Enables static website hosting with `index.html` as the root document |
| `aws_s3_object` | Uploads `assets/index.html` from the repo directly into the bucket |

After `terraform apply`, your website is live at:
```
http://{bucket-name}.s3-website-us-east-1.amazonaws.com
```

---

### `terraform/iam.tf`

Creates IAM resources so EC2 instances can access the S3 bucket:

| Resource | Description |
|----------|-------------|
| `aws_iam_role` | Role named `ec2_s3_role` — allows EC2 service to assume it |
| `aws_iam_policy` | Policy named `s3_access_policy` — grants full `s3:*` access to the dev bucket |
| `aws_iam_policy_attachment` | Attaches the policy to the role |
| `aws_iam_instance_profile` | Wraps the role as `s3-access-profile` — attach this to EC2 instances |

---

### `terraform/data.tf`

Fetches dynamic values from AWS at runtime:

| Data Source | What it gets | Used by |
|-------------|-------------|---------|
| `aws_ami` | Latest Amazon Linux 2 AMI ID | Available for EC2 use |
| `aws_region` | Current AWS region (`us-east-1`) | Available for resource naming |
| `aws_caller_identity` | Your AWS account ID | S3 bucket name uniqueness |

Also outputs the latest AMI ID to the console after `terraform apply`.

---

### `terraform/variables.tf`

All configurable inputs. Most have sensible defaults — only change what you need:

| Variable | Default | Description |
|----------|---------|-------------|
| `vpc_cidr_block` | `172.26.0.0/16` | IP range for the VPC |
| `subnet_1_cidr` | `172.26.10.0/24` | IP range for subnet in `us-east-1a` |
| `subnet_2_cidr` | `172.26.20.0/24` | IP range for subnet in `us-east-1b` |
| `bucket_name` | `terraform-jenkins-class-ziyotek` | Base name for the S3 bucket (account ID is appended) |
| `environment` | `dev` | Environment label used in tags |
| `instance_type` | `t2.micro` | EC2 instance size (not used unless you add an EC2 resource) |
| `ingress_cidr_blocks` | `["0.0.0.0/0"]` | IP ranges allowed into the security group |

---

## Files You Must Change Before Running

### 1. `terraform/provider.tf` — S3 backend bucket (required)

You must create an S3 bucket in your AWS account and set it here:

```hcl
backend "s3" {
  bucket = "your-unique-bucket-name"   # ← change this
  key    = "tfstate"
  region = "us-east-1"
}
```

Create the bucket first:
```bash
aws s3 mb s3://your-unique-bucket-name --region us-east-1
```

### 2. `assets/index.html` — Website content (optional)

Edit this to customize what your S3 website shows:
```html
<h1>Welcome to Terramino</h1>
<p>Environment: dev</p>
```

### 3. `terraform/variables.tf` — Bucket name (optional)

Change the S3 app bucket base name if you want:
```hcl
variable "bucket_name" {
  default = "your-preferred-bucket-name"   # ← change this
}
```

---

## How to Run

### Prerequisites

**1. Install Terraform**
```bash
curl -qL -o terraform.zip https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
unzip terraform.zip && mv terraform /usr/local/bin/
terraform version
```

**2. Configure AWS credentials**
```bash
aws configure
# AWS Access Key ID, Secret Key, Region: us-east-1
```

**3. Create the S3 state bucket**
```bash
aws s3 mb s3://your-state-bucket-name --region us-east-1
```

**4. Update `terraform/provider.tf`** with your bucket name (see above).

---

### Option A — Run Terraform Directly (no Jenkins)

```bash
cd terraform

terraform init      # connects to S3 backend, downloads AWS provider
terraform validate  # checks for syntax errors
terraform plan      # previews what will be created
terraform apply     # creates all AWS resources (type 'yes' to confirm)
```

**What gets created (~1–2 minutes):**
- VPC with 2 subnets and a security group
- IAM role, policy, and instance profile
- S3 bucket with public website hosting
- `index.html` uploaded and live at the S3 website URL

To get your website URL after apply:
```bash
terraform output
# or
aws s3api get-bucket-website --bucket your-bucket-name-YOUR_ACCOUNT_ID
```

To destroy everything:
```bash
terraform destroy
```

---

### Option B — Run via Jenkins Pipeline

This triggers automatically on every git push to the repo.

#### Step 1 — Set up a Jenkins server

Jenkins must be running with:
- **AWS CLI** installed and configured with credentials
- **Terraform** installed (v1.5.7 recommended)
- A **GitHub webhook** or polling configured to trigger builds on push

#### Step 2 — Create a Jenkins Pipeline job

1. Open Jenkins → **New Item → Pipeline**
2. Name it (e.g. `ziyotek-terraform`)
3. Under **Pipeline**, select **Pipeline script from SCM**
4. Set **SCM** to Git, enter your repo URL
5. Set **Branch** to `*/main`
6. Set **Script Path** to `Jenkinsfile`
7. Click **Save**

#### Step 3 — Configure AWS credentials on Jenkins

Option 1 — IAM Instance Profile (recommended if Jenkins runs on EC2):
- Attach an IAM role to the Jenkins EC2 instance with permissions for: EC2, VPC, S3, IAM

Option 2 — AWS credentials in Jenkins:
```
Jenkins → Manage Jenkins → Credentials → Add:
  Kind: AWS Credentials
  Access Key ID: your-key
  Secret Access Key: your-secret
```

Then reference in Jenkinsfile:
```groovy
environment {
    AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
}
```

#### Step 4 — Trigger the pipeline

```bash
# Make any change and push
echo "trigger" >> test.txt
git add . && git commit -m "trigger pipeline"
git push origin main
```

Jenkins picks up the push and runs the 3 stages automatically.

---

## What Happens on Each Pipeline Run

```
git push origin main
       │
       ▼
┌─────────────────────┐
│  Stage 1: Prep       │  Prints "Preparing..."
│                      │  Checks: aws --version
│                      │  Checks: terraform --version
└──────────┬───────────┘
           │
           ▼
┌─────────────────────┐
│  Stage 2: Build      │  cd terraform
│                      │  terraform init
│                      │  → Downloads AWS provider
│                      │  → Connects to S3 backend
└──────────┬───────────┘
           │
           ▼
┌─────────────────────┐
│  Stage 3: Deploy     │  cd terraform
│                      │  terraform apply -auto-approve
│                      │  → Creates VPC, subnets, SG
│                      │  → Creates IAM role + policy
│                      │  → Creates S3 bucket
│                      │  → Enables website hosting
│                      │  → Uploads index.html
│                      │  Website is now live!
└─────────────────────┘
```

Total time: **~2–3 minutes**

---

## What You'll See in AWS Console After Apply

| Service | Resource |
|---------|----------|
| **VPC** | 1 VPC (`172.26.0.0/16`), 2 subnets, 1 security group |
| **S3** | 1 bucket named `terraform-jenkins-class-ziyotek-{account_id}` with website hosting enabled |
| **IAM** | Role `ec2_s3_role`, policy `s3_access_policy`, instance profile `s3-access-profile` |

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `No valid credential sources` | AWS CLI not configured on Jenkins agent | Run `aws configure` on the Jenkins server or attach IAM role to Jenkins EC2 |
| `BucketNotFound` on `terraform init` | State bucket doesn't exist | Create it: `aws s3 mb s3://your-bucket` |
| `BucketAlreadyExists` | S3 app bucket name taken globally | Change `bucket_name` in `variables.tf` |
| `terraform: command not found` | Terraform not installed on Jenkins agent | Install Terraform on the Jenkins server |
| `AccessDenied` on S3 bucket policy | AWS account has S3 Block Public Access enabled | Go to S3 Console → Block Public Access settings → disable for the bucket |

---

## AWS Costs

| Resource | Cost |
|----------|------|
| VPC, Subnets, Security Group | Free |
| S3 bucket + website hosting | ~$0.023/GB storage, minimal for small files |
| IAM resources | Free |

Always run `terraform destroy` when done to avoid any storage charges.

---

## Fixes Applied to Original Repo

See [FIXES.md](./FIXES.md) for full details. Summary:

| # | File | Fix |
|---|------|-----|
| 1 | `terraform/iam.tf` | Fixed IAM policy ARNs from string literals to proper Terraform resource references |
| 2 | `terraform/provider.tf` | Replaced hardcoded personal S3 bucket with `YOUR_TERRAFORM_STATE_BUCKET` placeholder |
| 3 | `assets/index.html` | Fixed broken HTML structure (missing tags, orphan closing tags) |
| 4 | `Jenkinsfile` | Added version checks to Prep stage for easier debugging |
