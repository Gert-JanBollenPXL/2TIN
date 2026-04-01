A - RDS PostgreSQL (20)

Aanmaken DB:
![aanmaken_db1](image.png)
![aanmaken_db2](image-1.png)
![aanmaken_db3](image-2.png)
![aanmaken_db4](image-3.png)
![aanmaken_db5](image-4.png)
![aanmaken_db6](image-5.png)
![aanmaken_db7](image-6.png)
![aanmaken_db8](image-7.png)

B - Database Integratie (20)
Eerst ssh toelaten naar ec2:
![SSH-auth](image-8.png)
SSH:
![SSH](image-9.png)
Nano docker compose:
![docker_compose](image-10.png)
Docker compose up -d:
![docker_compose_up](image-11.png)
Testing:
![Testing](image-12.png)

C- Application Load Balancer (30)

![load_balancer_test](image-13.png)

D - Lambda Functie: Data Ophalen (10)

Gewoon copy-paste

E - Lamba Functie: Data Toevoegen (20)

Code:
![lambda_code1](image-15.png)
![lambda_code2](image-16.png)
Test response:
![lambda_PUT_test](image-14.png)

- deze lijkt te falen in het autogradingscript, terwijl mijn output wel hetzelfde is als de opgave als ik deze test:
![Lambda_POST_test](image-19.png)

F tem J - API Gateway

![API](image-18.png)

- de gewone POST lijkt te werken na proxy integration aan te zetten, de web test faalt wel nog steeds