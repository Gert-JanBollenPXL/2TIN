# Assignment 2  Source control

Voor deze opdracht maken we gebruik van Github. Voer onderstaande zaken uit op je Linux VM uit les 1.

Je krijgt bij het clonen van deze repository een Github repository met daarin de Calculator applicatie die we ook in de eerste les hebben gebruikt. De main (=master) branch van deze repository is ALTIJD deployable. 

Als eerste na het binnenhalen van de applicatie moet je de dependencies installeren. Dit kan, na het installeren van [NodeJS](https://nodejs.org/en/), met onderstaand commando:

```
npm install
```

De applicatie starten kan na het installeren van NodeJS en de dependencies. Gebruik onderstaand commando in de folder om de applicatie op te starten:

```
npm start
```
_npm scripts staan in de package.json file. Kijk achterliggend zeker even welke commando's daar uitgevoerd worden_

Vervolgens kan je in de browser van je VM surfen naar [http://localhost:3000](http://localhost:3000) om de applicatie te gebruiken.

Het uitvoeren van de unit testen kan met volgend commando:


```
npm test
```


Zoals je al gemerkt hebt, heeft onze calculator applicatie enkel een add functie. Klanten geven ons feedback dat een aftrek functie ook gewenst is. Jouw team is verantwoordelijk voor de implementatie van deze functie. Er is al een kleine aanzet voor deze feature aanwezig om je op weg te helpen.

Je team werkt aan de hand van de github flow. Dit wil dus zeggen dat jullie een nieuwe branch zullen starten. In de les hebben we ook gezien dat het voorzien van goede en gestructureerde commit messages als pull requests belangrijk is. Het is dus ook belangrijk dat jullie dit doortrekken in het afwerken van deze opdracht!


![alt_text](https://i.imgur.com/o09XN75.png "image_tooltip")
_Maak een nieuwe branch en geef deze een duidelijke naam! In deze branch doe je regelmatig een aantal commits._

Voorzie de implementatie in de backend van de applicate in de file `routes.js`, voorzie minstens één unittest die de aftrek functie test en voorzie de implementatie in de frontend (`public/index.html` en `public/frontend.js`). **Tegelijkertijd **werkt iemand anders ook al meteen de vermenigvuldig functie uit (en deel functie, macht functie, ... afhankelijk van het aantal teamleden. Elk teamlid werkt 1 feature uit). Ook daar voorzie je de unittesten & implementatie. Denk eraan om ook regelmatig de wijzigingen van je branch te pushen naar Github! Hetzelfde wordt gedaan voor de deel-functie door weer een ander teamlid.

Als je denkt dat een feature klaar is, maak je gebruik van een Pull request om de wijzigingen te mergen naar de main branch. Let hierbij op het gebruik van een **duidelijke omschrijving** & het **taggen van je teamgenoten**! De feature mag pas gemerged worden na toestemming van 2 personen. Je zal hierbij merken dat je maar 1 persoon als reviewer kan toevoegen. Voor meerdere personen is een pro versie van github nodig. Je voegt één persoon toe als reviewer, de andere teamleden tag je in de pull request. Die andere leden geven via de comments al dan niet toestemming voor het mergen.

![alt_text](https://i.imgur.com/o09XN75.png "image_tooltip")
_Voer de pull request uit zoals hierboven beschreven in de repository. Doe daarna ook de merge. Deze moeten terug te vinden zijn in de commit history._


![alt_text](https://i.imgur.com/o09XN75.png "image_tooltip")
_Zorg ervoor dat alle wijzigingen (tot en met de merge) van beide features zichtbaar zijn op Github. Als dit het geval is, wordt deze opdracht gezien als ingediend._

_In een later hoofdstuk zullen we zien hoe hier het deployen naar een QA omgeving tussen de pull request & het effectief mergen naar de master branch kan helpen bij het verhogen van de kwaliteit van onze applicatie._

# Deliverable
Een repository met minstens:
- Verschillende feature branches voor elke feature
- Een PR voor elke feature branch
- Elke feature bevat code in de backend, code in de frontend, unittesten voor de backend
- Een Main branch met de laatste versie van de code
- Goede en duidelijk gestructureerde commit messages & PR messages
- Duidelijke review van de code aanwezig in de PRs
