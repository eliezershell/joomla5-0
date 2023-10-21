#!/bin/bash

sudo apt update
if [ $? -gt 0 ]; then
        echo "Erro ao atualizar pacotes do repositório APT!"; exit 0
fi

sudo apt install apache2 -y
if [ $? -gt 0 ]; then
        echo "Erro ao instalar Apache2!"; exit 0
fi

sudo apt install mysql-server -y
if [ $? -gt 0 ]; then
        echo "Erro ao instalar MySQL!"; exit 0
fi

sudo apt install php8.1 -y
if [ $? -gt 0 ]; then
        echo "Erro ao instalar PHP8.1!"; exit 0
fi

echo "------------------------------Verificando Apache2------------------------------"
systemctl status apache2
echo "-------------------------------------------------------------------------------"

echo "------------------------------Verificando MySQL------------------------------"
service mysql status
echo "-------------------------------------------------------------------------------"

echo "------------------------------Verificando PHP8.1------------------------------"
php -v
echo "-------------------------------------------------------------------------------"

echo "------------------------------Criando Database------------------------------"
read -p "Nome de usuário MySQL: " usuario
read -p "Senha de usuário MySQL: " senha
read -p "Nome do banco de dados MySQL: " banco
sudo mysql -u root <<MYSQL_SCRIPT
CREATE USER '$usuario'@'localhost' IDENTIFIED BY '$senha';
CREATE DATABASE $banco;
GRANT ALL PRIVILEGES ON $banco.* TO '$usuario'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
if [ $? -gt 0 ]; then
        echo "Erro ao criar Database!"; exit 0
fi

sudo apt install unzip -y
if [ $? -gt 0 ]; then
        echo "Erro ao instalar Unzip!"; exit 0
fi

sudo rm -f /var/www/html/index.html
if [ $? -gt 0 ]; then
        echo "Erro ao remover o arquivo index.html do Apache2!"; exit 0
fi

wget https://downloads.joomla.org/cms/joomla5/5-0-0/Joomla_5-0-0-Stable-Full_Package.zip
if [ $? -gt 0 ]; then
        echo "Erro ao baixar arquivos do Joomla!"; exit 0
fi

sudo mv Joomla_5-0-0-Stable-Full_Package.zip /var/www/html
if [ $? -gt 0 ]; then
        echo "Erro ao mover o arquivo Zip do Joomla para o diretório do Apache2!"; exit 0
fi

sudo unzip /var/www/html/Joomla_5-0-0-Stable-Full_Package.zip -d /var/www/html
if [ $? -gt 0 ]; then
        echo "Erro ao extrair o arquivo Zip do Joomla!"; exit 0
fi

sudo rm -f /var/www/html/Joomla_5-0-0-Stable-Full_Package.zip
if [ $? -gt 0 ]; then
        echo "Erro ao Remover o arquivo Zip do Joomla!"; exit 0
fi

sudo mv /var/www/html/libraries/vendor/composer/autoload_psr4.php /var/www/html/administrator/cache
if [ $? -gt 0 ]; then
        echo "Erro ao mover arquivo autoload_psr4.php para o diretório correto!"; exit 0
fi

sudo chmod +w /var/www/html
if [ $? -gt 0 ]; then
        echo "Erro ao dar permissões 777 em /var/www/html!"; exit 0
fi

sudo sed -i "s/output_buffering = 4096/output_buffering = Off/g" /etc/php/8.1/apache2/php.ini
if [ $? -gt 0 ]; then
        echo "Erro ao alterar ouput_buffering em php.ini!"; exit 0
fi

sudo systemctl restart apache2

echo "------------------------------Instalação concluída com sucesso!------------------------------"
echo "----------------------Script by: Eliezer Ribeiro | linkedin.com/in/elinux--------------------"
exit 0
