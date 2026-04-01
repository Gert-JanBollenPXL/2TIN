# Assignment 6 Environments (DTAP) & Testing
We starten deze opdracht met de configuratie van de 2 servers.

## Configuratie
Voor deze opdracht maak je gebruik van 2 virtuele machines in AWS:
*   **Testserver:** Een nieuwe Ubuntu Server VM in de AWS cloud (t2.micro, public subnet, public ip, vergeet je **security group** niet). Je mag hiervoor de Cloud Essentials learner lab gebruiken.
*   **Productieserver:** Een nieuwe Ubuntu Server VM in de AWS cloud (t2.micro, public subnet, public ip, vergeet je **security group** niet). Je mag hiervoor de Cloud Essentials learner lab gebruiken.

Voeg daarnaast ook de code van de calculator app toe aan deze repository. Je kan als alternatief ook rechtstreeks de repository `https://github.com/PXL-2TIN-DevOps-Resources/calculator-app-finished` clonen in de eerste stap van je pipeline.

### Configuratie testserver & productieserver
De servers zijn nieuwe kale Ubuntu vms die we gebruiken voor de deployment van de applicatie in de test- en productieomgeving. Deze draait voor alle groepen in AWS. Installeer docker op je machines. Je kan hiervoor eventueel [deze installatiegidsen](https://www.digitalocean.com/community/tutorial-collections/how-to-install-and-use-docker) gebruiken.

Belangrijk is dat de `ubuntu` user het docker commando moeten kunnen gebruiken (zonder `sudo`!!). Denk doorheen de opdracht ook goed na over het gebruik van security groups (poort 22 voor `ssh`/`scp`, poort 80 voor de gedeployde app, ...).

## Opgave
In deze repository voorzie je 2 workflows. Elke workflow heeft zijn eigen pipeline:
- de test deployment worfklow: Doorloopt het hele CI process en zorgt voor een artifact en deployed dit naar de testserver
- de production deployment workflow: doorloopt enkel het CD proces en neemt het laatste artifact en deployed deze a.d.h.v. `ssh` op de production server

Details van bovenstaande implementaties kan je hieronder terugvinden.

_Tip: Het is niet toegelaten om het `sudo` commando te gebruiken. Heb je geen rechten in bepaalde folders of commando's? Dan zorg je ervoor dat de gebruiker `ubuntu` de juiste rechten krijgt.

# test deployment workflow
Voorzie minimaal volgende steps in deze pipeline:
*   Step `Install dependencies`: Configureer en installeer NodeJS en voer `npm install` uit om dependencies te installeren
*   Step `Build artifact`: In deze stage bouw je een docker image van de nodeJS applicatie. (Tip: Zorg eerst voor een werkende Dockerfile en test deze lokaal). De image wordt vanuit de pipeline gebuild.
*   Step `Push artifact`: In deze stage push je de gebouwde image naar dockerhub. Je maakt hier gebruik van een publieke image op het profiel van één van je teamgenoten.
*   Step `deployment`: In deze stage zorg je ervoor dat de docker container opgestart wordt op poort 3000 en blijft draaien na het uitvoeren van de pipeline.
    * _Tip 1: Gebruik de container vanuit dockerhub!_
    * _Tip 2: Denk eraan dat er misschien nog een vorige versie van de applicatie actief is._
    * _Tip 3: Denk aan je security groups._
    
    
* Als je vervolgens naar [http://<vm-ip>:3000](http://<vm-ip>:3000) surft, zal je de calculator app kunnen gebruiken.

![alt_text](https://i.imgur.com/9leib3p.png "image_tooltip") _Heb je aanpassingen gedaan om ubuntu rechten te geven tot bepaalde mappen of commando's, dan documenteer je dit in oplossing.md onder punt (a)._
  
# production deployment workflow
Het doel van deze pipeline is het voorzien van volgende steps:

*   Stage `pull prod`: Zorg ervoor dat je in deze stage op je remote server de laatste versie van je docker container download a.d.h.v. dockerhub.
*   Stage `start prod`: Zorg ervoor dat de container wordt opgestart op je remote server. Na het opstarten moet je de applicatie kunnen gebruiken op poort 80.
    *   _Tip 1: Maak gebruik van Github secrets voor het opslaan van je credentials voor de SSH verbinding_
*   Stage `test prod`: Doe een check om te kijken of de applicatie werkt. Voorlopig kan je dit testen met het `curl` commando om te controleren of je een statuscode 200 krijgt als je het IP adres van de `productieserver` bezoekt.

# Deliverable
Deze repository met:
- 2 workflows met bovenstaande beschreven stages
    - Een niet werkende (=syntax errors in het pipeline script) Workflow file = -30% op het eindresultaat
    - Gebruik van `sudo` in je workflows resulteert in een 0 op deze PE
- Eventueel de code van de calculator app
- Een opgevulde `oplossing.md` file met antwoorden op bovenstaande vragen inclusief screenshots indien nodig.

# Integratie testen (API)
## Kennismaking API
Er werdt een eenvoudige api gebouwd op [https://devops.d-ries.be/api](https://devops.d-ries.be/api) deze moet getest worden en deze tests willen we geïntegreerd zien in een Github actions pipeline.

Om dit te doen gaan we gebruik maken van Postman en zijn CLI variant Newman. Installeer Postman alvorens te beginnen. Postman kan je downloaden op [https://www.postman.com/downloads/?utm_source=postman-home](https://www.postman.com/downloads/?utm_source=postman-home). 

_De API is beveiligd met een simpele authentication key, deze key is 2TINDEVOPS (in hoofdletters). De key moet meegegeven worden in de header met als naam ‘key’ zoals ook terug te vinden in de Swagger documentatie op de API zelf._

*   Ga aan de slag met de documentatie van de API (deze is te vinden op de api zelf onder de subdir /api). Zorg dat jullie vertrouwd raken met de werking van de API en zijn endpoints.
*   Zorg ervoor dat ieder lid van jullie groep zichzelf ook manueel toevoegt in de API. Dit doe je dus in deze fase handmatig met de tool postman.

## Integratietesten met postman 
*   Voorzie volgende stappen in een test collection (nog steeds in de tool Postman) en sla deze op onder de naam “api-testcollection-&lt;groepsnaam>”
    *   Geef een lijst weer van alle studenten in de API.
    *   Geef de specifieke details weer van een lid van jullie groep weer.
*   Sla de test collection op en exporteer deze in JSON format.

Bij bovenstaande requests doe je via de postman testen ook de nodige controle's of de request gelukt is en of de nodige data weldegelijk aanwezig is in de response. Hoe je dit doet is gezien tijdens de les. Zie ook [https://learning.postman.com/docs/writing-scripts/intro-to-scripts/](https://learning.postman.com/docs/writing-scripts/intro-to-scripts/)

![alt_text](https://i.imgur.com/9leib3p.png "image_tooltip")
_Toon aan met screenshots & uitleg onder **punt (a)** in oplossing.md hoe je het handmatig testen van de API aangepakt hebt. Toon ook de testen die je in Postman geschreven hebt._

![alt_text](https://i.imgur.com/9leib3p.png "image_tooltip")
_Voeg de geëxporteerde JSON files van je postman test suite toe aan deze repository._

# End to end testen
Binnen onze calculator app willen we ook graag enkele automatische e2e testen voorzien. Je gebruikt hiervoor de gedeployde applicatie uit de vorige opdracht &  **playwright**. Maak in deze repository een playwright test project aan met `npm init playwright@latest`. **Voorzie eveneens een `.gitignore` file op de juiste plaats zodat de `node_modules` map niet mee gepusht wordt naar Github**

Gebruik playwright om 2 testen te schrijven:

*   AppHasAddButton: Deze test check of er effectief een &lt;button> element op de webpagina aanwezig is met als inhoud "add". Indien niet moet deze test falen.
*   AppCanSubtract: Deze applicatie test de functionaliteit van de Applicatie, trekt 3 van 7 af en controleert dan of de uitkomst correct op de pagina staat. Indien niet, zal deze test falen.

![alt_text](https://i.imgur.com/9leib3p.png "image_tooltip")
_Toon met screenshots de verschillende stappen in je playwright scripts aan van de verschillende testen onder **punt (b)**._

![alt_text](https://i.imgur.com/9leib3p.png "image_tooltip")
_Sla het project op en voeg de playwright file(s) toe aan deze repository._

# Workflow

Graag zouden we de testen ook willen zien runnen in een pipeline. Bouw een nieuwe workflow in Github actions die volgende steps heeft:

*   `Fetch code`: Deze stapt haalt het playwright test project & de postman `.json` files uit de repository van de opdracht (indien nodig).
*   `Set up environment`: Doe een setup van NodeJS en zorg er ook voor dat newman op het systeem geinstalleerd staat voor gebruik.
*   `Install dependencies`: Deze stap installeert de nodige dependencies voor de playwright testen (`npm install`).
*   `Run e2e test`: Deze stap gebruikt playwright om de e2e testen te runnen in de pipeline. Zorg voor een gegenereerd rapport (JUNIT formaat). De nodige informatie hoe je dit doet kan je terugvinden in de slides.
*   `Run integratie test`: Deze stap voert de postman testen uit a.d.h.v. newman en genereert ook een rapport (JUNIT formaat). Gebruik hiervoor de [newman](https://www.npmjs.com/package/newman) CLI omgeving.
*   `Archive artifact`: Deze stap maakt een artifact van alle gemaakte rapporten uit de vorige stappen.


# Deliverable
- Screenshots & beschrijvingen in oplossing.md
- een `.json` file export van de postman testen, toegevoegd aan deze repository
    - inclusief de test cases
- een playwright project met de e2e testen, toegevoegd aan deze repository
- een opgevulde workflow die gebruik gemaakt van Newman en playwright om de testen uit te voeren
    - Een niet werkende (=syntax errors in het pipeline script) = -30% op het eindresultaat

