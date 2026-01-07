Vagrant.configure("2") do |config|
  config.vm.box_check_update = false

  # =====================
  # PROVIDER (VMware Workstation / Fusion)
  # =====================
  config.vm.provider "vmware_desktop" do |v|
    v.gui = false
    v.vmx["ethernet0.virtualDev"] = "vmxnet3"
    v.vmx["ethernet1.virtualDev"] = "vmxnet3"
  end

# =====================
  # NODE01 (CLUSTER)
  # =====================
  config.vm.define "node01" do |node|
    node.vm.box = "bento/rockylinux-9"
    node.vm.hostname = "node01"

    node.vm.network "private_network",
      ip: "192.168.183.11",
      vmware__network_name: "VMnet1",
      auto_config: true

    node.vm.provider "vmware_desktop" do |v|
      v.vmx["memsize"] = "2048"
      v.vmx["numvcpus"] = "2"
    end

    # --- CORRECTION ICI ---
    node.vm.provision "shell", inline: <<-SHELL
      # 1. Activer le dépôt High Availability (Requis pour PCS/Pacemaker sur Rocky 9)
      dnf install -y dnf-plugins-core
      dnf config-manager --set-enabled highavailability

      # 2. Installation des paquets HA
      dnf install -y chrony pcs pacemaker fence-agents-all

      # 3. Activation des services
      systemctl enable --now chronyd
      systemctl enable --now pcsd

      # 4. Mot de passe hacluster
      echo 'vagrant' | passwd --stdin hacluster
    SHELL
  end

  # =====================
  # NODE02 (CLUSTER)
  # =====================
  config.vm.define "node02" do |node|
    node.vm.box = "bento/rockylinux-9"
    node.vm.hostname = "node02"

    node.vm.network "private_network",
      ip: "192.168.183.12",
      vmware__network_name: "VMnet1",
      auto_config: true

    node.vm.provider "vmware_desktop" do |v|
      v.vmx["memsize"] = "2048"
      v.vmx["numvcpus"] = "2"
    end

    # --- CORRECTION ICI ---
    node.vm.provision "shell", inline: <<-SHELL
      # 1. Activer le dépôt High Availability (Requis pour PCS/Pacemaker sur Rocky 9)
      dnf install -y dnf-plugins-core
      dnf config-manager --set-enabled highavailability

      # 2. Installation des paquets HA
      dnf install -y chrony pcs pacemaker fence-agents-all

      # 3. Activation des services
      systemctl enable --now chronyd
      systemctl enable --now pcsd

      # 4. Mot de passe hacluster
      echo 'vagrant' | passwd --stdin hacluster
    SHELL
  end

  # =====================
  # WINDOWS SERVER (AD)
  # =====================
  config.vm.define "winsrv" do |win|
    win.vm.box = "gusztavvargadr/windows-server-2022-standard"
    win.vm.hostname = "winsrv"

    win.vm.network "private_network",
      ip: "192.168.183.166",
      vmware__network_name: "VMnet1",
      auto_config: true

    win.vm.provider "vmware_desktop" do |v|
      v.vmx["memsize"] = "4096"
      v.vmx["numvcpus"] = "2"
    end

    # Active WinRM pour Ansible
    win.vm.provision "shell", privileged: false, inline: <<-PS
      winrm quickconfig -q
      winrm set winrm/config/service '@{AllowUnencrypted="true"}'
      winrm set winrm/config/service/auth '@{Basic="true"}'
      powershell -Command "Set-Item WSMan:\\localhost\\Service\\AllowUnencrypted -Value true"
      powershell -Command "Set-Item WSMan:\\localhost\\Service\\Auth\\Basic -Value true"
      powershell -Command "Enable-PSRemoting -Force"
    PS
    # Force l'IP statique sur Ethernet1 (la carte réseau privée)
    win.vm.provision "shell", run: "always", inline: <<-PS
      $TargetIP = "192.168.183.166"
      $InterfaceAlias = "Ethernet1"
      
      # Vérifie si l'IP est déjà bonne pour gagner du temps
      $CurrentIP = (Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
      
      if ($CurrentIP -ne $TargetIP) {
          Write-Host "Correction de l'IP : Changement de $CurrentIP vers $TargetIP"
          # Supprime l'ancienne IP dynamique
          Remove-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
          # Force la nouvelle IP statique
          New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $TargetIP -PrefixLength 24 -Confirm:$false
      } else {
          Write-Host "IP Correcte : $TargetIP"
      }
    PS
    # ===========================
  end

  # =====================
  # ADMIN (ANSIBLE)
  # =====================
  config.vm.define "admin" do |admin|
    admin.vm.box = "bento/ubuntu-22.04"
    admin.vm.hostname = "admin"

    # Réseau LAB (host-only VMware)
    admin.vm.network "private_network",
      ip: "192.168.183.10",
      vmware__network_name: "VMnet1",
      auto_config: true

    admin.vm.provider "vmware_desktop" do |v|
      v.vmx["memsize"] = "2048"
      v.vmx["numvcpus"] = "2"
    end

    # Provision automatique : collections + playbook
    admin.vm.provision "shell", inline: <<-SHELL
      chmod +x /vagrant/ansible/bootstrap.sh
      /vagrant/ansible/bootstrap.sh
    SHELL
  end

end