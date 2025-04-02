# PB-Compass-Projeto-AWS-Docker
Este projeto foi desenvolvido como parte do programa de bolsas de DevSecOps da Compass Uol. O objetivo é implementar uma solução de infraestrutura utilizando **AWS** e **Docker**, com foco no deploy de uma aplicação **WordPress** em contêiner. A solução envolve a configuração de uma instância **EC2**, a instalação do **Docker**, e o uso de **Amazon RDS** e **EFS** para suportar a aplicação.

## Tecnologias Utilizadas

Este projeto utiliza diversas tecnologias:
- **Amazon VPC**: para criar redes e sub-redes na AWS.
- **AWS EC2**: para provisionar e gerenciar instâncias virtuais.
- **Amazon Linux 2023**: sistema operacional utilizado na instância EC2.
- **Docker**: para empacotar e executar a aplicação WordPress.
- **Docker Compose**: para facilitar a configuração dos contêineres.
- **Amazon RDS (MySQL)**: para gerenciar o banco de dados da aplicação.
- **Amazon EFS**: para armazenamento compartilhado entre contêineres.

---

## Etapas do Projeto

### 1. Criação de uma VPC
- Acesse o Console AWS e vá para a seção **VPC**. 
- Clique em **Create VPC** e selecione a opção **VPC and more**. 
- Crie uma VPC com **2 sub-redes públicas** e **2 sub-redes privadas**.
- Certifique-se de que o **Internet Gateway** está associado à VPC. Caso não esteja, selecione o gateway, clique em **Actions** > **Attach to VPC** e associe-o à VPC criada.
- Para permitir a criação de instâncias com IP público automaticamente, configure as sub-redes::
  - Vá para **Subnets**, selecione uma sub-rede pública e clique em **Actions** > **Edit subnet settings**.
  - Marque a opção **Enable auto-assign public IPv4 address** e depois clique em **Save**.
  - Repita o processo para a outra sub-rede pública.

### 2. Configuração e Criação dos Security Groups
- Para este projeto serão usados dois grupos de segurança, um padrão criado junto com a VPC e outro que será usado apenas com o Load Balancer.

1. **Security Group Padrão**
- No menu lateral, vá para **Security Groups** e selecione o grupo associado à VPC criada.
- Configure as regras de entrada nas seguintes portas:
  - **HTTP (porta 80)**: acesso restrito ao seu IP.
  - **SSH (porta 22)**: acesso restrito ao seu IP.
  - **Custom TCP (porta 2049 - NFS)**: acesso restrito ao IPv4 CIDR da sua VPC.

- Nas regras de saída, permita **All Traffic** com o destino `0.0.0.0/0`.

2. **Security Group do Load Balancer**
- Crie um novo **Security Group** para o Load Balancer clicando em **Create security group**:
  - Personalize o nome e a descrição.
  - **Regras de entrada**: configure uma regra HTTP na porta 80, permitindo tráfego de origem `0.0.0.0/0`.
  - **Regras de saída**: permita **All Traffic** com o destino `0.0.0.0/0`.
  - Edite as regras de entrada do grupo de segurança padrão, permitindo tráfego **HTTP** na porta 80, mas apenas a partir do grupo de segurança criado para o Load Balancer.

### 3. Criação do Banco de Dados no RDS 
- Vá para **Aurora and RDS** > **Databases** e clique em **Create database**.
- Selecione **MySQL** e configure o banco de dados com as seguintes opções:
  - **Engine Version**: última versão disponível.
  - **Templates**: selecione **Free tier**.
  - Personalize o nome do banco de dados e o nome de usuário, definindo uma senha. 
  - Escolha a instância **db.t3.micro**. 
  - **Connectivity**: selecione **Don’t connect to an EC2 compute resource** e associe à VPC criada.
  - **Additional configuration**: defina um nome para a base de dados.

- Finalize clicando em **Create database**.

### 4. Criação do Sistema de Arquivos EFS
- Acesse a seção **EFS** e clique em **Create file system**.
- Selecione a **VPC** criada e finalize a criação clicando em **Create file system**.

