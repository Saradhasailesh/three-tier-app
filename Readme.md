# Terraform Projects

This repository contains various Terraform projects that helped me get hands-on experience with Infrastructure as Code (IaC) using Terraform. Each project is organized in its own directory and focuses on a specific use case.

---

## 📁 Project 1: VPC with Public and Private Subnets

**Directory:** `/vpc-setup`

### 🔧 Description

This Terraform configuration sets up a custom Virtual Private Cloud (VPC) with:

- Public and private subnets across multiple availability zones
- Internet Gateway for public internet access
- NAT Gateway for secure outbound internet access from private subnets
- Separate route tables for public and private subnets

This setup is commonly used as a foundational network structure for hosting applications on the cloud.

### 🗂️ Terraform Resources Used

- `aws_vpc`
- `aws_subnet`
- `aws_internet_gateway`
- `aws_nat_gateway`
- `aws_route_table`
- `aws_route_table_association`
- `aws_eip`
- `data.aws_availability_zones`

### ⚙️ Variables (Defined in `variables.tf`)

| Name                  | Description                            | Type   | Example            |
|-----------------------|----------------------------------------|--------|--------------------|
| `public_subnet_cidrs` | List of CIDRs for public subnets       | list   | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs`| List of CIDRs for private subnets      | list   | `["10.0.101.0/24", "10.0.102.0/24"]` |

### 📦 How to Use

1. Navigate to the project folder:

    ```bash
    cd vpc-setup
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Review the execution plan:

    ```bash
    terraform plan
    ```

4. Apply the configuration:

    ```bash
    terraform apply
    ```

5. Destroy resources when done:

    ```bash
    terraform destroy
    ```

---

### ✅ Status

✅ Completed  
🧪 Tested with multiple CIDR combinations  
☁️ Cloud provider: Compatible with AWS  

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 📁 Project 2: Static Website Hosting with S3

**Directory:** `/s3-static-website`

### 🔧 Description

This Terraform configuration creates a unique-named S3 bucket for hosting a static website. It includes:

- Random suffix generation for unique bucket names
- Static website configuration with custom `index.html` and `error.html`
- Public access configuration for static content
- Upload of local HTML files to S3
- Bucket policy to allow public read access to the website

This setup is ideal for hosting simple HTML/CSS/JS websites without a backend.

### 🗂️ Terraform Resources Used

- `random_string`
- `aws_s3_bucket`
- `aws_s3_bucket_website_configuration`
- `aws_s3_bucket_public_access_block`
- `aws_s3_object`
- `aws_s3_bucket_policy`

### ⚙️ Variables (Defined in `variables.tf`)

| Name           | Description                 | Type   | Example       |
|----------------|-----------------------------|--------|---------------|
| `bucket_name`  | Base name for the S3 bucket | string | `"demo-bucket"` |

### 📁 Project Structure

s3-static-website/ ├── html/ │ ├── index.html │ └── error.html ├── main.tf ├── variables.tf └── outputs.tf


### 📦 How to Use

1. Navigate to the project directory:

    ```bash
    cd s3-static-website
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Review the plan:

    ```bash
    terraform plan
    ```

4. Apply the configuration:

    ```bash
    terraform apply
    ```

5. After deployment, you can access the website via the S3 **Website Endpoint** provided in the outputs.

6. To clean up:

    ```bash
    terraform destroy
    ```

---

### ✅ Status

✅ Completed  
🌐 Public static website is accessible via generated S3 endpoint  
📄 Files are uploaded from local `html/` folder

---

### 🧠 Learnings

> _"This project helped me understand how to serve static content from an S3 bucket, control bucket permissions and public access, and use Terraform to automate content upload and policy configuration."_

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## ☁️ Project 3: Web Server Deployment on EC2

**Directory:** `/ec2-webserver`

### 🔧 Description

This Terraform project provisions a web server on AWS EC2 with Apache installed and a custom welcome message. It also creates the required security group and SSH key pair.

### 🧱 What It Does

- Launches an EC2 instance with Apache2 installed via `user_data`
- Automatically enables and starts the Apache server
- Displays a welcome message on the root web page
- Creates a security group allowing HTTP (port 80) and SSH (port 22)
- Associates the instance with a public key

### 🗂️ Terraform Resources Used

- `aws_instance`
- `aws_security_group`
- `aws_key_pair`
- `data "aws_availability_zones"`

### ⚙️ Variables

| Name           | Description                  | Type   | Example                          |
|----------------|------------------------------|--------|----------------------------------|
| `key_name`     | Name of the SSH key pair     | string | `"webserver-key"`                |
| `public_key`   | Your public SSH key content  | string | `"ssh-rsa AAAAB3..."`            |
| `ami`          | AMI ID for the EC2 instance  | string | `"ami-0c55b159cbfafe1f0"` (Ubuntu)|
| `instance_type`| EC2 instance type            | string | `"t2.micro"`                     |

### 📁 Project Structure

ec2-webserver/ ├── main.tf ├── variables.tf └── outputs.tf


### 🚀 How to Deploy

1. Move to project folder:

    ```bash
    cd ec2-webserver
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Set values for `ami`, `public_key`, and other variables in a `terraform.tfvars` file or via CLI.

