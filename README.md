# PB-Compass-Projeto-AWS-Docker

Este projeto foi desenvolvido como parte do programa de bolsas de **DevSecOps** da **Compass Uol**. O objetivo é implementar uma solução de infraestrutura na **AWS** utilizando **Docker** para o deploy de uma aplicação **WordPress** em contêiner. A solução envolve a configuração de instâncias **EC2** através de um **Auto Scaling Group** e de um **Load Balancer**, a instalação do **Docker**, e  integração com **Amazon RDS** e **EFS** para garantir a persistência de dados e armazenamento compartilhado entre os contêineres.

---

## Tecnologias Utilizadas

São utilizadas diversas tecnologias:
- **Amazon VPC**: para criar redes e sub-redes na AWS.
- **AWS EC2**: para provisionar e gerenciar instâncias virtuais.
- **Amazon Linux 2023**: sistema operacional utilizado na instância EC2.
- **Docker**: para empacotar e executar a aplicação WordPress.
- **Docker Compose**: para facilitar a configuração dos contêineres.
- **Amazon RDS (MySQL)**: para gerenciar o banco de dados da aplicação.
- **Amazon EFS**: para armazenamento compartilhado entre contêineres.
- **Classic Load Balancer (CLB)**: para distribuir o tráfego entre as instâncias de aplicação.
- **Auto Scaling**: permitir escalar automaticamente as instâncias conforme a demanda de tráfego.
- **CloudWatch**: para monitoramento e alarmes, acompanhando métricas como uso de CPU.

---

## Etapas do Projeto

### 1. Criação de uma VPC
- Acesse o Console AWS e vá para a seção **VPC**. 
- Clique em **Create VPC** e selecione a opção **VPC and more**. 
- Crie uma VPC com **2 sub-redes públicas** e **2 sub-redes privadas**.
- Selecione duas ***Availability Zones (AZs)** e um **NAT Gateway**.
- Finalize a criação clicando em **Create VPC**.

### 2. Criação dos Security Groups
- O projeto requer quatro grupos de segurança:
  - **web**: acessso às instâncias.
  - **clb**: acesso para o Load Balancer.
  - **rds**: acesso ao banco de dados.
  - **efs**: acesso ao sistema de arquivos.  

- Após a criação, edite as regras da seguinte maneira:

1. **Security Group Web**
- **Regras de entrada**: configure uma regra HTTP na porta 80, permitindo tráfego de origem do grupo de segurança do Load Balancer.
- **Regras de saída**: 
  - **All Traffic** com o destino `0.0.0.0/0`.
  - **HTTP** na porta 80, com o destino para o grupo de segurança do Load Balancer.
  - **MYSQL/Aurora** na porta 3306, com o destino para o grupo de segurança do RDS.
  - **NFS** na porta 2049, com o destino para o grupo de segurança do EFS.

2. **Security Group do Load Balancer**
- **Regras de entrada**: configure uma regra **HTTP** na porta 80, permitindo tráfego de origem `0.0.0.0/0`.
- **Regras de saída**: configure uma regra **HTTP** na porta 80, com o destino para o grupo de segurança Web.

3. **Security Group do RDS**
- **Regras de entrada**: configure uma regra **MYSQL/Aurora** na porta 3306, permitindo tráfego de origem do grupo de segurança Web.
- **Regras de saída**: configure uma regra **MYSQL/Aurora** na porta 3306, com o destino para o grupo de segurança Web.

4. **Security Group do EFS**
- **Regras de entrada**: configure uma regra **NFS** na porta 2049, permitindo tráfego de origem do grupo de segurança Web.
- **Regras de saída**: configure uma regra **NFS** na porta 2049, com o destino para o grupo de segurança Web.

### 3. Criação do Banco de Dados no RDS 
- Vá para **Aurora and RDS** > **Databases** e clique em **Create database**.
- Selecione **MySQL** e configure o banco de dados com as seguintes opções:
  - **Engine Version**: última versão disponível.
  - **Templates**: selecione **Free tier**.
  - Personalize o nome do banco de dados e o nome de usuário, definindo uma senha. 
  - Escolha a instância **db.t3.micro**. 
  - **Connectivity**: selecione **Don’t connect to an EC2 compute resource**, associe ao grupo de segurança do RDS e à VPC criada.
  - **Additional configuration**: defina um nome para a base de dados.

