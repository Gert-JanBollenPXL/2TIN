terminal length 0  (no --more--)
### Switch

| CMD                        | Shortened     | Uitleg                                |
| -------------------------- | ------------- | ------------------------------------- |
| (do) show running-config   | (do) sh run   | Volledige actieve config              |
| show ip interface brief    | sh ip int bri | Alle interfaces: status(up/down) + IP |
| (do) show vlan brief       | sh vl bri     | Welke VLANs & Ports bestaan.          |
| (do) show interface status | sh int stat   | kabel connected? + welke VLAN         |
| (do) show interface trunk  | sh int tr     | Active trunks + Allowed VLANs         |
| show etherchannel summary  | sh eth sum    | EtherChannel status (SU = goed!)      |
| show spanning-tree         | sh span       | STP status per VLAN                   |
| show ip route(L3 sw only)  | sh ip ro      |                                       |
| examples:                  |               |                                       |
| sh int f0/6 switchport     |               | not in list? inactive vlan?           |
| sh int g0/1.30             |               | correct Vlan ID? encap.. dot1Q xx     |
| default int f0/10          |               | reset switchport                      |
|                            |               |                                       |

> **EtherChannel status letters:**
> - `SU` = Switch, In Use → **goed!**
> - `SD` = Switch, Down → probleem
> - `P` achter poorten = in use → goed

### Router 

| CMD                              | **Shortened    | Uitleg                                                                              |
| -------------------------------- | -------------- | ----------------------------------------------------------------------------------- |
| show running-config (int g0/0/0) | sh run         | Volledige actieve config (check subinterfaces/crypto keys).                         |
| show ip interface brief          | sh ip int bri  | (sub)interfaces: IP-adres + status (`Status` = fysiek, `Protocol` = data).          |
| show ip protocols                | sh ip prot     | Welke routing (OSPF 10) draait er? Welke netwerken adverteer je?                    |
| show ip route (ospf)             | sh ip ro       | **De routeringstabel.** Zie je de `O` (OSPF) en `C` (Connected) routes?             |
| show ip ospf neighbor            | sh ip ospf nei | OSPF-buren. Staat de status op **`FULL`**? (0 pt als het op _2-WAY_ blijft hangen). |
| show ip ospf interface brief     | sh ip ospf int | Check de OSPF-timers (Hello/Dead) en de handmatige **Cost** van een poort.          |
| show ip nat translations         | sh ip nat tra  | Actieve NAT/PAT-vertalingen. Zie je hier niets? Dan pingen de clients niet.         |
| show access-lists                | sh acc         | Toont alle ACL's inclusief de **'matches' tellers** (bewijs dat de ACL werkt!).     |
| show standby brief               | sh stan bri    | **HSRP status.** Is deze specifieke router nu `Active`, `Standby` of `Listen`?      |
| show interfaces trunk            | sh int tr      | lists ports & trunks & vlans allowed.                                               |
| sh spanning-tree vlan 1          |                |                                                                                     |

#### Belangrijke Router status-details

##### 1. Interface Status: Up / Down vs. Administratively Down
Als je `sh ip int bri` typt, kijk dan goed naar de `Status` kolom:
- **`Status: up / Protocol: up`** $\rightarrow$ Alles is perfect.
- **`Status: down / Protocol: down`** $\rightarrow$ Er zit geen kabel in, of de kabel zit in de verkeerde poort.
- **`Status: administratively down / Protocol: down`** $\rightarrow$ Je bent vergeten **`no shutdown`** te typen op die poort!
##### 2. OSPF Neighbor status letters:
- **`FULL / -`** $\rightarrow$ Gevormd op een Point-to-Point link (seriële link of direct tussen twee routers). Dit is **goed**.
- **`FULL / DR`** of **`FULL / BDR`** $\rightarrow$ Gevormd op een gedeeld netwerk (via een switch). Dit is **goed**.
- **`2-WAY / DROTHER`** $\rightarrow$ Dit betekent dat twee routers die geen DR of BDR zijn met elkaar praten. Dit is normaal op een switch-netwerk met _meer_ dan twee routers, maar ze wisselen dan **geen** routing-tabellen met elkaar uit.
##### 3. NAT Tabel kolommen:
- **`Inside local`** $\rightarrow$ Het échte, private IP-adres van je PC in het LAN (bijv. `192.168.1.10`).
- **`Inside global`** $\rightarrow$ Het publieke IP-adres waarnaar je PC zojuist is vertaald op het internet (bijv. je WAN-interface IP).

### Output filters | pipelines

| CMD                                 | Info                  |
| ----------------------------------- | --------------------- |
| sh run \| section VTY               | shows entire section  |
| sh ip int bri \| include UP         | show lines w/ keyw    |
| sh ip int bri \| exclude UNASSIGNED | filter out keyw lines |
| sh ip route \| begin GATEWAY        | start at keyword      |
>Can be used with any show cmd, keywords case sensitive!
>search multiple strings with | like: **sh int | include Desc|conn**


#### Swap wrong Vlans
! --- Stap 1: Haal VLAN 30 weg bij subinterface .10 --- 
interface g0/1.10 
 encapsulation dot1Q 999 
exit 
! --- Stap 2: Nu is VLAN 30 vrij! Zet hem direct goed op .30 --- 
interface g0/1.30 
 encapsulation dot1Q 30 
exit 
! --- Stap 3: Zet nu ook VLAN 10 netjes op de .10 interface --- 
interface g0/1.10 
 encapsulation dot1Q 10 
exit

#### Trunk allow fix
interface f0/1
 switchport trunk allowed vlan 3,4,8,13
! -- expleciet is beter dan all:
interface f0/1
 switchport trunk allowed vlan all
 switchport trunk allowed vlan remove 7