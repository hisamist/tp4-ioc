# tp4-ioc — Infrastructure as Code

Terraform + Docker + Ansible + GitHub Actions

> **Objectif :** Zéro configuration manuelle — infrastructure définie en code, versionnée dans Git, déployable en une commande.

---

## Architecture cible

```
GitHub Actions (CI/CD)
    │
    ├── validate (PR)     → fmt-check + init + validate
    ├── plan (PR)         → terraform plan (artifact)
    ├── apply (main)      → terraform apply -auto-approve
    └── configure (main)  → ansible-playbook
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
               [App:3000]  [Postgres:5432] [Redis:6379]
                    └───────────┴───────────┘
                           docker network
```

---

## Structure du projet

```
tp4-ioc/
├── .github/workflows/iac.yml    # Pipeline CI/CD
├── main.tf                      # Provider + appels modules
├── variables.tf                 # Déclaration des variables
├── outputs.tf                   # Affichage des résultats
├── terraform.tfvars             # Valeurs concrètes (NON commité)
├── terraform.tfvars.example     # Template sécurisé (commité)
├── Makefile                     # Commandes raccourcies
├── ansible/
│   ├── inventory.ini            # Hosts Ansible
│   ├── playbook.yml             # Configuration des conteneurs
│   └── templates/
│       └── default.conf         # Config Nginx personnalisée
└── modules/
    └── docker-service/
        ├── main.tf              # Ressources Docker génériques
        ├── variables.tf         # Interface du module
        └── output.tf            # Sorties du module
```

---

## Commandes rapides (Makefile)

```bash
# Terraform
make init          # terraform init
make fmt           # formater les .tf
make fmt-check     # vérifier le formatage (CI)
make validate      # valider la configuration
make plan          # prévisualiser les changements
make apply         # créer l'infrastructure
make destroy       # supprimer l'infrastructure
make output        # afficher les outputs

# Ansible
make ansible       # exécuter le playbook
make ansible-check # dry-run (sans changements)
make ansible-syntax # vérifier la syntaxe

# Docker
make docker-ps     # lister les conteneurs actifs
make docker-logs   # afficher les logs
make docker-clean  # nettoyer conteneurs/images arrêtés

# Combinés
make deploy        # apply + ansible (full deploy)
make health        # outputs + rapport de santé
make check         # fmt-check + validate + syntax (CI/pre-commit)

# Nettoyage
make clean         # supprimer fichiers Terraform locaux
make reinit        # clean + init
make help          # lister toutes les commandes
```

---

## Prérequis

| Outil | Version | Installation |
|-------|---------|-------------|
| Terraform | >= 1.0 | [HashiCorp apt repo](https://developer.hashicorp.com/terraform/downloads) |
| Docker Desktop | latest | [docker.com](https://www.docker.com/products/docker-desktop/) |
| Ansible | latest | `pip install ansible` (WSL) |
| community.docker | latest | `ansible-galaxy collection install community.docker` |

### Installation Terraform (WSL)
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```

---

## Démarrage rapide

```bash
# 1. Copier les variables
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars avec vos valeurs

# 2. Initialiser et déployer
make init
make deploy   # terraform apply + ansible playbook

# 3. Vérifier
make docker-ps
curl http://localhost:3000
```

---

## Points clés Terraform

### Module réutilisable `docker-service`

Un seul module appelé 3 fois — pas de duplication :

```hcl
module "postgres" { source = "./modules/docker-service" ... }
module "redis"    { source = "./modules/docker-service" ... }
module "app"      { source = "./modules/docker-service" ... }
```

Ajouter un conteneur = 1 bloc `module` à ajouter.

### Bloc `dynamic` pour les volumes

```hcl
dynamic "volumes" {
  for_each = var.volumes  # liste vide = aucun volume
  content { ... }
}
```

Redis/Nginx n'ont pas de volume, PostgreSQL en a un — même module, comportement adaptatif.

### Protection des secrets

```hcl
variable "postgres_password" {
  sensitive = true  # masqué dans les outputs terraform apply
}
```

---

## Sécurité — Checklist

- `terraform.tfvars` dans `.gitignore` (jamais commité)
- `*.tfstate` dans `.gitignore` (contient l'état réel)
- `terraform.tfvars.example` commité sans secrets réels
- Secrets GitHub Actions via `Settings > Secrets > POSTGRES_PASSWORD`
- Passer les secrets via `TF_VAR_postgres_password` dans le workflow
- `terraform fmt -check` passe sans erreur

---

## CI/CD — GitHub Actions (`.github/workflows/iac.yml`)

| Job | Déclencheur | Actions |
|-----|------------|---------|
| `validate` | PR + push | fmt-check + init + validate |
| `plan` | PR | plan + upload artifact |
| `apply` | push main | apply -auto-approve |
| `configure` | après apply | ansible-playbook |

### Secret à configurer dans GitHub

```
Settings > Secrets and variables > Actions > New repository secret
Nom : POSTGRES_PASSWORD
```

Utilisé dans le workflow via :
```yaml
env:
  TF_VAR_postgres_password: ${{ secrets.POSTGRES_PASSWORD }}
```

---

## Ansible

Le playbook vérifie et configure les conteneurs après `terraform apply` :

1. Vérifie que les 3 conteneurs sont en état `running`
2. Teste PostgreSQL avec `pg_isready`
3. Teste Redis avec `redis-cli ping`
4. Copie la configuration Nginx personnalisée
5. Recharge Nginx via un handler
6. Affiche un rapport de santé

```bash
make ansible         # exécution normale
make ansible-check   # dry-run sans modification
```

---

## Barème (TP noté /20)

| Critère | Points |
|---------|--------|
| Terraform init + provider | 3 |
| Ressources Docker (3 conteneurs + réseau + volume) | 4 |
| Playbook Ansible | 3 |
| Module `docker-service` réutilisable | 3 |
| Pipeline CI/CD GitHub Actions | 4 |
| Bonnes pratiques (gitignore, tfvars.example, fmt) | 2 |
| Commits conventionnels | 1 |
| **Total** | **20** |
