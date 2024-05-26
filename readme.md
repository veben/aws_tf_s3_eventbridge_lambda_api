# Readme

<img src="s3_eventbridge_lambda_api.drawio.svg" alt="s3_eventbridge_lambda_api.drawio.svg" style="width:500px;height:auto;">

## 1. 📝 Preparation
- Follow [installations](https://github.com/veben/aws_terraform_snippets/blob/main/readme.md)
- Choose **Cloud hosting** and follow "Installing" and "Initialization" steps

## 2. 🪂 Deploying
- Define `TF_VAR_client_id` and `TF_VAR_client_secret` env vars with `client_id` and `client_secret` values:
- Deploy the infrastructure
```sh
terraform init; terraform plan; terraform apply --auto-approve
```

> If you have not defined env vars, `client_id` and `client_secret` are prompted

## 3. 🧪 Test the pattern

### Users creation
- Fill file `create_users.csv` with users you want to create
- Upload file to **s3-eventbridge-api-bucket** s3 bucket
- Follow logs via Cloudwatch or via CLI with below command:

```sh
log_group_name=`aws logs describe-log-groups --profile p_lambda_deployer | jq ".logGroups[].logGroupName" | tr -d '"'` && aws logs tail $log_group_name --profile p_lambda_deployer --follow
```

### Users deletion
- Fill file `delete_users.csv` with ids of users you want to delete
- Upload file to **s3-eventbridge-api-bucket** s3 bucket
- Follow logs via Cloudwatch or via CLI with below command:

```sh
log_group_name=`aws logs describe-log-groups --profile p_lambda_deployer | jq ".logGroups[].logGroupName" | tr -d '"'` && aws logs tail $log_group_name --profile p_lambda_deployer --follow
```

## 4. 🚿 Cleaning
```sh
tf destroy
```
