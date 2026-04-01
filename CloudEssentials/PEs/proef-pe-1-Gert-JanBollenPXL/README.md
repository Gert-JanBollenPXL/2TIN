# Proef PE 1: CLI in AWS

## Overzicht
Voor deze PE werk je met de AWS management console of de AWS CLI (versie 2). Onderstaande infrastructuur wordt opgezet. Je beschrijft de oplossingen zoals gevraagd in het bestand `oplossing.md` met de nodige commando's en screenshots. Screenshots kan je embedden in je oplossing bestand met `![alt text](./images/image.png)`.

Indien je gebruik maakt van de management console neem je screenshots van *alle* invulformulieren in de webapplicatie. Bij het gebruik van de CLI toon je screenshots van de gebruikte commando's en output.

**Let goed op de naamgevingen van de elementen die je opzet en de gevraagde tags (key & value). Deze moeten _exact_ overeenkomen om punten te kunnen krijgen op de verschillende onderdelen.**

Het is enkel toegestaan om gebruik te maken van zelfgemaakte notities in `docx` of `pdf` formaat, de officiële AWS (CLI) documentatie op 
[https://docs.aws.amazon.com/index.html](https://docs.aws.amazon.com/index.html), [https://docs.aws.amazon.com/cli/latest/index.html](https://docs.aws.amazon.com/cli/latest/index.html) en [https://docs.aws.amazon.com/cli/index.html](https://docs.aws.amazon.com/cli/index.html)

_Veel succes!_

## VPC (B) - 10 punten
Maak een nieuwe VPC aan met als cidr block 10.0.0.0/16. Zorg ervoor dat deze VPC een tag krijgt met als key `Name` en als value `vpc-pe`.

Documenteer je commando(s) en screenshot in `oplossing.md` onder de titel `Antwoord B`.

## Indienen

Volg het stappenplan hieronder om je oplossing in te dienen:
- Controleer of alle nodige documentatie is toegevoegd op Github in `oplossing.md`
- Pas de file `creds.txt` aan en voeg je huidige AWS CLI credentials toe aan de variabelen in deze file. **LET OP: PAS DE VARIABEL NAMEN NIET AAN!! Deze zijn hoofdlettergevoelig**
- Doe een commit met als titel "einde examen" en push deze naar Github (`git push origin main`)
- Controleer nog een laatste keer of alle documentatie op Github staat. Enkel deze documentatie wordt bekeken. Hierna mag je niets meer aan de lab omgeving in AWS academy aanpassen. Alle infrastructuur blijft onaangepast opstaan en moet ten alle tijde overeen komen met de documentatie in `oplossing.md`