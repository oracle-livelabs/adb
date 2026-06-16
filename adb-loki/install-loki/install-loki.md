# Lab 1: Install and Configure Loki

## Introduction

In this lab, you will install Grafana Loki on a compute instance in the same VCN as your Autonomous AI Database. Loki will receive log entries pushed from the database via UTL_HTTP.

*Estimated Lab Time:* 15 minutes

### Objectives

- Install Loki on a VCN compute instance
- Configure Loki for out-of-order writes (required for database log push)
- Create a systemd service for automatic startup
- Verify Loki is running and accepting push requests

### Prerequisites

- A compute instance in the same VCN/subnet as your Autonomous AI Database
- SSH access to the compute instance (via bastion or direct)

**Already have Loki installed?** If Loki is already running on your compute instance, skip to [Lab 2](?lab=deploy-dbms-loki).

## Task 1: SSH Into the Compute Instance

1. If your compute instance is in a private subnet, create a bastion port-forwarding session:

    ```bash
    
    oci bastion session create-port-forwarding \
      --bastion-id <your_bastion_ocid> \
      --target-private-ip <compute_private_ip> \
      --target-port 22 \
      --key-type PUB \
      --ssh-public-key-file ~/.ssh/id_ed25519.pub \
      --session-ttl 10800 \
      --wait-for-state SUCCEEDED
    
    ```

2. Start the SSH tunnel and connect:

    ```bash
    
    ssh -i ~/.ssh/id_ed25519 opc@<compute_private_ip>
    
    ```

## Task 2: Download and Install Loki

1. Download the Loki binary:

    ```bash
    
    cd /tmp
    LOKI_VERSION="3.4.2"
    curl -LO "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip"
    unzip loki-linux-amd64.zip
    sudo mv loki-linux-amd64 /usr/local/bin/loki
    sudo chmod +x /usr/local/bin/loki
    
    ```

2. Verify the installation:

    ```bash
    
    loki --version
    
    ```

    You should see output like: `loki, version 3.4.2`

## Task 3: Create the Loki Configuration

1. Create the data directories and system user:

    ```bash
    
    sudo mkdir -p /etc/loki /var/lib/loki/chunks /var/lib/loki/rules
    sudo useradd --system --no-create-home --shell /bin/false loki
    sudo chown -R loki:loki /var/lib/loki
    
    ```

2. Create the configuration file:

    ```bash
    
    sudo tee /etc/loki/loki-config.yaml > /dev/null << 'EOF'
    auth_enabled: false

    server:
      http_listen_port: 3100

    common:
      path_prefix: /var/lib/loki
      storage:
        filesystem:
          chunks_directory: /var/lib/loki/chunks
          rules_directory: /var/lib/loki/rules
      replication_factor: 1
      ring:
        kvstore:
          store: inmemory

    schema_config:
      configs:
        - from: 2020-10-24
          store: tsdb
          object_store: filesystem
          schema: v13
          index:
            prefix: index_
            period: 24h

    limits_config:
      allow_structured_metadata: true
      volume_enabled: true
      unordered_writes: true
      reject_old_samples: false
    EOF
    
    ```

    **Note:** The `unordered_writes: true` and `reject_old_samples: false` settings are required. Without these configurations, Loki silently drops log entries whose timestamps are older than the most recently ingested entry. This behavior occurs because the database forwards log entries using their original timestamps, which may be earlier than timestamps that Loki has already processed.

## Task 4: Create the systemd Service

1. Create the service file:

    ```bash
    
    sudo tee /etc/systemd/system/loki.service > /dev/null << 'EOF'
    [Unit]
    Description=Grafana Loki
    After=network.target

    [Service]
    Type=simple
    User=loki
    Group=loki
    ExecStart=/usr/local/bin/loki -config.file=/etc/loki/loki-config.yaml
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    EOF
    
    ```

2. Start Loki:

    ```bash
    
    sudo systemctl daemon-reload
    sudo systemctl enable loki
    sudo systemctl start loki
    
    ```

## Task 5: Verify Loki Is Ready

1. Wait for the ingester to initialize (about 20 seconds), then check:

    ```bash
    
    sleep 20
    curl -s http://localhost:3100/ready
    
    ```

    Expected output: `ready`

    Keep trying the curl command if you do not see `ready` after 20 seconds

2. Test the push API with a sample entry:

    ```bash
    
    curl -s -X POST http://localhost:3100/loki/api/v1/push \
      -H "Content-Type: application/json" \
      -d '{
        "streams": [{
          "stream": { "job": "test", "source": "curl" },
          "values": [
            ["'$(date +%s)000000000'", "Hello from Loki test push!"]
          ]
        }]
      }'
    
    ```

    No output (HTTP 204) means success.

3. If the compute instance uses `firewalld`, open port 3100:

    ```bash
    
    sudo firewall-cmd --permanent --add-port=3100/tcp
    sudo firewall-cmd --reload
    
    ```

    **Note:** Also verify that the VCN subnet security list allows inbound TCP on port 3100 from the Autonomous AI Database subnet CIDR.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - German Viscuso, Product Manager, Oracle Autonomous AI Database
- **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, June 2026
