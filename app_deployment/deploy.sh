#!/bin/bash

# Убедиться, что скрипт запускается с правами суперпользователя
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт должен быть запущен с правами суперпользователя." 
   exit 1
fi

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
sudo yum install -y python3 ansible terraform docker

# Настройка Python-окружения
echo "Установка Jinja2 для Python..."
pip3 install jinja2

# Шаг 1: Рендеринг конфигурационного файла с использованием Jinja2
echo "Рендеринг конфигурационного файла..."
python3 jinja/render_config.py
if [[ $? -ne 0 ]]; then
    echo "Ошибка рендеринга конфигурации."
    exit 1
fi

# Шаг 2: Развёртывание Docker-контейнера через Ansible
echo "Запуск Ansible для развёртывания Docker-контейнера..."
ansible-playbook -i ansible/inventory.ini ansible/deploy.yml
if [[ $? -ne 0 ]]; then
    echo "Ошибка запуска Ansible."
    exit 1
fi

# Шаг 3: Развёртывание EC2-инстансов с помощью Terraform
echo "Развёртывание инфраструктуры с помощью Terraform..."
cd terraform || exit
terraform init
terraform apply -auto-approve
if [[ $? -ne 0 ]]; then
    echo "Ошибка развертывания Terraform."
    exit 1
fi

# Получение публичного IP EC2-инстанса
instance_ip=$(terraform output -raw instance_public_ip)
echo "Развёртывание завершено. Публичный IP EC2-инстанса: $instance_ip"
cd ..

# Завершение
echo "Скрипт выполнен успешно!"
