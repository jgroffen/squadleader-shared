# commands to make ubuntu work better for me

# Install Tweaks app for gnome - mainly so I can set display scaling to 1.5
sudo apt install gnome-tweaks

# install a fully functional vim client instead of the minimal vi - which is what ubuntu
# came with ootb
sudo apt install vim

# install nvm to get the latest node and npm (ubuntu packages lag behind)
sudo apt install curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
source ~/.bashrc

# NodeJS and NPM used extensively
nvm install node

# Using pnpm, which is much faster and efficient with disk space, also enforces strict
# dependency correctness ... no phantom transitive dependencies.
npm install -g pnpm
pnpm setup
source ~/.bashrc

# Installs tsc (typescript compiler) globally
pnpm install -g typescript

# Install continue command (cn) - alternative to copilot cli that can use offline models
curl -fsSL https://raw.githubusercontent.com/continuedev/continue/main/extensions/cli/scripts/install.sh | bash

# Useful service to resolve .local hostnames on the LAN, which the host vm is advertising
sudo apt install avahi-daemon avahi-utils
sudo systemctl enable --now avahi-daemon
