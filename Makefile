.PHONY: help \
        init fmt fmt-check validate plan apply destroy output \
        ansible ansible-check ansible-syntax \
        deploy health \
        check

TERRAFORM  := terraform
TFVARS     := terraform.tfvars
INVENTORY  := ansible/inventory.ini
PLAYBOOK   := ansible/playbook.yml

# ── Help ──────────────────────────────────────────────────────────────────────
help: ## Afficher les commandes disponibles
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ── Terraform ─────────────────────────────────────────────────────────────────
init: ## terraform init
	$(TERRAFORM) init

fmt: ## Formater les fichiers .tf
	$(TERRAFORM) fmt -recursive

fmt-check: ## Verifier le formatage (sans modifier)
	$(TERRAFORM) fmt -recursive -check

validate: ## Valider la configuration Terraform
	$(TERRAFORM) validate

plan: ## Afficher les changements prevus
	$(TERRAFORM) plan -var-file=$(TFVARS)

apply: ## Appliquer l'infrastructure
	$(TERRAFORM) apply -var-file=$(TFVARS) -auto-approve

destroy: ## Detruire l'infrastructure
	$(TERRAFORM) destroy -var-file=$(TFVARS) -auto-approve

output: ## Afficher les outputs Terraform
	$(TERRAFORM) output

# ── Ansible ───────────────────────────────────────────────────────────────────
ansible: ## Executer le playbook Ansible
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK)

ansible-check: ## Dry-run du playbook (sans changements)
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --check

ansible-syntax: ## Verifier la syntaxe du playbook
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --syntax-check

# ── Combinés ─────────────────────────────────────────────────────────────────
deploy: apply ansible ## Terraform apply + Ansible (full deploy)

health: output ansible ## Outputs + rapport de sante Ansible

check: fmt-check validate ansible-syntax ## Verifications completes (CI/pre-commit)

# ── Docker ────────────────────────────────────────────────────────────────────
docker-ps: ## Lister les conteneurs actifs
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

docker-logs: ## Afficher les logs de tous les conteneurs
	docker logs $(filter mon-app,$(shell docker ps --format "{{.Names}}"))

docker-clean: ## Supprimer conteneurs/images arretes
	docker system prune -f

# ── Nettoyage Terraform ───────────────────────────────────────────────────────
clean: ## Supprimer les fichiers Terraform locaux
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

reinit: clean init ## Reinitialiser completement Terraform
