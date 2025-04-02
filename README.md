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

## Etapas do Projeto

### 1. Criação de uma VPC
- Acesse o Console AWS e vá para a seção **VPC**. 
- Clique em **Create VPC** e selecione a opção **VPC and more**. 
- Crie uma VPC com **2 sub-redes públicas** e **2 sub-redes privadas**.
- Verifique se o **Internet Gateway** está associado à VPC. Caso não esteja:
  - Selecione o **Internet Gateway**.
  - Clique em **Actions** > **Attach to VPC** e associe à VPC criada.

- Configure as sub-redes para permitir criação de instâncias com Ip público automaticamente:
  - Clique em **Subnets**, selecione uma das sub-redes públicas.
  - Vá em **Actions** > **Edit subnet settings**.
  - Marque a caixa **Enable auto-assign public IPv4 address** e depois clique em **Save**.

### 2. Configuração do Security Group
- No menu lateral esquerdo, vá para **Security Groups** e selecione o grupo associado à VPC criada.
- Configure as regras de entrada nas seguintes portas:
  - **HTTP**: porta 80, restringindo o acesso apenas ao seu IP.
  - **SSH**: porta 22, também restringindo o acesso apenas ao seu IP.
  - **Custom TCP**: porta 2049 (NFS), restringindo o acesso apenas ao **IPv4 CIDR** da sua VPC.
- Nas regras de saída, permita **All Traffic** com o destino `0.0.0.0/0`.

### 3. Criação do Banco de Dados no RDS 
- Acesse a seção **Aurora and RDS** > **Databases** e clique em **Create database**.
- Selecione **MySQL** e configure o banco de dados. 
- Associe o banco de dados à instância EC2 criada no passo anterior, na seção **Connectivity**.
- Finalize a criação clicando em **Create database**.

### 4. Criação do Sistema de Arquivos EFS
- Navegue até a seção **EFS** e clique em **Create file system**.
- Selecione a **VPC** criada anteriormente.
- Finalize clicando em **Create file system**.

### 5. Criação de uma Instância EC2
- No Console EC2, clique em **Launch instance**.
- Adicione as tags necessárias e utilize a **Amazon Linux 2023 AMI** como imagem base para a instância.
- Crie e vincule uma chave SSH **.pem** para eventual acesso à instância.
- Associe a instância à VPC criada anteriormente, colocando-a em uma sub-rede pública.
- Associe a instância ao **Security Group** configurado anteriormente.
- Use o script do **User Data** presente neste repositório, atentando-se em fazer as seguintes alterações:
  - Substitua `<efs file-system-id>` pelo ID do sistema de arquivos criado no passo anterior.
  - Substitua `<RDS-ENDPOINT>` pelo endpoint do banco de dados.
  - Substitua `<db_name>` pelo nome da base de dados do banco.
  - Substitua `<db_user>` pelo nome de usuário mestre do banco de dados.
  - Substitua `<db_password>` pelo senha configurada para o banco de dados.

- Finalize a criação clicando em **Launch instance**.
- Repita o processo para criar uma segunda instância, se atentando em colocá-la em uma seub-rede pública de outra Zona de Disponibilidade.

### 6. Conectando as Instâncias ao Banco de Dados 
- Acesse novamente a seção **Aurora and RDS** > **Databases** e clique no banco de dados criado.
- Na seção **Connectivity & security**, role até **Connected compute resources**. 
- Clique em **Actions** > **Set up EC2 connection**, escolha a instância criada e finalize clicando em **Continue**. 
- Repita esse processo para conectar a outra instância.

### 7. Etapa Alternativa: Instalação Manual do WordPress 
Caso decida fazer a instalção manualmente em vez de usando o **User Data** siga os seguintes passos:

1. Acesso à Instância EC2 via SSH
- Para acessar a instância via SSH, utilize o **Visual Studio Code**: 
  - Selecione a instância na AWS e clique em **Connect**. 
  - Copie o comando exibido no campo **SSH Client** e cole no terminal do VS Code. 
  - Substitua `"nome_da_chave"` pelo caminho correto da chave, que deverá estar em `C:\Users\seu_usuario\.ssh`.

2. Instalação do Docker
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

3. Instalação do Docker Compose
- Instale o Docker Compose:

  ```bash
  sudo curl -SL https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  ```

- Verifique a instalação:

  ```bash
  docker-compose --version
  ```

4. Configuração do Ponto de Montagem
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

5. Instalação do WordPress
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


### 8. Criação do Load Balancer
- Acesse novamente o Console da AWS e vá para a seção **EC2**.
- No menu esquerdo, clique em **Load Balancers** e depois em **Create load balancer**.
- Escolha **Classic Load Balancer** e configure as opções:
  - **Scheme**: Internet-facing.
  - Escolha a **VPC** onde as suas instâncias EC2 estão localizadas.
  - Selecione as Availability Zones e as sub-redes públicas usadas para as instâncias EC2.
  - **Security groups**: crie um novo grupo de segurança:
    - Nas regras de entrada, configure HTTP na porta 80, permitindo tráfego de origem `0.0.0.0/0`.
    - Nas regras de saída, permita **All Traffic** com o destino `0.0.0.0/0`.
  - **Listeners and routing**: HTTP na porta 80.
  - **Health Checks**: defina Ping protocol para HTTP, Ping port para 80 e Ping path como `/wp-admin/install.php`.
  - **Advanced health check settings**: defina Response timeout para 5 segundos, Interval para 30 segundos e Healthy threshold para 3 (mantenha Unhealthy threshold como 2).

- Associe o Load Balancer às instâncias EC2.  
- Clique em **Create load balancer** para finalizar.
- Após a criação, vá até **Security Groups** e edite as regras de entrada do primeiro grupo de segurança criado para HTTP na porta 80, permitindo acesso do Security Group criado para o Load Balancer.
- Volte até o Load Balancer, na seção **Details**, copie o **DNS name** para acessar a aplicação WordPress pelo navegador.

### 9. Criação do Auto Scaling Group



