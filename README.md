# PB-Compass-Projeto-AWS-Docker
Este projeto foi desenvolvido como parte do programa de bolsas de DevSecOps da Compass Uol. O objetivo é implementar uma solução de infraestrutura utilizando **AWS** e **Docker**, com foco no deploy de uma aplicação **WordPress** em contêiner. A solução envolve a configuração de uma instância **EC2**, a instalação do **Docker**, e o uso de **Amazon RDS** e **EFS** para suportar a aplicação.

## Tecnologias Utilizadas

Este projeto utiliza diversas tecnologias:
- **Amazon VPC**: Para criar redes e sub-redes isoladas na AWS.
- **AWS EC2**: para provisionar e gerenciar instâncias virtuais.
- **Amazon Linux 2023**: sistema operacional utilizado na instância EC2.
- **Docker**: para empacotar e executar a aplicação WordPress.
- **Docker Compose**: para facilitar a configuração e orquestração dos contêineres.
- **Amazon RDS (MySQL)**: para gerenciar o banco de dados da aplicação.
- **Amazon EFS**: para armazenamento compartilhado entre contêineres.

---

## Etapa 1: Configuração Inicial do Ambiente na AWS

### 1. Criação de uma VPC
- Acesse o Console AWS e vá para a seção **VPC**. 
- Clique em **Create VPC** e selecione a opção **VPC and more**. 
- Crie uma VPC com **2 sub-redes públicas** e **2 sub-redes privadas**.
- Verifique se o **Internet Gateway** está associado à VPC. Caso não esteja:
  - Selecione o **Internet Gateway**.
  - Clique em **Actions** > **Attach to VPC** e associe à VPC criada.

### 2. Configuração do Security Group
- Navegue até o Console EC2, vá para **Security Groups** e selecione o grupo associado à VPC criada.
- Configure as regras de entrada nas seguintes portas:
  - **HTTP** (porta 80)
  - **SSH** (porta 22)
  - **NFS** (porta 2049)
- Nas regras de saída, permita **All Traffic** com o destino `0.0.0.0/0`.

### 3. Criação de uma Instância EC2
- No Console EC2, clique em **Launch instance**.
- Adicione as tags necessárias e utilize a **Amazon Linux 2023 AMI** como imagem base para a instância.
- Crie e vincule uma chave SSH **.pem** para acesso à instância.
- Associe a instância à VPC criada anteriormente, colocando-a em uma sub-rede pública.
- Associe a instância ao **Security Group** configurado no passo anterior.
- Finalize a criação clicando em **Launch instance**.

### 4. Criação do Banco de Dados no RDS 
- Acesse a seção **Aurora and RDS** > **Databases** e clique em **Create database**.
- Selecione **MySQL** e configure o banco de dados. 
- Associe o banco de dados à instância EC2 criada no passo anterior, na seção **Connectivity**.
- Finalize a criação clicando em **Create database**.
- Após a criação, estabeleça uma conexão do banco de dados com a instância da seguinte maneira:
  - Na seção **Connectivity & security**, role até **Connected compute resources**. 
  - Clique em **Actions** > **Set up EC2 connection**, escolha a instância criada e finalize clicando em **Continue**. 

### 5. Criação do Sistema de Arquivos EFS
- Navegue até a seção **EFS** e clique em **Create file system**.
- Selecione a **VPC** associada à instância EC2 e ao RDS.
- Finalize clicando em **Create file system**.

---

## Etapa 2: Instalação do WordPress usando Docker Compose 

### 1. Acesso à Instância EC2 via SSH
- Para acessar a instância via SSH, utilize o **Visual Studio Code**: 
  - Selecione a instância na AWS e clique em **Connect**. 
  - Copie o comando exibido no campo **SSH Client** e cole no terminal do VS Code. 
  - Substitua `"nome_da_chave"` pelo caminho correto da chave, que deverá estar em `C:\Users\seu_usuario\.ssh`.

### 2. Instalação do Docker
- Atualize os pacotes da instância:

  ```bash
    sudo yum update -y
  ```

