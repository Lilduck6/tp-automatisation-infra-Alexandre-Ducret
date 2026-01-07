#!/bin/bash

# On arrête le script si une commande échoue (pour ne pas masquer les erreurs)
# set -e 

echo "--- DÉBUT DU BOOTSTRAP AUTOMATISÉ ---"

# 1. Gestion du verrou APT (Le problème que tu as eu)
# On attend que le système ait fini ses mises à jour automatiques de démarrage
export DEBIAN_FRONTEND=noninteractive
echo "--- Vérification des verrous APT ---"
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    echo "En attente de la libération du verrou apt..."
    sleep 5
done
while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
    echo "En attente de la libération du verrou apt lists..."
    sleep 5
done

# 2. Réparation préventive (C'est la commande magique pour ton erreur)
echo "--- Nettoyage et Réparation des paquets ---"
dpkg --configure -a
apt-get install -f -y

# 3. Installation des pré-requis
echo "--- Installation des outils de base ---"
apt-get update -q
apt-get install -y software-properties-common sshpass curl git

# 4. Installation d'Ansible (Version Officielle)
echo "--- Ajout du dépôt Ansible ---"
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible python3-passlib

# 5. Configuration SSH
echo "--- Configuration SSH ---"
if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
    sudo -u vagrant ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -q -N ""
fi

# 6. Configuration Ansible
echo "--- Création du fichier de config Ansible ---"
mkdir -p /etc/ansible
cat <<EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
inventory = /vagrant/ansible/hosts.ini
interpreter_python = auto_silent
EOF

# 7. Installation des Collections (La partie critique pour Windows)
echo "--- Installation des collections Galaxy ---"
# On tente l'installation, si ça échoue on attend et on réessaie (résilience réseau)
n=0
until [ "$n" -ge 3 ]
do
   sudo -u vagrant ansible-galaxy collection install microsoft.ad community.windows ansible.windows community.general && break
   n=$((n+1)) 
   echo "Échec installation collection, nouvelle tentative dans 10s..."
   sleep 10
done
#!/bin/bash

# ... (votre code existant d'installation d'Ansible) ...

echo ">>> Démarrage de la configuration du Cluster HA..."
# On s'assure d'avoir les clés SSH acceptées pour éviter le prompt 'yes/no'
export ANSIBLE_HOST_KEY_CHECKING=False

# Lancement du playbook de configuration HA
ansible-playbook -i /vagrant/ansible/hosts.ini /vagrant/ansible/install_ha.yml

echo ">>> Démarrage de la configuration du Cluster HA..."
export ANSIBLE_HOST_KEY_CHECKING=False

# 1. Installation du Cluster
ansible-playbook -i /vagrant/ansible/hosts.ini /vagrant/ansible/install_ha.yml

# 2. Déploiement du Site Web et de la Ressource Apache (AJOUT À FAIRE)
echo ">>> Déploiement du Service Web..."
ansible-playbook -i /vagrant/ansible/hosts.ini /vagrant/ansible/deploy_web.yml

# ... (après install_ha.yml et deploy_web.yml) ...

# 3. Déploiement du serveur de fichiers Samba (AJOUT)
echo ">>> Installation de Samba..."
ansible-playbook -i /vagrant/ansible/hosts.ini /vagrant/ansible/deploy_samba.yml

# 4. Installation de l'Active Directory (déjà fait précédemment)
# ...

# ... (Après deploy_samba.yml) ...

# 4. Sécurisation des serveurs Linux (Mission 2)
echo ">>> Application du Hardening (Sécurité)..."
ansible-playbook -i /vagrant/ansible/hosts.ini /vagrant/ansible/security_linux.yml


# 5. Installation de l'Active Directory sur Windows
echo ">>> Installation et Configuration de Active Directory..."
ansible-playbook -i /vagrant/ansible/hosts.ini /vagrant/ansible/install_ad.yml

# 6. Sécurisation Windows (Mission 3)
echo ">>> Application du Hardening Windows..."
ansible-playbook -i /vagrant/ansible/hosts.ini /vagrant/ansible/security_windows.yml

# 7. Supervision Zabbix (Mission 4)
echo ">>> Installation des Agents Zabbix..."
ansible-playbook -i /vagrant/ansible/hosts.ini /vagrant/ansible/install_zabbix_agent.yml

echo ">>> Installation du Serveur Zabbix (Cerveau)..."
ansible-playbook -i /vagrant/ansible/hosts.ini /vagrant/ansible/install_zabbix_server.yml

echo "--- BOOTSTRAP TERMINÉ AVEC SUCCÈS ---"
