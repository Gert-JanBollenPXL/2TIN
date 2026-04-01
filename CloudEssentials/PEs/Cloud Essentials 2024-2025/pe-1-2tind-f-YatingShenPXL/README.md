[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/boXw-gmc)
# PE 1: Management console / CLI in AWS (150 punten)

## Overzicht
Voor de PE opdracht is een aparte AWS Academy learner lab omgeving opgezet met als naam [AWS Academy Learner Lab [98458]](https://awsacademy.instructure.com/courses/98458)

Voor deze PE werk je met de AWS management console of de AWS CLI (versie 2). Onderstaande infrastructuur wordt opgezet. Je beschrijft de oplossingen zoals gevraagd in het bestand `oplossing.md` met de nodige commando's en screenshots. Screenshots kan je embedden in je oplossing bestand met `![alt text](./images/image.png)`.

Indien je gebruik maakt van de management console neem je screenshots van *alle* invulformulieren in de webapplicatie. Bij het gebruik van de CLI toon je screenshots van de gebruikte commando's en output.

**Let goed op de naamgevingen van de elementen die je opzet en de gevraagde tags (key & value). Deze moeten _exact_ overeenkomen om punten te kunnen krijgen op de verschillende onderdelen.**

Het is enkel toegestaan om gebruik te maken van zelfgemaakte notities in `docx` of `pdf` formaat, de officiële AWS (CLI) documentatie op 
[https://docs.aws.amazon.com/index.html](https://docs.aws.amazon.com/index.html), [https://docs.aws.amazon.com/cli/latest/index.html](https://docs.aws.amazon.com/cli/latest/index.html) en [https://docs.aws.amazon.com/cli/index.html](https://docs.aws.amazon.com/cli/index.html)

_Veel succes!_

## Deel 1
Een voorbeeld van de gevraagde output is te vinden onder _Antwoord A_ in de file `oplossing.md`.

### VPC (B) - 10 punten
Maak een nieuwe VPC aan met als cidr block 10.0.0.0/16. Zorg ervoor dat deze VPC een tag krijgt met als key `Name` en als value `vpc-pe`.

Documenteer je commando(s) en screenshot in `oplossing.md` onder de titel `Antwoord B`.

### Publieke subnets (C) - 30 punten
Voorzie 2 publieke subnets met de cidr blocks 10.0.0.0/24 en 10.0.1.0/24 in de availability zone's us-east-1a en us-east-1b. Beide subnets moeten publieke IPs geven bij het aanmaken van nieuwe EC2 instances. Tip: `--map-public-ip-on-launch`.

Zorg ervoor dat deze subnets tags krijgen met als key `Name` en als value `vpc-pe-public-1` en `vpc-pe-public-2`.

### VPC internet connectie (D) - 20 punten
Zorg ervoor dat de VPC voorzien is van een internetverbinding a.d.h.v. een internet gateway (naam `vpc-pe-igw`) & route-table (naam `vpc-pe-public-rtb`). Voorzie de nodige routes in je route tabel zodat de publieke subnets bereikbaar zijn. Je mag de route tabel hergebruiken voor beide subnets.

Documenteer je commando(s) en screenshot in `oplossing.md` onder de titel `Antwoord D`.

## Deel 2
### Security group (E) - 20 punten
Maak een nieuwe security group met als naam `pe-secgroup` in de `vpc-pe` VPC. Voeg 3 inbound rules toe: 
* Binnenkomend ssh verkeer (poort 22) vanuit jouw IP adres
* Binnenkomend http verkeer (poort 80) van overal
* Binnenkomend verkeer op poort 99 vanuit het IP adres 8.8.8.8

### Keypair (F) - 10 punten
Maak een nieuw keypair aan met als naam `pe-key` en als type `rsa`.

### EC2 instances (G) - 30 punten
Maak 2 nieuwe instances (beide in een ander publiek subnet in jouw aangemaakte VPC) met als naam `ec2-pe-1` en `ec2-pe-2` gebruik makend van de `Amazon linux 2 AMI (HVM) - Kernel 5.10 SSD Volume type`. Je kan de `ami-id` opzoeken indien nodig. De instance type is `t2.micro` en je koppelt de `pe-key` aan de instance. Zorg ervoor dat beide instances gebruik maken van het userdata script dat je kan terugvinden in de root directory van deze folder (`./userdata`).

Zorg er eveneens voor dat de instances gebruik maken van de security group `pe-secgroup` die je gemaakt hebt in een van de vorige stappen. Dit is de enige securitygroup die gekoppeld mag zijn aan de instances.

Documenteer je commando(s) en screenshot in `oplossing.md` onder de titel `Antwoord G`.

## Deel 3

### Static S3 website (H) - 30 punten
Zet een nieuwe s3 bucket op met als naam `cloud-pe-studentennummer`. Zorg ervoor dat deze bucket werkt als een static website die je kan bezoeken. Voorzie de nodige permissies en koppel onderstaalde policy:
```
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "PublicReadGetObject",
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::bucket-name/*"
      }
  ]
}
```

Open lokaal de file `./website/index.html` en pas op regel 29 de url aan naar het publiek IP adres van je EC2 instance `ec2-pe-1`.

Upload de aangepaste file `./website/index.html` naar de root directory van je s3 bucket.

Bezoek de website van je S3 bucket via de browser en voeg een screenshot van de webpagina toe aan je oplossingbestand. 

Bij het bezoeken van deze pagina zou er in het midden een hash moeten verschijnen. Indien er een titel "Cloud serivces rocks!" verschijnt, wil dit zeggen dat de communicatie tussen S3 bucket en je EC2 instance niet werkt.

Plaats de volledige url van je S3 bucket in het `s3bucket.txt` bestand.

Documenteer je commando(s) en screenshot in `oplossing.md` onder de titel `Antwoord H`.

## Indienen

Volg het stappenplan hieronder om je oplossing in te dienen:
- Controleer of alle nodige documentatie is toegevoegd op Github in `oplossing.md`
- Plaats de url van je S3 bucket in het bestand `s3bucket.txt`
- Pas de file `creds.txt` aan en voeg je huidige AWS CLI credentials toe aan de variabelen in deze file. **LET OP: PAS DE VARIABEL NAMEN NIET AAN!! Deze zijn hoofdlettergevoelig**
- Doe een commit met als titel "einde examen" en push deze naar Github (`git push origin main`)
- Controleer nog een laatste keer of alle documentatie op Github staat. Enkel deze documentatie wordt bekeken. Hierna mag je niets meer aan de lab omgeving in AWS academy aanpassen. Alle infrastructuur blijft onaangepast opstaan en moet ten alle tijde overeen komen met de documentatie in `oplossing.md`