- Finalize clicando em **Create database**.

- Caso não consiga selecionar o grupo de segurança do RDS durante a criação e o banco de dados ficar vinculado ao grupo de segurança padrão, altere as regras de entrada e saída desse grupo para as regras do grupo do RDS.

### 4. Criação do Sistema de Arquivos EFS
- Acesse a seção **EFS** e clique em **Create file system**.
- Selecione a VPC criada e as duas sub-redes privadas. 
- Finalize  clicando em **Create file system**.

### 5. **Criação do Launch Template para Lançamento das Instâncias**
- Vá para a seção **EC2** e acesse **Launch Templates** > **Create launch template**.
- Personalize com o nome e a descrição.
- Selecione **Amazon Linux 2023 AMI** e **t2.micro**.
- Vincule o grupo de segurança Web e adicione as tags necessárias.
- Use o script de **User Data** disponível neste repositório, fazendo as seguintes alterações:
  - Substitua `<efs file-system-id>` pelo ID do sistema de arquivos EFS.
  - Substitua `<RDS-ENDPOINT>` pelo endpoint do banco de dados.
  - Substitua `<db_name>`, `<db_user>` e `<db_password>` pelas credenciais do banco de dados.

- Finalize clicando em **Create launch template**.

### 6. Criação do Load Balancer
- No menu lateral, acesse **Load Balancers** > **Create load balancer** > **Classic Load Balancer**. 
- Configure as opções:
  - **Scheme**: Internet-facing.
  - **VPC**: escolha a VPC criada.
  - **Availability Zones**: selecione as zonas de disponibilidade e as sub-redes públicas.
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

- Finalize clicando em **Create load balancer**.

### 7. Criação do Auto Scaling Group
- Acesse **Auto Scaling Groups** > **Create Auto Scaling group**.
- Selecione o **Launch Template** criado anteriormente.
- Configure a VPC, sub-redes privadas, e associe o Load Balancer.
- Marque a opção **Turn on Elastic Load Balancing health checks**.
- Configure a capacidade da seguinte maneira:
  - **Desired capacity**: 2.
  - **Min desired capacity**: 2.
  - **Max desired capacity**: 4.

- Selecione **No scaling policies**. 
- Marque a opção **Enable group metrics collection within CloudWatch**.
- Adicone as tags que desejar.
- Finalize clicando em **Create Auto Scaling group**. 

### 8. Acesso ao WordPress
- Vá para a seção **Instances** e aguarde a criação das instâncias.
- Após a criação, acesse o Load Balancer e verifique o status das instâncias na seção **Target instances**.
- Se estiverem com o status **In-service**, copie o **DNS name** e cole-o no navegador para acessar a aplicação WordPress.
- Faça a configuração e depois o login no WordPress para acessar a página inicial.

## 9. Criação de Alarme no CloudWatch
- Selecione o Auto Scaling Group criado e acesse **Automatic scaling** > **Create dynamic scaling policy**.
- Configure da seguinte maneira:
  - **Policy type**: Simple scaling.
  - **Scaling policy name**: personalize com um nome.
  - **Take the action**: selecione **Add**, com valor **2**.

- Finalize clicando em **Create**.
- Navegue até a seção **ClouWatch**, em **Alarms**, clique em **In alarm** e depois em **Create alarm**.
- Clique em **Select metric** > **EC2** > **By Auto Scaling Group**.
- Selecione a métrica **CPUUtilization** e clique em **Select metric**.
- Em **Whenever CPUUtilization is...**, selecione **Greater/Equal** e digite 80 em **than...**.
- Em **Notification**, clique em **Remove** para excluir a notificação. 
- Clique em **Auto Scaling action**, selecione o Auto Scaling Group criado.
- Dê um nome para o alarme e finalize clicando em **Create alarm**.

---

## Conclusão

O projeto cria uma infraestrutura bem escalável e eficiente para rodar o WordPress na AWS, usando Docker e vários serviços da AWS, como EC2, RDS, EFS e Auto Scaling. Com a configuração de VPCs, grupos de segurança e balanceamento de carga, garantimos que a aplicação fique segura, disponível e possa crescer conforme a demanda. E com a integração do CloudWatch, é possível automatizar ajustes de capacidade das instâncias, otimizando os recursos e ajudando a reduzir os custos.