### 5. Criação de uma Instância EC2
- No Console EC2, clique em **Launch instance**.
- Adicione as tags necessárias e utilize a **Amazon Linux 2023 AMI**.
- Crie e vincule uma chave SSH **.pem** para acesso à instância.
- Associe a instância à VPC criada, colocando-a em uma sub-rede pública.
- Associe a instância ao **Security Group** configurado.
- Use o script de **User Data** disponível neste repositório, fazendo as seguintes alterações:
  - Substitua `<efs file-system-id>` pelo ID do sistema de arquivos EFS.
  - Substitua `<RDS-ENDPOINT>` pelo endpoint do banco de dados.
  - Substitua `<db_name>`, `<db_user>` e `<db_password>` pelas credenciais do banco de dados.

- Finalize clicando em **Launch instance**.
- Repita o processo para criar uma segunda instância em uma sub-rede pública em outra Zona de Disponibilidade.

### 6. Conectando as Instâncias ao Banco de Dados 
- Vá para **Aurora and RDS** > **Databases** e selecione o banco de dados criado.
- Na seção **Connectivity & security**, role até **Connected compute resources**. 
- Clique em **Actions** > **Set up EC2 connection**, escolha a instância criada e finalize clicando em **Continue**. 
- Repita esse processo para conectar a outra instância EC2.

### 7. Etapa Alternativa: Instalação Manual do WordPress 
Caso prefira instalar o WordPress manualmente, siga os passos abaixo:

1. **Acesso à Instância EC2 via SSH**
- Acesse a instância via SSH utilizando o **Visual Studio Code**: 
  - Selecione a instância e clique em **Connect**. 
  - Copie o comando SSH exbido e cole-o no terminal do VS Code. Substitua `"nome_da_chave"` pelo caminho correto da chave SSH.

2. **Instalação do Docker**
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

- Efetue logout e login novamente para aplicar as permissões e verifique a instalação:

  ```bash
  docker ps
  ```

3. **Instalação do Docker Compose**
- Instale o Docker Compose:

  ```bash
  sudo curl -SL https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  ```

- Verifique a instalação:

  ```bash
  docker-compose --version
  ```

4. **Configuração do Ponto de Montagem**
- Instale o cliente Amazon EFS:

  ```bash
  sudo yum install -y amazon-efs-utils
  ```

- Crie o ponto de montagem:

  ```bash
  sudo mkdir efs
  ```

- Monte o EFS:

  ```bash
  sudo mount -t efs <efs file-system-id>:/ /home/ec2-user/efs/
  ```

- Use o ID do sistema de arquivos que você está montando no local `<efs file-system-id>`.

5. **Instalação do WordPress**
- Baixe a imagem oficial do WordPress:

  ```bash
  docker pull wordpress
  ```

- Crie um diretório para o projeto:

  ```bash
  mkdir projeto-docker
  cd projeto-docker
  ```

- Crie o arquivo `docker-compose.yml` usando o script que está neste repositório e configure as variáveis de ambiente:

  ```bash
  nano docker-compose.yml
  ```

- Execute o WordPress com Docker Compose:

  ```bash
  docker-compose up -d
  ```


### 8. Criação do Load Balancer
- Acesse novamente o Console da AWS e vá para a seção **EC2** > **Load Balancers**.
- Clique em **Create load balancer** e escolha **Classic Load Balancer**. 
- Configure as opções:
  - **Scheme**: Internet-facing.
  - **VPC**: escolha a VPC onde as suas instâncias EC2 estão localizadas.
  - **Availability Zones**: selecione as zonas de disponibilidade e as sub-redes públicas usadas pelas instâncias EC2.
  - **Security groups**: associe ao grupo de segurança criado para o Load Balancer.
  - **Listeners and routing**: defina para HTTP na porta 80.
  - **Health Checks**: configure os parâmetros da seguinte maneira:
    - **Ping protocol**: escolha HTTP.
    - **Ping port**: defina 80.
    - **Ping path**: insira `/wp-admin/install.php`.

  - **Advanced health check settings**: defina os seguintes parâmetros:
    - **Response timeout**: 5 segundos.
    - **Interval**: 30 segundos.
    - **Healthy threshold**: 3. 
    - **Unhealthy threshold**: 2.

- Associe o Load Balancer às instâncias EC2.
- Clique em **Create load balancer** para finalizar.
- Após a criação, na seção **Details**, copie o **DNS name**.
- Use o **DNS name** no navegador para acessar a aplicação WordPress.

### 9. Criação do Auto Scaling Group



