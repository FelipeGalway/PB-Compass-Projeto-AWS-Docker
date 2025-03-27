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
- Criação da **VPC**:
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

### 5. Acesso à Instância EC2 via SSH
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

- Adicione o ec2-user ao docker grupo para que você possa executar Docker comandos sem usar `sudo`:

  ```bash
  sudo usermod -a -G docker ec2-user
  ```

- Obtenha as novas permissões de grupo docker efetuando logout e login novamente. Para fazer isso, feche a janela do terminal SSH atual e reconecte-se à sua instância em uma nova. Sua nova sessão SSH deverá ter as permissões de grupo docker apropriadas.

- Verifique se o ec2-user pode executar comandos do Docker sem usar o sudo.

  ```bash
  docker ps
  ```

### 2. Instalação do Docker Compose
- Instale o **Docker Compose** utilizando o gerenciador de pacotes do Amazon Linux:

  ```bash
  sudo curl -SL https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  ```

- Verifique se o Docker Compose foi instalado corretamente:

  ```bash
  docker-compose --version
  ```

  ### 3. Instalação do WordPress
- Instale a imagem oficial do **WordPress**:

  ```bash
  docker pull wordpress
  ```

- Crie uma pasta para o projeto e navegue até ela:

  ```bash
  mkdir projeto-docker
  cd projeto-docker
  ```

- Crie o arquivo `docker-compose` e adicione o script que está neste repositório, fazendo as alterações necessárias nas variáveis de ambiente:

  ```bash
  nano docker-compose.yml
  ```

- Inicie a instalação do **WordPress** através do **Docker Compose**:

  ```bash
  docker-compose up
  ```