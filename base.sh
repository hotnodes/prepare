#!/bin/bash

echo "#############################"
echo "Installing basic packages..."
apt -qq update \
&& apt -qq -y --no-install-recommends install man bc tmux zsh htop smartmontools \
fail2ban cpufrequtils git gawk jq make clang pkg-config libssl-dev

# node.js 
# curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && apt-get install -y nodejs

echo "##################"
echo 'Setting up zsh...'
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
echo 'export HOSTNAME_SHORT=$(hostname -s)' >> ~/.zshrc
. /etc/os-release
echo '. /etc/os-release' >> ~/.zshrc
echo 'PROMPT="%{$FG[245]%}[${ID}-${VERSION_ID}]%{$reset_color%} %{$FG[216]%}$(hostname -s)%{$reset_color%} %{$FX[bold]$FG[081]%}$LOGNAME%{$reset_color%} %f%b %F{blue}%~%f $(git_prompt_info)"' >> ~/.zshrc
echo 'HISTSIZE=100000' >> ~/.zshrc
echo 'HISTFILE=~/.zsh_history' >> ~/.zshrc
echo 'SAVEHIST=100000' >> ~/.zshrc
echo 'HISTDUP=erase' >> ~/.zshrc


echo '#################################'
echo 'Applying cpufrequtils settings...'
echo "ENABLE='true'
GOVERNOR='performance'
MAX_SPEED='0'
MIN_SPEED='0'
" >> /etc/default/cpufrequtils
systemctl -q enable cpufrequtils
systemctl -q restart cpufrequtils


echo '###########################'
echo 'Configuring limits.conf...'
echo '*    soft    nofile  1048576
*    hard    nofile  1048576

*    soft    nproc   1048576
*    hard    nproc   1048576
' >> /etc/security/limits.conf

echo '###################################'
echo 'Applying openssh-server settings...'
sed -i 's|^PermitRootLogin .*|PermitRootLogin yes|' /etc/ssh/sshd_config
sed -i 's|^ChallengeResponseAuthentication .*|ChallengeResponseAuthentication no|' /etc/ssh/sshd_config
sed -i 's|^#PasswordAuthentication .*|PasswordAuthentication no|' /etc/ssh/sshd_config
sed -i 's|^#PermitEmptyPasswords .*|PermitEmptyPasswords no|' /etc/ssh/sshd_config
sed -i 's|^#PubkeyAuthentication .*|PubkeyAuthentication yes|' /etc/ssh/sshd_config
sed -i 's|^#HostBasedAuthentication .*|HostBasedAuthentication no|' /etc/ssh/sshd_config

echo "###########################"
echo 'Applying sysctl settings...'
sysctl -wq vm.swappiness=5
sysctl -wq vm.overcommit_memory=1
sysctl -wq net.core.rmem_default=10000000
sysctl -wq net.core.rmem_max=10000000
sysctl -wq net.core.wmem_default=10000000
sysctl -wq net.core.wmem_max=10000000
sysctl -wq net.ipv4.tcp_mem='80000000 80000000 80000000'
sysctl -wq net.ipv4.tcp_rmem='80000000 80000000 80000000'
sysctl -wq net.ipv4.tcp_wmem='80000000 80000000 80000000'
sysctl -wq net.ipv4.tcp_syncookies=0
sysctl -wq net.ipv4.conf.all.log_martians=1
sysctl -wq net.core.somaxconn=131072
sysctl -wq net.ipv4.conf.all.send_redirects=0
sysctl -wq net.ipv4.conf.all.accept_redirects=0
sysctl -wq net.ipv4.conf.all.accept_source_route=0
sysctl -wq net.ipv4.tcp_slow_start_after_idle=0
sysctl -wq net.ipv4.tcp_keepalive_time=60
sysctl -wq net.ipv4.tcp_keepalive_intvl=10
sysctl -wq net.ipv4.tcp_fin_timeout=5
sysctl -wq net.ipv4.tcp_max_tw_buckets=2000000
sysctl -wq net.ipv4.tcp_congestion_control=highspeed
sysctl -wq net.ipv4.tcp_ecn=0
sysctl -wq net.ipv4.tcp_fastopen=3
sysctl -wq net.ipv4.tcp_sack=1
sysctl -wq net.ipv4.tcp_fack=1
sysctl -wq net.ipv4.tcp_timestamps=0
sysctl -wq net.ipv4.tcp_window_scaling=1
sysctl -wq net.ipv4.tcp_low_latency=1
sysctl -wq net.ipv4.tcp_tw_reuse=1
sysctl -wq net.ipv4.tcp_keepalive_probes=5
sysctl -wq net.ipv4.tcp_max_syn_backlog=131072
sysctl -wq net.core.netdev_max_backlog=131072
sysctl -wq fs.file-max=20633088
sysctl -wq fs.nr_open=20633088
sysctl -wq kernel.pid_max=4194304
sysctl -wq fs.inotify.max_user_watches=1048576
sysctl -wq fs.inotify.max_queued_events=1048576
sysctl -wq fs.inotify.max_user_instances=1048576
sysctl -wq fs.aio-max-nr=1048576
sysctl -p

zsh
