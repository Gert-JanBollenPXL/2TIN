# SECURE CODING

Voor deze PE moet je een lekke zeef dichten. We bekijken een webapplicatie die gekoppeld is aan een backend en een eenvoudige database. De makers van deze app vonden het een goed idee om zelf aan security te doen. Een pen tester heeft deze app doorgelicht en jullie gaan voor deze PE onderstaande risico's elimineren.

## De omgeving
In deze PE vind je enkele belangrijke bestanden. Je krijgt ook alle broncode meegeleverd. Als je de app eens wilt testen, dat kan door docker compose te gebruiken:

    docker compose up --build

Denk eraan, daarvoor moet je wel docker geinstalleerd hebben. Je kan dan de app bezoeken op `localhost:8080`. De app bestaat uit een frontend die geschreven is in Flutter, een backend in Node.js express en een postgresql database. Het bestand Lab.md bevat de engelstalige versie van deze opgave en mag je negeren. Het is ook belangrijk om te noteren dat er enkele binnenwegen genomen zijn zodat jullie gemakkelijk de code kunnen aanpassen en testen. Zo wordt de Flutter app in zijn dockerfile eerst gebuild en dan pas gedeployed naar een nginx server. In praktijk zou je dat build process loskoppelen van de deployment. Er zitten ongetwijfeld ook meer fouten in de app dan hieronder aangegeven! Zo is er bijvoorbeeld ook geen sprake van een https verbinding. We moedigen je aan om op zoek te gaan naar nog andere lekken die je kan vinden!

## FOUT #1: SQL Injection
Onze pen tester heeft opgemerkt dat je toegang kan krijgen tot de database met behulp van een SQL Injection

![task](./task.png) Misbruik de SQL injection fout om toegang te krijgen tot het geheim. Documenteer welk commando je gebruikt hebt hiervoor.

![task](./task.png) Repareer de backend zodat de input gesanitized wordt.

## FOUT #2: Insecure Storage
De paswoorden worden op dit moment plaintext opgeslaan. De developers willen echter echt niet afwijken van hun database want er zijn geen centjes om te migreren.

![task](./task.png) Zorg ervoor dat de paswoorden veilig opgeslagen worden in de database.

![task](./task.png) Controleer dat je ook nog steeds geldig kan inloggen!

## FOUT #3: CORS
De database kan op dit moment van eender waar gequeried worden. We willen dat vermijden aan de hand van CORS.

![task](./task.png) Zoek op wat CORS is. Hoe kan CORS ons hier helpen?

![task](./task.png) Gebruik CORS zodat onze backend enkel door onze frontend mag gebruikt worden.

## FOUT #4: Credentials in Version Control
Op dit moment staan er al heel wat naakte credentials in bijvoorbeeld de docker file, maar ook de backend, etc. 

![task](./task.png) We willen niet dat de credentials opgenomen worden in onze dockerfiles of docker compose files. Hoe kan je dat vermijden? We willen dat onze oplossing ook niet opgenomen wordt in version control.

![task](./task.png) Verwijder op dezelfde manier credentials die je vindt in de backend.

![task](./task.png) Het kwaad is al geschied. We hebben de credentials weggehaald uit ons project, maar iemand die teruggaat in onze branch history kan de credentials nog terug opvissen. Wat is jouw advies?

