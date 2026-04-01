[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/sauAhTKi)
# PE1 Opdracht 1

- [BASISOPDRACHT (8p)](#basisopdracht-8p)
- [EXTRA'S (12p)](#extras-12p)
  - [EXTRA 1: Environment (3p)](#extra-1-environment-3p)
  - [EXTRA 2: Web (3p)](#extra-2-web-3p)
  - [EXTRA 3: apache2 (6p)](#extra-3-apache2-6p)
- [Officiële builtin module documentatie](#officiële-builtin-module-documentatie)

---

Instructies:

- Gebruik het voorbereide Vagrant en Ansible lab in deze directory.
- Doe (`cd`) naar de project directory
- typ `code .`
- Bouw één Ansible oplossing.
- pas de bestaande `playbook.yml` en `inventory.ini` files aan
  - voeg geen host variabelen toe in de statische inventory file `inventory.ini`
- maak nieuwe files bij al naargelang
- gebruik named tasks
- **behoud de play en task volgorde gelijkaardig aan de volgorde in deze assignment**
- plaats geen verificatie of reporting tasks vóór de tasks die de files maken of wijzigen die ze controleren
- je mag de `ansible.builtin.command` of `ansible.builtin.shell` modules niet gebruiken, tenzij expliciet gevraagd in de assignment
- Het gebruik van scripts is niet toegestaan, tenzij expliciet gevraagd in de assignment
- Manuele aanpassingen aan de VM zijn niet toegestaan, tenzij om manueel iets te testen. Vergeet deze manuele acties niet ongedaan te maken.
- enkel oplossingen die vóór de deadline gecommit zijn, worden geëvalueerd

---

## BASISOPDRACHT (8p)

**Database server tasks:**

- definieer deze variabelen enkel voor de groep **`dbservers`**:
  - `database`: `app_db`
  - `table_users`: `users`
  - `sql_script_directory`: `/opt/pe1/db-scripts/`
- installeer de packages `postgresql-server` en `postgresql` op de hosts in de groep `dbservers`
  - de naam van de bijhorende service is `postgresql`
- stop en disable de service `firewalld` op de `dbservers` hosts
- zorg ervoor dat de `postgresql` service enabled en gestart is
- initialiseer postgres:
  - gebruik de file `init_postgres.sh` in deze repo
  - voer dit uit op de managed host met de module `ansible.builtin.command`
- maak een Jinja2 template voor `/opt/pe1/db-scripts/init.sql`
  - gebruik `database` en `table_users` in de SQL template
  - de Jinja2 template moet renderen naar deze inhoud:

    ```sql
    -- create database only if it does not exist
    SELECT 'CREATE DATABASE app_db'
    WHERE NOT EXISTS (
        SELECT FROM pg_database WHERE datname = 'app_db'
    )\gexec

    -- connect to the database
    \connect app_db

    -- create table if not exists
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ```

- Druk deze waarden afdrukken voor de `init.sql` file in je playbook output:
  - `exists: true`
  - `path: /opt/pe1/db-scripts/init.sql`
  - gebruik de module `ansible.builtin.stat`

---

## EXTRA'S (12p)

De extra's worden *enkel* beoordeeld als de Basis Opdracht *volledig succesvol* is volbracht.

Vul de playbook aan met volgende extra features:

### EXTRA 1: Environment (3p)

- definieer deze variabelen voor **de groep webservers**:
  - stel `my_environment` in op `web-env`
  - stel `my_env_name` in op `Webservers`
- definieer deze variabelen voor **de groep dbservers**:
  - stel `my_environment` in op `dv-env`
  - stel `my_env_name` in op `Database Servers`
- gebruik `ansible.builtin.lineinfile` om ervoor te zorgen dat `/etc/environment` exact deze regels bevat:

  ```text
  ENV1=web-env
  ENV2=Webservers
  ```

  - hardcode deze regels niet, ze moeten dynamisch opgebouwd worden met groepsvariabelen
- voor alle hosts, nadat de vereiste regels aanwezig zijn in `/etc/environment`:
  - toon de inhoud van `/etc/environment` in de Ansible output
  - gebruik hiervoor `ansible.builtin.command` met `cat` op de juiste manier

---

### EXTRA 2: Web (3p)

**Web tasks:**

- definieer deze groepsvariabelen, enkel voor `webservers`:
  - `service_name`: `web`
  - `service_id`: `42`
- zorg dat de directory `/opt/pe1/web` bestaat op alle hosts in `webservers`
- maak een Jinja2 template voor `/opt/pe1/web/data`
  - de gegenereerde file moet exact deze regels bevatten op elke host:

    ```text
    ID: 42
    Service: web
    Hostname: webserver1
    Host Architecture: x86_64
    ```

  - gebruik de variabelen `service_name` en `service_id` in de template
  - **alle regels zijn dynamisch**, niets is hardcoded, inclusief de laatste 2 regels
- voor elke host in `webservers`, nadat de file `/opt/pe1/web/data` is aangemaakt
  - toon de inhoud van `/opt/pe1/web/data` in de Ansible output
  - gebruik hiervoor `ansible.builtin.command` met `cat` op de juiste manier

---

### EXTRA 3: apache2 (6p)

**Apache2:**

- definieer deze variabelen enkel voor de groep **`webservers`**:
  - `web_root`: `/var/www/pe1`
  - `index_file`: `index.html`
  - `apache_port`: `8080`
- installeer de packages `httpd` op de hosts in de groep `webservers`
  - de naam van de bijhorende service is `httpd`
- stop en disable de service `firewalld` op de `webservers` hosts
- maak de web root directory met de waarde van `web_root`
  - zorg dat deze bestaat en correcte permissies heeft (eigendom van user `apache`)
- maak een Jinja2 template voor de Apache configuratie file
  - bestemming: `/etc/httpd/conf.d/pe1.conf`
  - gebruik de variabele `apache_port`
  - Apache moet luisteren op poort `8080` via de variabele `apache_port`
  - gebruik de variabele `web_root` zodat de directory dynamisch is
  - de template moet exact renderen naar:

  ```apache
  Listen 8080

  <VirtualHost *:8080>
      DocumentRoot "/var/www/pe1"

      <Directory "/var/www/pe1">
          AllowOverride None
          Require all granted
      </Directory>
  </VirtualHost>
  ```

- zorg ervoor dat de `httpd` service enabled en gestart is
- maak een Jinja2 template voor de webpagina
  - bestemming is de file `index_file` in de directory `web_root`
  - gebruik de variabelen `web_root` en `apache_port` in de template
  - de template moet exact renderen naar:

  ```html
  <!DOCTYPE html>
  <html>
  <head>
      <title>PE1 Web Server</title>
  </head>
  <body>
      <h1>Web server running</h1>
      <p>Served from /var/www/pe1 on port 8080</p>
  </body>
  </html>
  ```

- nadat de web server tasks uitgevoerd zijn, moet je playbook output deze waarden tonen voor de index file:
  - `exists: true`
  - `path: /var/www/pe1/index.html`
  - gebruik de module `ansible.builtin.stat`
- na uitvoeren van je playbook moet dit commando werken vanaf de laptop:

  ```bash
  curl http://10.10.0.10:8080
  ```

---

## Officiële builtin module documentatie

- `ansible.builtin.command`: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html)
- `ansible.builtin.debug`: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html)
- `ansible.builtin.dnf`: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/dnf_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/dnf_module.html)
- `ansible.builtin.file`: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)
- `ansible.builtin.lineinfile`: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html)
- `ansible.builtin.service`: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html)
- `ansible.builtin.stat`: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/stat_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/stat_module.html)
- `ansible.builtin.template`: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)