- Instale o Docker:

  ```bash
  sudo yum install -y docker
  ```

- Inicie o Docker:

  ```bash
  sudo service docker start
  ```

- Adicione o `ec2-user` ao grupo do Docker, para que os comandos sejam executados sem o uso do `sudo`:

  ```bash
  sudo usermod -a -G docker ec2-user
  ```

- Obtenha as novas permissões efetuando logout e login novamente. Verifique a instalação:

  ```bash
  docker ps
  ```

### 3. Instalação do Docker Compose
- Instale o Docker Compose:

  ```bash
  sudo curl -SL https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  ```

- Verifique a instalação:

  ```bash
  docker-compose --version
  ```

### 4. Configurando o Ponto de Montagem
- Instale o cliente Amazon EFS:

  ```bash
  sudo yum install -y amazon-efs-utils
  ```

- Crie o ponto de montagem:

  ```bash
  sudo mkdir efs
  ```

- Monte o EFS na instância:

  ```bash
  sudo mount -t efs <efs file-system-id>:/ /home/ec2-user/efs/
  ```

- Use o ID do sistema de arquivos que você está montando no local `<efs file-system-id>`.

### 5. Instalação do WordPress
- Baixe a imagem oficial do WordPress:

  ```bash
  docker pull wordpress
  ```

- Crie um diretório para o projeto:

  ```bash
  mkdir projeto-docker
  cd projeto-docker
  ```

- Crie o arquivo `docker-compose.yml` usando o script que está neste repositório e configure as variáveis de ambiente conforme necessário:

  ```bash
  nano docker-compose.yml
  ```

- Execute o WordPress com Docker Compose:

  ```bash
  docker-compose up -d
  ```

### 6. Utilizando o User Data 
Uma alternativa para simplificar o processo de configuração da instância EC2 é usar o **User Data** durante a criação da instância. Isso permite que a instância seja inicializada automaticamente com todas as dependências já instaladas e configuradas. Para implementar essa abordagem, siga os passos abaixo:

- Crie uma nova instância seguindo os passos de criação da instância anterior, mas dessa vez selecione uma **sub-rede** de **outra Zona de Disponibilidade**.
- Durante o processo de criação, acesse a seção **Advanced Details** e role até a parte inferior até encontrar **User Data**.
- Cole o script presente neste repositório no campo **User Data**. Certifique-se de incluir o **ID do sistema de arquivos EFS** e as 
**variáveis de ambiente** necessárias para a conexão com o banco de dados.
- Finalize a criação da instância clicando em **Launch instance**.

A instância será iniciada automaticamente com as configurações necessárias. Para garantir a comunicação com o banco de dados RDS, o processo de conexão será realizado da mesma forma que foi feito anteriormente.

---

## Etapa 3: Configuração Final

### 1. Criação do Load Balancer
- Acesse novamente o Console da AWS e vá para a seção **EC2**.
- No menu esquerdo, clique em **Load Balancers** e depois em **Create load balancer**.
- Escolha **Classic Load Balancer** e configure as opções:
  - **Scheme**: Internet-facing.
  - Escolha a **VPC** onde as suas instâncias EC2 estão localizadas.
  - Selecione as Availability Zones e as sub-redes públicas usadas para as instâncias EC2.
  - **Security groups**: selecione o mesmo grupo de segurança das instâncias.
  - **Listeners and routing**: HTTP na porta 80.
  - **Health Checks**: defina Ping protocol para HTTP, Ping port para 80 e Ping path como `/wp-admin/install.php`.
  - **Advanced health check settings**: defina Response timeout para 5 segundos, Interval para 30 segundos e Healthy threshold para 3 (mantenha Unhealthy threshold como 2).

- Associe o Load Balancer às instâncias EC2.  
- Clique em **Create load balancer** para finalizar.
- Após a criação, na seção **Details**, copie o **DNS name** do Load Balancer para acessar a aplicação WordPress pelo navegador.

### 2. Criação do Auto Scaling  