4. Run the plan:

    ```bash
    terraform plan
    ```

5. Deploy the EC2 instance:

    ```bash
    terraform apply
    ```

6. Open your browser and visit the instance's public IP to see your web page.

7. SSH into your instance (if needed):

    ```bash
    ssh -i <your-private-key>.pem ubuntu@<public-ip>
    ```

8. To destroy the infrastructure:

    ```bash
    terraform destroy
    ```

---

### ✅ Status

✅ EC2 instance launches with a running web server  
🌐 Apache serves a welcome HTML page  
🔐 Access control via security groups  

---

### 🧠 Learnings

> _"This project helped me get hands-on experience launching EC2, configuring a web server with `user_data`, managing security groups, and handling SSH access."_

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## ☁️ Project 4: Access S3 from EC2 using Terraform Modules

**Directory:** `/s3-access-ec2`

### 🔧 Description

This project demonstrates how to access an S3 bucket from an EC2 instance using **modularized Terraform code**. The infrastructure is broken into 3 modules: `vpc`, `ec2`, and `s3`.

It includes:
- A custom VPC with a public subnet
- An S3 bucket storing an `index.html` file
- An EC2 instance with an IAM role that allows it to read from the S3 bucket and serve the HTML via Apache

---

### 🗂️ Module Overview

#### 🔹 `modules/vpc/`
Creates:
- VPC
- Public Subnet
- Internet Gateway
- Route Table and Association
- Security Group allowing HTTP/HTTPS traffic

#### 🔹 `modules/s3/`
Creates:
- An S3 bucket with a unique name (using `random_string`)
- Uploads `index.html` file to the bucket

#### 🔹 `modules/ec2/`
Creates:
- Key Pair using input key name and public key
- IAM Instance Profile with a role that has S3 read access
- EC2 instance using the profile, installs Apache, and copies the S3 HTML to `/var/www/html/index.html`

---
###  Directory Structure
s3-access-ec2/
├── main.tf
├── output.tf
├── terraform.tfvars
├── variables.tf
├── modules/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── output.tf
│   ├── s3/
│   │   ├── main.tf
│   │   ├── index.html
│   │   ├── variables.tf
│   │   └── output.tf
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       └── output.tf


---

### ⚙️ Input Variables (in root)

| Name               | Description                          | Type     |
|--------------------|--------------------------------------|----------|
| `region`           | AWS region to deploy resources       | string   |
| `ami`              | AMI ID for EC2 instance              | string   |
| `instance_type`    | EC2 instance type                    | string   |
| `key_name`         | Key pair name                        | string   |
| `public_key`       | Public key value                     | string   |

---

### 🚀 How to Deploy

1. Clone the project and move to the root directory:

    ```bash
    git clone <repo-url>
    cd s3-access-ec2
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Create a `terraform.tfvars` file or pass variables via CLI.

4. Run a plan:

    ```bash
    terraform plan
    ```

5. Apply the infrastructure:

    ```bash
    terraform apply
    ```


6. Access the web server in your browser:

    ```
    http://<ec2-public-ip>
    ```

------

Navigate to EC2 by clicking on the Services menu in the top, then click on EC2 in the Compute section.

Navigate to Instances on the left panel.

![Description](./access_s3_from_ec2/instance.png)

EC2 Instance may be Pending state, wait for in to get into Running state. And, complete the Status check, it will be updated to 2/2 checks passed from Initializing

To use the Session manager feature for SSH, select the Instance and click on the Connect button.

![Description](./access_s3_from_ec2/ssm.png)

Run the first command to list all the S3 Buckets. And, copy the bucket name.

aws s3 ls
Copy the bucket name and list its objects.
Note: upload this S3 object file in your S3 bucket and follow the next command to list the s3 object in your S3 bucket.

aws s3 ls s3://<Bucket-Name>

![Description](./access_s3_from_ec2/terminal.png)
