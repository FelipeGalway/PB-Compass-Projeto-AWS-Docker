# PB-Compass-Projeto-AWS-Docker
Projeto desenvolvido como parte do programa de bolsas de DevSecOps da Compass Uol, focado na implementação de uma solução de infraestrutura utilizando AWS e Docker. Consiste na instalação e configuração do Docker em uma EC2 para o deploy de uma aplicação Wordpress em contêiner.

## Tecnologias Utilizadas

Este projeto utiliza diversas tecnologias:

- **Amazon VPC**: para criação de redes e sub-redes na AWS.
- **AWS EC2**: para provisionamento de uma instância virtual na nuvem.
- **Amazon Linux**: sistema operacional utilizado na instância EC2.


---

## Etapa 1: Configuração Inicial do Ambiente na AWS

### 1. Criação de uma VPC na AWS
- Acesse a seção **VPC** e depois **Your VPCs**. 
- Clique em **Create VPC** e selecione a opção **VPC and more**. 
- Configure a VPC com **2 sub-redes públicas** e **2 sub-redes privadas**.
- Vá até a seção **Internet Gateways** e verifique se o Internet Gateway criado está associado à VPC criada anteriormente. 
- Caso o internet Gateway não esteja associado, associe-o seguindo os seguintes passos:
  - Selecione o Internet Gateway.
  - Clique em **Actions**.
  - Clique em **Attach to VPC** e escolha a VPC criada.

### 2. Configuração do Security Group
- Navegue até a seção **EC2** em **Security Groups** e selecione o grupo associado à VPC criada.
- Configure as regras de entrada nas seguintes portas:
  - **HTTP** (porta 80)
  - **SSH** (porta 22)
  - **NFS** (porta 2049)
- Nas regras de saída, configure **All Traffic**, permitindo acesso ao IP `0.0.0.0/0`.

### 3. Criação de uma Instância EC2
- Navegue até a seção **EC2** em **Instances** e clique em **Launch instances**.
- Adicione as tags necessárias e utilize a **Amazon Linux 2023 AMI** como imagem base para a instância.
- Crie e vincule uma chave **.pem** à instância para permitir o acesso SSH.
- Associe a instância à VPC criada anteriormente, colocando-a em uma sub-rede pública.
- Associe a instância ao **Security Group** configurado no passo anterior.
- Finalize a criação clicando em **Launch instance**.

### 4. Criação do Banco de Dados no RDS 
- Acesse a seção **Aurora and RDS** e depois **Databases**.
- Clique em **Create database** e selecione **MySQL**. 
- Configure o Banco de Dados e associe-o à instância criada no passo anterior, na seção **Connectivity**.
- Finalize a criação clicando em **Create database**.

### 5. Criação do Sistema de Arquivos EFS
- Navegue até a seção **EFS** e clique em **Create file system**.
- Escolha a VPC e as sub-redes onde o EFS será montado, garantindo que ele esteja na mesma VPC das instâncias EC2 e do RDS para comunicação interna.
- Finalize clicando em **Create**.

### 6. Acesso à Instância EC2 via SSH
- Acesse a instância via SSH para realizar as configurações necessárias.
- A conexão pode ser realizada utilizando o **Visual Studio Code** da seguinte maneira: 
  - Selecione a instância na AWS e clique em **Connect**. 
  - Copie o comando exibido no campo **SSH Client** e cole no terminal do VS Code. 
  - Substitua `"nome_da_chave"` pelo caminho correto da chave, que deverá estar em `C:\Users\seu_usuario\.ssh`.

---

## Etapa 2: Instalação do WordPress usando Docker Compose 

### 1. Instalação do Docker
- Atualize os pacotes instalados e o cache de pacotes em sua instância:

  ```bash
    sudo yum update -y
  ```

- Instale o mais recente Docker Pacote Community Edition:

  ```bash
  sudo yum install -y docker
  ```

- Inicie o Docker:

  ```bash
  sudo service docker start
  ```

- Adicione o ec2-user ao grupo do Docker para que você possa executar os comandos sem usar `sudo`:

  ```bash
  sudo usermod -a -G docker ec2-user
  ```

- Obtenha as novas permissões efetuando logout e login novamente. 

- Após iniciar nova conexão SSH, verifique se o `ec2-user` pode executar comandos do Docker sem usar o `sudo`:

  ```bash
  docker ps
  ```

### 2. Instalação do Docker Compose
- Instale o **Docker Compose** utilizando os seguintes comandos:

  ```bash
  sudo curl -SL https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  ```

- Verifique se o Docker Compose foi instalado corretamente:

  ```bash
  docker-compose --version
  ```

### 3. Configurando o Ponto de Montagem
- Instale o cliente Amazon EFS utilizando o seguinte comando:

  ```bash
  sudo yum install -y amazon-efs-utils
  ```

- Crie uma pasta para ser o ponto de montagem:

  ```bash
  sudo mkdir efs
  ```

- Configure a montagem usando o ID do sistema de arquivos:

  ```bash
  sudo mount -t <efs file-system-id> <efs-mount-point>/
  ```

- Use o ID do sistema de arquivos que você está montando no local `file-system-id` e a pasta configurada no passo anterior no lugar do `efs-mount-point`.

### 4. Instalação do WordPress
- Instale a imagem oficial do **WordPress**:

  ```bash
  docker pull wordpress
  ```

- Crie uma pasta para o projeto e navegue até ela:

  ```bash
  mkdir projeto-docker
  cd projeto-docker
  ```

- Crie o arquivo `docker-compose.yml` e adicione o script que está neste repositório, fazendo as alterações necessárias nas variáveis de ambiente:

  ```bash
  nano docker-compose.yml
  ```

- Inicie a instalação do **WordPress** através do **Docker Compose**:

  ```bash
  docker-compose up -d
  ```

### 5. Utilizando o User Data 
Como alternativa, é possível utilizar o User Data durante a criação da instância EC2 para iniciar a instância com tudo já instalado e pronto para ser executado. Para fazer isso, siga os seguintes passos:
- Crie uma nova instância seguindo os passos de criação da instância anterior.
- Durante o processo de criação, acesse a seção **Advanced Details** e role até a parte inferior até encontrar **User Data**.
- Cole o script presente neste repositório no campo de User Data (lembre-se de acrescentar o ID do sistema de arquivos EFS e também as variáveis de ambiente para a conexão com o Banco de Dados).
- Finalize a criação da instância clicando em **Launch instance**.
- Para que estabeleça uma conexão do Banco de Dados RDS com a nova instância:
  - Navegue até a seção **Aurora and RDS**, depois **Databases** e acesse o Banco de Dados criado anteriormente.
  - Na seção **Connectivity & security**, role até **Connected compute resources**, expanda **Actions**, clique em **Set up EC2 connection**, escolha a nova instância criada e finalize clicando em **Continue**. 

Com essa abordagem, não será necessário realizar manualmente a instalação do Docker, do Docker Compose e do WordPress, nem configurar o ponto de montagem, pois a instância será iniciada com tudo já instalado e configurado.

---

## Etapa 3: Configuração Final do Ambiente na AWS
