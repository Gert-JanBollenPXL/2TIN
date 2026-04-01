[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/BavG4rug)
# PE 1: AWS Management & CLI Implementatie (150 punten)

## Overzicht
Voor deze PE-opdracht werk je in een aparte AWS Academy leeromgeving met de naam [AWS Academy Learner Lab 141250](https://awsacademy.instructure.com//courses/141250).

Tijdens deze opdracht zal je een  infrastructuur opzetten in AWS via **de Management Console** of via de **AWS CLI (versie 2)**.  
De resultaten worden gedocumenteerd in het bestand `oplossing.md`, samen met alle relevante **commando’s** en **screenshots**.

Screenshots voeg je toe met de markdown-syntax:  
`![beschrijving](./images/image.png)`

Gebruik je de **console**, toon dan screenshots van *alle* configuratiepagina’s.  
Gebruik je de **CLI**, toon dan zowel de gebruikte commando’s als de uitvoer.

⚠️ **Let goed op naamgeving en tagging!**  
De gevraagde *keys* en *values* moeten exact overeenkomen met de opdracht. Foute tags of namen betekenen puntenverlies.

Tijdens het examen mag je enkel gebruik maken van:
- Eigen notities (`.docx` of `.pdf`)
- Officiële AWS documentatie:
  - [https://docs.aws.amazon.com/index.html](https://docs.aws.amazon.com/index.html)
  - [https://docs.aws.amazon.com/cli/latest/index.html](https://docs.aws.amazon.com/cli/latest/index.html)
  - [https://docs.aws.amazon.com/cli/index.html](https://docs.aws.amazon.com/cli/index.html)

Veel succes!

## Deel 1

Een voorbeeld van de verwachte structuur vind je onder **Antwoord A** in `oplossing.md`.

### Networking (B) — 10 punten
Maak een nieuwe **VPC** aan met CIDR-block `10.1.0.0/16`.  
Voorzie de VPC van een tag met:
- **Key:** `Name`  
- **Value:** `vpc-practest`

Documenteer je commando(s) en/of screenshots in `oplossing.md` onder de titel `Antwoord B`

---

### Subnetting(C) — 30 punten
Maak **twee publieke subnets** aan met CIDR-blocks:
- subnet met naam `vpc-practest-public-a` en CIDR `10.1.10.0/24`
- subnet met naam `vpc-practest-public-b` en CIDR `10.1.20.0/24`

Gebruik hiervoor de availability zones:
- `us-east-1a`
- `us-east-1b`

Zorg ervoor dat **instances automatisch een publiek IP-adres** krijgen (`--map-public-ip-on-launch`).

Documenteer je commando(s) en/of screenshots in `oplossing.md` onder de titel `Antwoord C`

---

### Internetverbinding (D) — 20 punten
Maak een internet gateway met naam:
- `vpc-practest-igw`

Koppel deze aan de VPC.  
Maak een route table met naam:
- `vpc-practest-rtb-public`

Voeg een route toe voor internetverkeer (`0.0.0.0/0`) via de internet gateway. Koppel de route table aan beide publieke subnets.

Documenteer je commando(s) en/of screenshots in `oplossing.md` onder de titel `Antwoord D`

## Deel 2

### Security Group (E) — 20 punten
Maak een nieuwe security group aan met naam:
- `prac-secgroup`

De security group hoort bij de VPC `vpc-practest`.  
Voeg drie inbound regels toe:

| Type | Poort | Bron |
|------|--------|------|
| SSH | 22 | Eigen IP-adres |
| HTTP | 80 | 0.0.0.0/0 |
| Custom TCP | 122 | 8.8.4.4/32 |

Documenteer je commando(s) en/of screenshots in `oplossing.md` onder de titel `Antwoord E`

---

### Key Pair (F) — 10 punten
Maak een nieuw **key pair** aan met:
- Naam: `prac-key`
- Type: `rsa`

Documenteer je commando(s) en/of screenshots in `oplossing.md` onder de titel `Antwoord F`

---

### EC2 Instances (G) — 30 punten
Maak **twee EC2-instances** aan met namen:
- `ec2-prac-1`
- `ec2-prac-2`

Gebruik:
- **AMI:** Amazon Linux 2023 kernel-6.1 AMI  
- **Instance type:** `t3.small`
- **Key pair:** `prac-key`
- **Security group:** `prac-secgroup`
- **Subnets:** elk in een verschillend publiek subnet  
- **User data:** script uit `./userdata`

Documenteer je commando(s) en/of screenshots in `oplossing.md` onder de titel `Antwoord G`

## Deel 3

### Static Website in S3 (H) — 30 punten
Maak een nieuwe **S3 bucket** aan met de naam:
- `infra-prac-<studentennummer>`

Activeer **Static Website Hosting** en zorg dat de website publiek toegankelijk is via een browser.  
Gebruik onderstaande bucket policy (pas de bucketnaam aan):

```json
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
Indien je een foutboodschap ziet staan onder de policy editor dan mag je deze negeren.

Open lokaal de file `./website/index.html` en pas **regel 29** aan:  
vervang de URL door het **publieke IP-adres** van `ec2-prac-1`.

Upload vervolgens de aangepaste `index.html` naar de root van je S3 bucket.

Bezoek de S3-website via de browser en voeg een screenshot toe in je documentatie.  

Als de tekst “Cloud services rocks!” verschijnt, betekent dit dat de verbinding met de EC2 instance niet werkt.

Sla de volledige URL van je S3-website op in `s3bucket.txt`.

Documenteer je commando(s) en/of screenshots in `oplossing.md` onder de titel `Antwoord H`

---

## Indienen

Volg deze stappen om je werk in te dienen:

1. Controleer of **alle onderdelen** correct beschreven zijn in `oplossing.md`.
2. Voeg de URL van je S3-website toe in `s3bucket.txt`.
3. Open `creds.txt` en vul je huidige AWS CLI credentials in bij de opgegeven variabelen.  
   ⚠️ **Verander de variabelnamen niet! Deze zijn hoofdlettergevoelig**
4. Commit je werk met het bericht `"einde examen"` en voer een push uit:
   ```bash
   git push origin main
   ```
5. Controleer of alles op GitHub staat.  
   Na het indienen mag je **niets meer aanpassen** in AWS Academy.  
   De infrastructuur moet identiek blijven aan wat je hebt gedocumenteerd.
