# cloudbigdata

## Deploy infrastructure (Terraform)
```
cd terraform
terraform init
terraform plan
terraform apply
terraform output > ../ansible/terraform_outputs.txt
```
## Configure Spark and run word count (Ansible)
```
cd ansible
./update_inventory.sh
ansible -i inventory.ini spark_all -m ping
ansbile-playbook -i inventory.ini playbooks/common.yml
ansbile-playbook -i inventory.ini playbooks/spark.yml
ansbile-playbook -i inventory.ini playbooks/test.yml
```
## Cleanup
```
cd terraform
terraform destroy
```
