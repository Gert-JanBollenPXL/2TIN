# A
## Test deployment workkflow

-> userdata script om ubuntu rechten te geven voor docker:

```
#cloud-config
package_update: true
package_upgrade: true
runcmd:
  - apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
  - apt-get update
  - apt-get install -y docker-ce
  - systemctl enable docker
  - usermod -aG docker ubuntu
power_state:
  mode: reboot
```

eerst geprobeerd met een gewoon bash script, maar een reload was nodig en deze gebruikte dan het userdata script opnieuw, wat niet de bedoeling is.

-> test deployment: naar poort 3000

![calc_app_test](/img/image.png)

-> production deployment: naar poort 80 (gewone http poort), ook te zien in github actions workflow (curl commando)

![calc_app_production](/img/image-1.png)

## Integratietesten met postman

-> handmatig testen: Zelf een POST sturen om een student toe te voegen (met de key:2TINDEVOPS in de header)

![Student_POST](/img/image-3.png)

-> Automatische testen:

tests voor GET students:

![Test_Students_GET](/img/image-2.png)

body van request GET students:

![Test_Students_GET_Body](/img/image-4.png)

tests voor GET student{id}:

![Test_Student{id}_GET](/img/image-5.png)

body van request GET student{id}:

![Test_Student{id}_GET](/img/image-6.png)

De geëxporteerde JSON test suite kan u vinden in: tests/api-testcollection-groep2.json

# B
## End to end testen

![playwright_tests](/img/image-7.png)

```
await.page.goto('/')
```

Gaat naar BASE_URL (Staat onder vars van de repository), dit is ook geconfigureerd in de playwright config file.

![alt text](/img/image-8.png)
