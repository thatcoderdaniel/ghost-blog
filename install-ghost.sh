#!/bin/bash
set -e

echo "🚀 Installing Ghost on VM..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18 (required for Ghost)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Ghost CLI
sudo npm install ghost-cli@latest -g

# Create Ghost directory
sudo mkdir -p /var/www/ghost
sudo chown $USER:$USER /var/www/ghost
chmod 775 /var/www/ghost

# Navigate to Ghost directory
cd /var/www/ghost

# Install MySQL client for database connection
sudo apt install -y mysql-client-8.0

echo "✅ Prerequisites installed! Ready for Ghost installation."

# Install Ghost
echo "📦 Installing Ghost..."
ghost install local --db mysql

echo "🎯 Ghost installation complete!"
echo "VM External IP: $(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/external-ip -H "Metadata-Flavor: Google")"
echo "Ghost will be available at: http://$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/external-ip -H "Metadata-Flavor: Google"):2368"