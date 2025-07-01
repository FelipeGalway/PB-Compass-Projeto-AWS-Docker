# 🐳 Projeto AWS com Docker: Deploy WordPress Escalável

> Projeto desenvolvido como parte do programa de bolsas **DevSecOps** da **Compass Uol**.  
> O objetivo é implementar uma solução escalável na **AWS**, usando **Docker** para hospedar uma aplicação **WordPress** com banco de dados gerenciado, armazenamento persistente e balanceamento de carga.

---

## ⚙️ Tecnologias Utilizadas

Este projeto combina múltiplos serviços da AWS com ferramentas de containerização:

- 🧱 **Amazon VPC** — Gerenciamento de redes e sub-redes
- 💻 **Amazon EC2** — Instâncias virtuais de aplicação
- 🐧 **Amazon Linux 2023** — Sistema operacional das instâncias
- 🐳 **Docker** — Contêiner da aplicação WordPress
- 🧩 **Docker Compose** — Orquestração dos contêineres
- 🛢️ **Amazon RDS (MySQL)** — Banco de dados gerenciado
- 📂 **Amazon EFS** — Armazenamento de arquivos compartilhado
- ⚖️ **Classic Load Balancer (CLB)** — Balanceamento de tráfego HTTP
- 📈 **Auto Scaling** — Escalabilidade automática de instâncias
- 🔍 **CloudWatch** — Monitoramento e alarmes

---

## 🛠️ Etapas do Projeto

### 🧭 1. Criação da VPC

- Acesse **VPC > Create VPC > VPC and more**
- Crie:
  - 2 sub-redes públicas
  - 2 sub-redes privadas
  - 2 Availability Zones (AZs)
  - 1 NAT Gateway

![VPC](/Prints%20de%20telas/VPC.png)

---

### 🔐 2. Configuração dos Security Groups

Crie **quatro grupos** de segurança:

- `web` — instâncias EC2
- `clb` — Load Balancer
- `rds` — banco de dados
- `efs` — sistema de arquivos

![SGs](/Prints%20de%20telas/SGs.png)

**Regras essenciais**:

1. **web**
   - Entrada: HTTP da `clb`
   - Saída: HTTP, MySQL, NFS e All traffic

2. **clb**
   - Entrada: HTTP (`0.0.0.0/0`)
   - Saída: HTTP para `web`

3. **rds**
   - Entrada/Saída: MySQL com `web`

4. **efs**
   - Entrada/Saída: NFS com `web`

---

### 🗃️ 3. Criação do Banco de Dados (RDS)

- Acesse **RDS > Databases > Create database**
- Escolha:
  - **Engine**: MySQL
  - **Template**: Free tier
  - **Instância**: db.t3.micro
  - **Conectividade**: vincule à VPC e ao SG `rds`

![RDS](/Prints%20de%20telas/RDS.png)

---

### 📂 4. Criação do EFS

- Acesse **EFS > Create file system**
- Selecione a VPC
- Escolha 2 sub-redes privadas
- Vincule o SG `efs`

![EFS](/Prints%20de%20telas/EFS.png)

---

### 🚀 5. Launch Template com User Data

- Vá em **EC2 > Launch Templates > Create**
- Escolha:
  - **AMI**: Amazon Linux 2023
  - **Tipo**: t2.micro
  - **Security Group**: `web`
  - Adicione **User Data** com:
    - ID do EFS
    - Endpoint do RDS
    - Nome/usuário/senha do banco

![Template](/Prints%20de%20telas/Template.png)

---

### ⚖️ 6. Configuração do Load Balancer

- Vá em **Load Balancers > Create > Classic Load Balancer**
- Configure:
  - **Scheme**: Internet-facing
  - **VPC/Sub-redes**: públicas
  - **Listener**: HTTP (porta 80)
  - **Health Check**: `/wp-admin/install.php`

![CLB](/Prints%20de%20telas/ASG.png)

---

### 🔁 7. Criação do Auto Scaling Group

- Acesse **Auto Scaling Groups > Create**
- Configure:
  - **Template**: Launch Template criado
  - **Sub-redes**: privadas
  - **Load Balancer**: CLB
  - **Capacidade**:
    - Min: 2
    - Max: 4
    - Desejado: 2
  - Ative monitoramento com CloudWatch

---

### 🌐 8. Acesso ao WordPress

- Vá em **EC2 > Instances** e aguarde a inicialização
- Verifique se estão **In-service** no Load Balancer
- Acesse o DNS público do CLB no navegador

![WordPress](/Prints%20de%20telas/WP.png)  
![Login](/Prints%20de%20telas/WP%20login.png)

---

### 🔔 9. Alarme no CloudWatch

- Vá em **Auto Scaling > Create dynamic scaling policy**
  - Ação: Add 2 instâncias
- Em **CloudWatch > Alarms > Create alarm**
  - Métrica: `CPUUtilization`
  - Condição: ≥ 80%
  - Ação: escalar com base no ASG

![Alarme](/Prints%20de%20telas/Alarme.png)

---

## ✅ Conclusão

Este projeto entrega uma arquitetura completa e escalável de WordPress na AWS utilizando **Docker**, **RDS**, **EFS** e **Auto Scaling**, com monitoramento via **CloudWatch** e distribuição de tráfego pelo **Load Balancer**.

Com isso, garantimos:
- 🔒 Segurança com SGs específicos
- ♻️ Escalabilidade automática
- 💾 Persistência de dados com EFS e RDS
- 🧩 Automatização do deploy via User Data


