[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/H8dlIcSm)
# PE1 Opdracht 2

- [BASISOPDRACHT (8p)](#basisopdracht-8p)
- [EXTRA'S (12p)](#extras-12p)
  - [EXTRA 1: Production (3p)](#extra-1-production-3p)
  - [EXTRA 2: lineinfile (3p)](#extra-2-lineinfile-3p)
  - [EXTRA 3: db-marker (6p)](#extra-3-db-marker-6p)
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

**Web server tasks:**

- installeer het package `nginx` op de hosts in de `webservers` group
  - de naam van de bijhorende service is `nginx`
- stop en disable de `firewalld` service op de `webservers` hosts
- definieer deze variabelen enkel voor de `webservers` group:
  - `site_title`: `PXL-site`
  - `site_message`: `PXL-2526-PE1`
  - `site_port`: `8080`
  - `web_marker_directory`: `/opt/pe1/web-markers`
- maak een Jinja2 template voor `/etc/nginx/conf.d/pxl-site.conf`
  - gebruik de `site_port` variabele in de nginx configuratie template
  - de nginx configuratie moet nginx laten luisteren op poort `8080`
  - de Jinja2 template moet renderen naar deze content:

    ```js
    server {
        listen 8080;
        server_name _;

        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }
    ```

- maak een Jinja2 template voor `/usr/share/nginx/html/index.html`
  - gebruik `site_title` en `site_message` in de HTML template
  - de file `/usr/share/nginx/html/index.html` moet exact één keer elk van deze regels bevatten:

    ```html
    <title>PXL-site</title>
    <h1>PXL-site</h1>
    <p>PXL-2526-PE1</p>
    ```

- nadat je playbook uitgevoerd is, moet dit command vanaf de laptop werken:

  ```bash
  curl http://localhost:8080
  ```

  - dit `curl` command moet de pagina teruggeven die gerenderd is vanuit `/usr/share/nginx/html/index.html`

**web-marker tasks:**

- zorg ervoor dat de directory uit de variabele `web_marker_directory` bestaat, enkel op de `webservers` hosts
  - maak de file `{{ web_marker_directory }}/web-marker.txt` op `webservers`
  - de content is niet belangrijk en mag leeg zijn
- na het deployen van de configuratie en HTML pagina, restart de `nginx` service vanuit het playbook
- zorg ervoor dat de `nginx` service enabled is
- nadat de web server tasks uitgevoerd zijn, moet je playbook output deze waarden tonen voor de web marker file:
  - `exists: true`
  - `path: /opt/pe1/web-markers/web-marker.txt`

---

## EXTRA'S (12p)

De extra's worden *enkel* beoordeeld als de Basis Opdracht *volledig succesvol* is volbracht.

Vul de playbook aan met volgende extra features:

### EXTRA 1: Production (3p)

**Production tasks:**

- voeg een parent group toe genaamd `production` die `webservers` en `dbservers` bevat
- maak een group variable file die actief is voor de `production` group van hosts
- definieer deze group variabelen, enkel voor `production`:
  - `company_name`: `PXL Automation`
  - `support_email`: `support@pxldemo.local`
- zorg ervoor dat de directory `/opt/pe1` bestaat op alle hosts in `production`
- maak een Jinja2 template voor `/opt/pe1/production-info.txt`
  - de gerenderde file moet exact deze 3 regels bevatten op elke host:

    ```text
    Company: PXL Automation
    Support: support@pxldemo.local
    Host: HOSTNAME
    ```

  - elke regel is dynamisch, niet hardcoded
  - vervang `HOSTNAME` dynamisch met de managed host naam via variabelen
    - op `webserver1` moet de laatste regel zijn: `Host: webserver1`
    - op `dbserver1` moet de laatste regel zijn: `Host: dbserver1`
    - niets hardcoden
- voor elke host in `production`, nadat de file `/opt/pe1/production-info.txt` remote is aangemaakt
  - toon de inhoud van die file in de Ansible output
  - gebruik `ansible.builtin.command` met `cat` correct om de informatie te tonen

---

### EXTRA 2: lineinfile (3p)

**lineinfile tasks:**

- gebruik `ansible.builtin.lineinfile` om ervoor te zorgen dat `/etc/motd` deze exacte regel bevat op `webservers`:

  ```text
  PE1 web node managed by Ansible
  ```

- voor elke host in `webservers`, nadat de vereiste regel aanwezig is in `/etc/motd`
  - toon de inhoud van die file in de Ansible output
  - gebruik `ansible.builtin.command` met `cat`

---

### EXTRA 3: db-marker (6p)

**Shell script:**

- definieer een group variabele enkel voor `dbservers`, genaamd `marker_directory`
  - stel de waarde in op `/opt/pe1/markers`
- zorg ervoor dat de directory uit `marker_directory` bestaat op `dbservers` hosts
- maak een Jinja2 template van nul voor een *shell script*
  - render die template naar het bash script `/usr/local/bin/create-marker.sh`
  - het gerenderde shell script moet het cli command `touch` gebruiken
    - om de file `db-marker.txt` te maken in de directory gedefinieerd in de variabele `marker_directory`
      - hardcode de directory niet
    - wat `touch` doet:

      ```bash
      > touch --help
      Usage: touch FILE...
      A FILE argument that does not exist is created empty.
      Update the access and modification times of each FILE to the current time.
      ```

      - als de file niet bestaat, wordt een lege file aangemaakt
      - als de file al bestaat, wordt de timestamp geüpdatet
    - voer het gerenderde shell script uit in je playbook zodat de marker file aangemaakt wordt op de managed host
      - gebruik de module `ansible.builtin.command`
    - je playbook output moet deze waarden tonen voor het shell script op de managed host:
      - `exists: true`
      - `path: /usr/local/bin/create-marker.sh`

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
