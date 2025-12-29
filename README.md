# 🖥️ Infrastructure Automatisée – Vagrant & Ansible

## 📌 Présentation du projet
Ce projet a pour objectif de déployer automatiquement une infrastructure complète
à l’aide de **Vagrant** et **Ansible**, dans une approche *Infrastructure as Code*.

L’infrastructure comprend :
- Un **cluster haute disponibilité** Linux (Pacemaker / Corosync)
- Un **serveur Windows** sécurisé
- Des services **Web (Nginx)** et **Samba**
- Une **supervision Zabbix**
- Une **IP virtuelle (VIP)** assurant la continuité de service

Le déploiement est entièrement automatisé via la commande :

```bash
vagrant up

🗺️ Schéma d’architecture

📎 Schéma réalisé avec Draw.io

VM Admin (Ansible / Zabbix)

Node01 / Node02 (Cluster HA)

Windows Server (Sécurité / AD)

IP virtuelle (VIP) pour le service Web

🧱 Architecture détaillée

| Machine | Rôle             | IP              |
| ------- | ---------------- | --------------- |
| admin   | Ansible / Zabbix | 192.168.183.167 |
| node01  | Cluster HA       | DHCP            |
| node02  | Cluster HA       | DHCP            |
| winsrv  | Windows sécurisé | 192.168.183.166 |
| VIP     | Service Web HA   | 192.168.183.100 |

⚙️ Prérequis

Vagrant

VMware Workstation / VirtualBox

Git

Connexion Internet

🚀 Installation & Déploiement
1️⃣ Cloner le dépôt

cd tp-automatisation

2️⃣ Lancer l’infrastructure
vagrant up


Aucune action manuelle n’est requise.
Ansible est automatiquement exécuté depuis la VM admin.

🧠 Choix d’architecture
Pourquoi Vagrant ?

Déploiement reproductible

Environnement isolé

Idéal pour les tests d’infrastructure

Pourquoi Ansible ?

Agentless

Lisible et maintenable

Automatisation complète des configurations système

Stratégie de haute disponibilité

Pacemaker & Corosync gèrent l’état du cluster

Une IP virtuelle (VIP) est déplacée automatiquement

En cas de panne d’un nœud, le service reste accessible

🔐 Sécurité

Pare-feu activé sur Windows

Politique de mots de passe renforcée

Durcissement Linux

Accès distant contrôlé (SSH / WinRM)

📊 Supervision Zabbix

Agent Zabbix installé sur les nœuds Linux

Supervision centralisée

Suivi de la disponibilité des services


✅ Preuves de fonctionnement
Cluster HA

Cluster en état ONLINE

VIP active sur un nœud







Supervision

Agents Zabbix actifs

Hôtes visibles dans l’interface Zabbix

📸 Screenshot du dashboard

🏁 Conclusion

Ce projet démontre la mise en place réussie d’une infrastructure automatisée,
sécurisée et hautement disponible, répondant aux principes de l’Infrastructure as Code.

L’ensemble du déploiement est reproductible, maintenable et validé par des preuves
de fonctionnement.