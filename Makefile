TEMP_DIR := ./tmp
USER := $(shell whoami)
NAME := ansible-ubuntu
TEMP_INVENTORY_FILE := ${TEMP_DIR}/hosts
#CONTAINER_ADDR := $(shell	docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${NAME})
CONTAINER_ADDR = 127.0.0.1:2222


install:
	pip install ansible

setup_ssh_keys:
	ssh-keygen -b 2048 -t rsa -C "${USER}@email.com" -f "${TEMP_DIR}/id_rsa" -N ""
	chmod 600 "${TEMP_DIR}/id_rsa"
	chmod 644 "${TEMP_DIR}/id_rsa.pub"

build:
	docker build -t ${NAME} -f Dockerfile --build-arg USER tmp/

run:
	docker run -d -p ${CONTAINER_ADDR}:22 --name ${NAME} ${NAME}

define INVENTORY_FILE
[target_group]
${CONTAINER_ADDR}
[target_group:vars]
ansible_ssh_private_key_file=${TEMP_DIR}/id_rsa
endef

	#cat > "${TEMP_INVENTORY_FILE}" << EOL
#[target_group]
#${CONTAINER_ADDR}:22
#[target_group:vars]
#ansible_ssh_private_key_file=${TEMP_DIR}/id_rsa
#EOL

export INVENTORY_FILE
setup_inventory_file:
	echo "$${INVENTORY_FILE}" > "${TEMP_INVENTORY_FILE}"

setup_ansible:
	ansible-playbook -i "${TEMP_INVENTORY_FILE}" -vvv machine-setup.yaml
