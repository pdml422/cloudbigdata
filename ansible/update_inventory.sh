#!/bin/bash
cd ../terraform

MASTER_IP=$(terraform output spark_master_public_ip | sed 's/"//g')
EDGE_IP=$(terraform output spark_edge_public_ip | sed 's/"//g')

WORKER_IPS_RAW=$(terraform output spark_workers_public_ips)

worker_ips=()
if [[ $WORKER_IPS_RAW == *"["* ]]; then
    TEMP_FILE=$(mktemp)
    terraform output spark_workers_public_ips > $TEMP_FILE
    
    while IFS= read -r line; do
        if [[ $line == *\"* ]]; then
            ip=$(echo $line | grep -oE '"([0-9]{1,3}\.){3}[0-9]{1,3}"' | sed 's/"//g')
            if [[ -n $ip ]]; then
                worker_ips+=("$ip")
            fi
        fi
    done < $TEMP_FILE
    rm $TEMP_FILE
fi

cat > ../ansible/inventory.ini << EOF
[spark_master]
spark-master ansible_host=$MASTER_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/cbd_gcp

[spark_workers]
EOF

for i in "${!worker_ips[@]}"; do
    echo "spark-worker-$i ansible_host=${worker_ips[$i]} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/cbd_gcp" >> ../ansible/inventory.ini
done

cat >> ../ansible/inventory.ini << EOF

[spark_edge]
spark-edge ansible_host=$EDGE_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/cbd_gcp

[spark_all:children]
spark_master
spark_workers
spark_edge
EOF

echo "=== Inventory Updated ==="
echo "Master: $MASTER_IP"
echo "Workers: ${#worker_ips[@]} nodes"
for i in "${!worker_ips[@]}"; do
    echo "  Worker $i: ${worker_ips[$i]}"
done
echo "Edge: $EDGE_IP"
echo "Inventory file: ../ansible/inventory.ini"
