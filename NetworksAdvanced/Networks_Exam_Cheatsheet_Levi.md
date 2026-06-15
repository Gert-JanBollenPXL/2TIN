___
# DEEL 1: SWITCH — LAN CONFIGURATIE

## Gouden Regel: Volgorde op een Switch

```
1. Identiteit + SSH
2. VLAN Database aanmaken
3. Spanning Tree instellen
4. EtherChannels (LAG) configureren
5. Trunk poorten instellen
6. Access poorten instellen
7. Management IP (SVI) + Default Gateway
8. Controleren!
```

---

## Stap 1 — Identiteit & SSH

SSH werkt NIET zonder hostname én domain-name. Altijd als eerste doen.

```
SW(config)# hostname LAB-SW01
SW(config)# ip domain name data.labnet.local
SW(config)# service password-encryption          ! versleutelt alle wachtwoorden
SW(config)# enable secret cisco                  ! privileged exec wachtwoord
SW(config)# username student privilege 15 secret pxl
SW(config)# crypto key generate rsa              ! kies 1024 bits
SW(config)# ip ssh version 2

SW(config)# line vty 0 15
SW(config-line)# login local
SW(config-line)# transport input ssh             ! alleen SSH, geen Telnet
SW(config-line)# exit
```

> ⚠️ **Examen tip:** Als ze vragen om SSH te configureren, vergeet `ip ssh version 2` niet.
> Als ze vragen om vanuit een specifiek subnet te SSHen → ACL op de VTY lines:
> `SW(config-line)# access-class 10 in`

---

## Stap 2 — VLAN Database

VLANs bestaan pas écht als je ze aanmaakt. Zonder dit begrijpt de switch het verkeer niet.

```
SW(config)# vlan 10
SW(config-vlan)# name Management
SW(config)# vlan 20
SW(config-vlan)# name Data_Users
SW(config)# vlan 30
SW(config-vlan)# name Voice_Users
SW(config)# vlan 99
SW(config-vlan)# name Native
SW(config-vlan)# exit
```

> 💡 **Native VLAN:** Dit is de VLAN die NIET getagged wordt over een trunk. Default = VLAN 1.
> Best practice: verander naar een ongebruikte VLAN (bv. 99). Beide kanten van de trunk moeten dezelfde native VLAN hebben!

---

## Stap 3 — Spanning Tree Protocol (STP)

**Waarom?** Voorkomt lussen in het netwerk bij redundante verbindingen.

```
SW(config)# spanning-tree mode rapid-pvst        ! snellere versie van STP
SW(config)# spanning-tree extend system-id

! SW1 = Primary Root (laagste bridge priority → wint verkiezingen)
SW1(config)# spanning-tree vlan 10,20,30,99 root primary

! SW2 = Secondary Root (backup)
SW2(config)# spanning-tree vlan 10,20,30,99 root secondary
```

> 💡 **Hoe werkt STP?**
> - Laagste **Bridge ID** (priority + MAC) wint → wordt Root Bridge
> - `root primary` stelt priority in op 24576 (of lager dan huidige root)
> - `root secondary` stelt priority in op 28672
> - Poorten: Root Port (RP), Designated Port (DP), Blocked Port

> ⚠️ **PortFast** — Gebruik op access poorten (eindapparaten, geen switches!):
> ```
> SW(config-if)# spanning-tree portfast
> ```
> PortFast slaat de STP luister/learn fase over → apparaat verbindt onmiddellijk.

---

## Stap 4 — EtherChannel (LAG / Port-Channel)

**Waarom?** Meerdere fysieke kabels bundelen tot één logische link → meer bandbreedte + redundantie.

### LACP Modes (de meest gebruikte):
| Mode | Gedrag |
|------|--------|
| `active` | Stuurt LACP packets, wil bundelen |
| `passive` | Wacht op LACP packets, bundelt als andere kant `active` is |
| `on` | Forceert bundeling, geen onderhandeling (beide kanten moeten `on` zijn) |

> ⚠️ Minstens één kant moet `active` zijn. Twee `passive` kanten = geen EtherChannel!

```
! Fysieke poorten configureren
SW(config)# interface range GigabitEthernet1/0/1 - 2
SW(config-if-range)# channel-group 1 mode active     ! of passive
SW(config-if-range)# no shutdown
SW(config-if-range)# exit

! Logische Port-Channel interface configureren
SW(config)# interface port-channel 1
SW(config-if)# description LAG-TO-SW02
SW(config-if)# switchport mode trunk
SW(config-if)# switchport trunk native vlan 99
SW(config-if)# switchport trunk allowed vlan 10,20,30,99
SW(config-if)# exit
```

> ⚠️ **Belangrijk:** Configureer trunking op de **port-channel interface**, niet op de individuele poorten!

---

## Stap 5 — Trunk Poorten

**Waarom?** Een trunk stuurt verkeer van MEERDERE VLANs over één kabel (met 802.1Q tags).

```
! Rechtstreekse trunk (geen EtherChannel)
SW(config)# interface GigabitEthernet0/1
SW(config-if)# switchport mode trunk
SW(config-if)# switchport trunk native vlan 99
SW(config-if)# switchport trunk allowed vlan 10,20,30,99
SW(config-if)# no shutdown
SW(config-if)# exit
```

---

## Stap 6 — Access Poorten (Eindapparaten)

**Waarom?** Een access poort hoort bij exact één VLAN. Hier sluit je PC's, printers, IP-telefoons op aan.

```
SW(config)# interface GigabitEthernet1/0/5
SW(config-if)# switchport mode access
SW(config-if)# switchport access vlan 20         ! Data VLAN
SW(config-if)# spanning-tree portfast            ! Eindapparaat → PortFast aan
SW(config-if)# no shutdown
SW(config-if)# exit
```

> 💡 **Voice VLAN** (IP-telefoon + PC op zelfde poort):
> ```
> SW(config-if)# switchport mode access
> SW(config-if)# switchport access vlan 20        ! data voor PC
> SW(config-if)# switchport voice vlan 30         ! voice voor telefoon
> SW(config-if)# spanning-tree portfast
> ```

---

## Stap 7 — Management SVI + Default Gateway

**SVI = Switch Virtual Interface** — een virtuele "poort" op de switch met een IP-adres.

```
SW(config)# interface vlan 10                    ! Management VLAN
SW(config-if)# description Management_Interface
SW(config-if)# ip address 172.17.1.2 255.255.255.0
SW(config-if)# no shutdown
SW(config-if)# exit

SW(config)# ip default-gateway 172.17.1.1        ! IP van de router
SW(config)# ntp server 10.199.64.66              ! tijd synchroniseren
```

---

## Stap 8 — Switch Controleren

```
SW# show ip interface brief                      ! Alle interfaces: status + IP
SW# show vlan brief                              ! Welke VLANs & Ports bestaan.
SW# show interfaces trunk                        ! Active trunks + Allowed VLANs
SW# show etherchannel summary                    ! EtherChannel status (SU = goed!)
SW# show spanning-tree                           ! STP status per VLAN
SW# show running-config                          ! Volledige actieve config
```

> 💡 **EtherChannel status letters:**
> - `SU` = Switch, In Use → **goed!**
> - `SD` = Switch, Down → probleem
> - `P` achter poorten = in use → goed

---

# DEEL 2: ROUTER — INTER-VLAN ROUTING (Router-on-a-Stick)

**Waarom?** Apparaten in VLAN 10 kunnen niet direct praten met VLAN 20 — de switch kent geen routing. Een router met sub-interfaces lost dit op.

## Architectuur

```
PC (VLAN 10) ──► Switch (trunk) ──► Router sub-interfaces ──► Switch (trunk) ──► PC (VLAN 20)
```

## Switch-kant: Trunk naar de router

```
SW(config)# interface GigabitEthernet0/1         ! poort richting router
SW(config-if)# switchport mode trunk
SW(config-if)# switchport trunk native vlan 99
SW(config-if)# switchport trunk allowed vlan 10,20,30,99
SW(config-if)# no shutdown
SW(config-if)# exit
```

## Router-kant: Sub-interfaces

```
! Hoofdinterface aan — GEEN ip address hierop!
RTR(config)# interface GigabitEthernet0/0/0
RTR(config-if)# no shutdown
RTR(config-if)# exit

! Sub-interface voor VLAN 10
RTR(config)# interface GigabitEthernet0/0/0.10
RTR(config-subif)# encapsulation dot1Q 10         ! zegt welke VLAN-tag dit is
RTR(config-subif)# ip address 172.17.10.1 255.255.255.0

! Sub-interface voor VLAN 20
RTR(config)# interface GigabitEthernet0/0/0.20
RTR(config-subif)# encapsulation dot1Q 20
RTR(config-subif)# ip address 172.17.20.1 255.255.255.0

! Native VLAN (geen tag!)
RTR(config)# interface GigabitEthernet0/0/0.99
RTR(config-subif)# encapsulation dot1Q 99 native  ! "native" = geen tag
RTR(config-subif)# exit
```

> ⚠️ **VLAN nummer in encapsulation moet overeenkomen met sub-interface nummer!**
> `.10` → `encapsulation dot1Q 10` ✅

> 💡 **Gateway voor clients:** Elk apparaat in VLAN 10 gebruikt `172.17.10.1` als default gateway.

---

# DEEL 3: ROUTERING

## 3.1 Statische Routering

**Wanneer:** Kleine netwerken, of als je exact wil bepalen welk pad verkeer neemt.

### Syntaxis:
```
RTR(config)# ip route [bestemmingsnetwerk] [subnetmask] [next-hop IP of exit-interface]
```

### Voorbeelden:
```
! Via next-hop IP (meest gebruikt in PT)
RTR(config)# ip route 192.168.2.0 255.255.255.0 10.0.0.2

! Via exit-interface (point-to-point verbindingen)
RTR(config)# ip route 192.168.2.0 255.255.255.0 Serial0/1/0

! Default route (als niets anders matched → stuur hiernaartoe)
RTR(config)# ip route 0.0.0.0 0.0.0.0 10.0.0.1
```

> 💡 **Default route** = de "stuur maar naar de ISP" route. Altijd `0.0.0.0 0.0.0.0`.

```
RTR# show ip route                               ! Routetabel bekijken
! S = Static, C = Connected, O = OSPF, * = candidate default
```

---

## 3.2 OSPF — Dynamische Routering

**Waarom?** Routers delen automatisch hun routing info. Bij wijzigingen past het netwerk zich aan.

### OSPF Basisconfig — Methode 1: Network Statements

```
RTR(config)# router ospf 10                      ! process-id (lokaal, hoeft niet te matchen!)
RTR(config-router)# router-id 1.1.1.1            ! Uniek ID per router (best practice)
RTR(config-router)# network 192.168.1.0 0.0.0.255 area 0
RTR(config-router)# network 10.0.0.0 0.0.0.3 area 0
RTR(config-router)# end
```

### OSPF Basisconfig — Methode 2: Interface-niveau

```
RTR(config)# router ospf 10
RTR(config-router)# router-id 1.1.1.1
RTR(config-router)# exit

RTR(config)# interface GigabitEthernet0/0/0
RTR(config-if)# ip ospf 10 area 0               ! OSPF activeren op interface
RTR(config)# interface Serial0/1/0
RTR(config-if)# ip ospf 10 area 0
```

> ⚠️ **Examen:** Beide methodes kunnen gevraagd worden! Lees de vraag goed.
> - "Activate OSPF using network statements" → Methode 1
> - "Activate OSPF by configuring the interfaces" → Methode 2

### Wildcard Masks (voor network statements)

Wildcard = **omgekeerde subnetmask**. Bit `0` = match, bit `1` = negeer.

| Subnet | Subnetmask | Wildcard |
|--------|-----------|----------|
| /24 | 255.255.255.0 | 0.0.0.255 |
| /25 | 255.255.255.128 | 0.0.0.127 |
| /26 | 255.255.255.192 | 0.0.0.63 |
| /27 | 255.255.255.224 | 0.0.0.31 |
| /28 | 255.255.255.240 | 0.0.0.15 |
| /30 | 255.255.255.252 | 0.0.0.3 |
| /32 (host) | 255.255.255.255 | 0.0.0.0 |

> 💡 **Truc:** 255 - subnetmask octet = wildcard octet
> Voorbeeld: /28 → 255 - 240 = 15 → wildcard = 0.0.0.15

### Passive Interfaces

**Waarom?** Voorkomen dat OSPF hello-packets gestuurd worden naar eindapparaten (nutteloos).

```
RTR(config)# router ospf 10
RTR(config-router)# passive-interface GigabitEthernet0/0/0   ! specifieke interface
RTR(config-router)# passive-interface loopback 0              ! loopbacks altijd passief!

! OF: maak alles passief, activeer dan enkel de nodige
RTR(config-router)# passive-interface default
RTR(config-router)# no passive-interface Serial0/1/0          ! dit is actief
```

### Default Route via OSPF propageren

```
! Op de router met internet-toegang:
RTR(config)# ip route 0.0.0.0 0.0.0.0 [ISP-IP]              ! statische default route
RTR(config)# router ospf 10
RTR(config-router)# default-information originate             ! stuur naar OSPF neighbors
```

> 💡 In de routetabel van andere routers verschijnt dit als `O*E2` (external type 2)

### OSPF Fine-tuning

```
! Bandbreedte referentie aanpassen (ALTIJD doen voor moderne netwerken!)
RTR(config)# router ospf 10
RTR(config-router)# auto-cost reference-bandwidth 10000       ! 10 Gbps als referentie

! Handmatige cost instellen op een interface
RTR(config-if)# ip ospf cost 30

! Hello/Dead timers (beide kanten MOETEN gelijk zijn!)
RTR(config-if)# ip ospf hello-interval 10                    ! default = 10 sec
RTR(config-if)# ip ospf dead-interval 40                     ! default = 4x hello

! Point-to-Point → geen DR/BDR verkiezing nodig
RTR(config-if)# ip ospf network point-to-point
```

### OSPF Controleren & Troubleshoot

```
RTR# show ip ospf neighbor                       ! Neighbors zien? → OSPF werkt
RTR# show ip route ospf                          ! Enkel OSPF routes
RTR# show ip route                               ! Volledige routetabel
RTR# show ip protocols                           ! OSPF process info + networks
RTR# show ip ospf                                ! Process details
RTR# show ip ospf interface [int]               ! OSPF op interface (hello timers etc.)
RTR# show ip interface brief                     ! Interface status
```

### OSPF Troubleshoot Checklist

| Probleem | Controleer |
|----------|-----------|
| Geen neighbors | Is OSPF geactiveerd op de interface? Zelfde area? Zelfde subnet? |
| Neighbor instabiel | Hello/Dead timers gelijk aan beide kanten? |
| Route ontbreekt | Juist network statement? Juiste wildcard? Interface up? |
| Hoge cost | `auto-cost reference-bandwidth` ingesteld? |

---

# DEEL 4: ACL — ACCESS CONTROL LISTS

**Wat is een ACL?** Een sequentiële lijst van regels die verkeer filtert op basis van IP-adressen (en poorten). Wordt op een router-interface toegepast.

## Kernregels — Nooit vergeten!

1. **Eerste match wint** — Volgorde is cruciaal!
2. **Implicit deny all** — Aan het einde staat altijd een onzichtbare `deny any`. Geen match = geblokkeerd!
3. **ACL wordt toegepast op een interface** met richting: `in` (binnenkomend) of `out` (uitgaand)

## Soorten ACLs

| Type | Nummers | Filtert op | Beste positie |
|------|---------|-----------|---------------|
| **Standard** | 1-99, 1300-1999 | Alleen **bron-IP** | Zo dicht mogelijk bij **bestemming** |
| **Extended** | 100-199, 2000-2699 | Bron + Bestemming + Protocol + Poort | Zo dicht mogelijk bij **bron** |

> 💡 **Ezelsbruggetje:**
> - Standard = Simpel = alleen Source = dicht bij bestemming (anders blokkeer je te veel)
> - Extended = Exact = alles specificeren = dicht bij source (blokkeer vroeg)

## Standard ACL

```
! Numbered standard ACL
RTR(config)# access-list 10 permit 192.168.1.0 0.0.0.255     ! permit subnet
RTR(config)# access-list 10 permit host 192.168.2.5           ! permit één host
RTR(config)# access-list 10 deny any                          ! expliciet deny (anders vergeet je het)

! Named standard ACL (beter leesbaar)
RTR(config)# ip access-list standard BLOCK_GUEST
RTR(config-std-nacl)# deny 192.168.99.0 0.0.0.255
RTR(config-std-nacl)# permit any
RTR(config-std-nacl)# exit

! Toepassen op interface
RTR(config)# interface GigabitEthernet0/0/0
RTR(config-if)# ip access-group 10 out                        ! of "in"
RTR(config-if)# exit
```

## Extended ACL

```
! Syntaxis:
! access-list [nr] [permit/deny] [protocol] [src] [wildcard] [dst] [wildcard] [operator poort]

! Voorbeeld: blokkeer HTTP van subnet 10.1.1.0/24 naar server 10.2.2.5
RTR(config)# access-list 110 deny tcp 10.1.1.0 0.0.0.255 host 10.2.2.5 eq 80
RTR(config)# access-list 110 deny tcp 10.1.1.0 0.0.0.255 host 10.2.2.5 eq 443
RTR(config)# access-list 110 permit ip any any               
! rest permitten!

! Voorbeeld: sta alleen SSH toe naar een beheernetwerk
RTR(config)# access-list 120 permit tcp any host 172.16.1.1 eq 22
RTR(config)# access-list 120 deny ip any any

! Named extended ACL
RTR(config)# ip access-list extended NO_TELNET
RTR(config-ext-nacl)# deny tcp any any eq 23
RTR(config-ext-nacl)# permit ip any any
RTR(config-ext-nacl)# exit

! Toepassen op interface
RTR(config)# interface GigabitEthernet0/0/1
RTR(config-if)# ip access-group NO_TELNET in
```

## ACL Keywords — Cheatsheet

| Keyword | Betekenis | Wildcard equivalent |
|---------|-----------|-------------------|
| `host 192.168.1.5` | Exact één IP | `192.168.1.5 0.0.0.0` |
| `any` | Elk IP | `0.0.0.0 255.255.255.255` |

## Poorten — Meest voorkomend

| Service | Protocol | Poort |
|---------|---------|-------|
| HTTP | tcp | 80 |
| HTTPS | tcp | 443 |
| SSH | tcp | 22 |
| Telnet | tcp | 23 |
| FTP | tcp | 20/21 |
| DNS | udp/tcp | 53 |
| DHCP | udp | 67/68 |
| SNMP | udp | 161 |

## ACL op VTY Lines (SSH beheer beperken)

```
RTR(config)# access-list 5 permit 172.16.1.0 0.0.0.255      
! alleen dit subnet mag SSH
RTR(config)# line vty 0 4
RTR(config-line)# access-class 5 in                          
! "access-class" ipv "access-group"!
```

> ⚠️ **VTY lines gebruiken `access-class`, interfaces gebruiken `access-group`!**

## ACL Controleren

```
RTR# show ip access-lists                        ! Alle ACLs + match-tellers
RTR# show ip access-lists 110                    ! Specifieke ACL
RTR# show running-config | include access        ! Snel ACLs in config vinden
RTR# show ip interface GigabitEthernet0/0/0      ! Welke ACL op welke interface
```

> 💡 **Tellers resetten:** `RTR# clear ip access-list counters`

---

# DEEL 5: NAT EN PAT

**Waarom NAT/PAT?** Privé-IP adressen (RFC 1918) zijn niet routeerbaar op het internet. NAT vertaalt privé → publiek.

## Concepten

| Term | Betekenis |
|------|-----------|
| **Inside Local** | Privé IP van intern apparaat |
| **Inside Global** | Publiek IP na vertaling |
| **Outside Local** | IP van server zoals intern gezien |
| **Outside Global** | Echt IP van server op internet |
| `ip nat inside` | Zet op interface richting intern netwerk |
| `ip nat outside` | Zet op interface richting internet/ISP |

## Soorten NAT

| Type | Wanneer | Config |
|------|---------|--------|
| **Static NAT** | 1 privé ↔ 1 publiek (bv. server) | `ip nat inside source static` |
| **Dynamic NAT** | Pool van publieke IPs, first-come | Access-list + pool |
| **PAT (Overload)** | Veel privé → 1 publiek IP (meest gebruikt!) | Pool of interface |

---

## Static NAT (één-op-één)

```
! Router interfaces labelen
RTR(config)# interface GigabitEthernet0/0/0       ! richting intern netwerk
RTR(config-if)# ip nat inside
RTR(config-if)# exit

RTR(config)# interface GigabitEthernet0/0/1       ! richting ISP/internet
RTR(config-if)# ip nat outside
RTR(config-if)# exit

! Statische mapping
RTR(config)# ip nat inside source static 192.168.1.10 203.0.113.5
!                                          ^ privé IP      ^ publiek IP
```

---

## Dynamic NAT (met pool)

```
! Stap 1: Definieer welke interne IPs vertaald worden (ACL)
RTR(config)# access-list 1 permit 192.168.1.0 0.0.0.255

! Stap 2: Maak een pool van publieke IPs
RTR(config)# ip nat pool MYPOOL 203.0.113.10 203.0.113.20 netmask 255.255.255.0
!                         ^ naam  ^ eerste IP     ^ laatste IP

! Stap 3: Koppel ACL aan pool
RTR(config)# ip nat inside source list 1 pool MYPOOL

! Stap 4: Interfaces labelen (zelfde als static NAT)
RTR(config)# interface GigabitEthernet0/0/0
RTR(config-if)# ip nat inside
RTR(config)# interface GigabitEthernet0/0/1
RTR(config-if)# ip nat outside
```

---

## PAT — Port Address Translation (Overload) ⭐

**Dit is wat thuis-routers doen.** Veel apparaten → 1 publiek IP, via poortnummers onderscheiden.

### PAT via interface (meest eenvoudig):

```
! ACL: welke interne IPs mogen?
RTR(config)# access-list 1 permit 192.168.0.0 0.0.0.255

! PAT met het IP van de outside interface zelf
RTR(config)# ip nat inside source list 1 interface GigabitEthernet0/0/1 overload
!                                                                         ^ "overload" = PAT!

! Interfaces labelen
RTR(config)# interface GigabitEthernet0/0/0
RTR(config-if)# ip nat inside
RTR(config)# interface GigabitEthernet0/0/1
RTR(config-if)# ip nat outside
```

### PAT via pool:

```
RTR(config)# access-list 1 permit 192.168.0.0 0.0.0.255
RTR(config)# ip nat pool PATPOOL 203.0.113.5 203.0.113.5 netmask 255.255.255.248
RTR(config)# ip nat inside source list 1 pool PATPOOL overload  ! "overload" = PAT
```

> 💡 **Verschil Dynamic NAT vs PAT:**
> - Dynamic NAT: 1 intern apparaat = 1 publiek IP (uit pool) → pool raakt op
> - PAT: Alle apparaten delen 1 publiek IP, poortnummers maken het uniek → pool raakt nooit op

---

## NAT Controleren & Troubleshoot

```
RTR# show ip nat translations                    ! Actieve vertalingen
RTR# show ip nat statistics                      ! Statistieken, interfaces
RTR# clear ip nat translation *                  ! Vertalingen wissen (voor testen)
RTR# debug ip nat                                ! Live NAT debug (ctrl+Z om te stoppen)
```

> ⚠️ **Meest voorkomende fouten:**
> 1. `ip nat inside` / `ip nat outside` vergeten op interfaces
> 2. ACL matcht niet (test met `show ip nat statistics`)
> 3. Pool subnet klopt niet met publieke IPs

---

# DEEL 6: THÉORIE TOPICS (MCQ)

## LAN Protocollen — Snelle Herhaling

| Concept | Wat is het? |
|---------|-------------|
| **VLAN** | Logische scheiding van netwerk op layer 2 |
| **802.1Q** | Standaard voor VLAN-tagging op trunks |
| **STP/RSTP** | Voorkomt lussen, kiest root bridge |
| **EtherChannel** | Bundeling van links (LACP = 802.3ad) |
| **Router-on-a-Stick** | Inter-VLAN routing via sub-interfaces |
| **SVI** | Virtuele interface op switch met IP |

## OSI Lagen — Wat filtert wat?

| Laag | Naam | Voorbeeld |
|------|------|---------|
| 2 | Data Link | Switch, MAC, VLANs, STP, QoS op switch |
| 3 | Network | Router, IP, OSPF, NAT, ACL |
| 4 | Transport | TCP/UDP, poorten, ACL extended |
| 7 | Application | Next-gen firewall, DNS, HTTP |

> 💡 **QoS in LAN = Laag 2** (op de switch, CoS bits in 802.1Q header)
> **Packet filtering ACL = Laag 3 en 4** (Standard = L3, Extended = L3+L4)

## Veelgestelde MCQ-Valkuilen

**OSPF:**
- Process-ID hoeft NIET te matchen tussen routers (is lokaal)
- Router-ID = hoogste loopback IP (of hoogste interface IP als geen loopback)
- Neighboring voorwaarden: zelfde area, zelfde hello/dead timers, zelfde subnet, zelfde network type
- `O*E2` in routetabel = default route gepropageerd via OSPF

**ACL:**
- Implicit deny = aan het einde staat altijd een onzichtbare `deny any`
- ACL zonder een `permit` = alles geblokkeerd!
- Volgorde is alles — meest specifieke regels eerst
- Standard ACL = dicht bij bestemming, Extended = dicht bij bron
- `access-class` voor VTY, `access-group` voor interfaces

**NAT/PAT:**
- PAT = `overload` keyword
- `ip nat inside` op interne interface, `ip nat outside` op externe
- Static NAT = server bereikbaar van buiten
- PAT = meest gebruikt in de echte wereld

**STP:**
- Root Bridge = laagste Bridge ID (priority, dan MAC)
- Root Port = poort op non-root switch dichtst bij root
- PortFast alleen op access poorten (eindapparaten)

## Afkortingen Cheatsheet

| Afkorting | Voluit |
|-----------|--------|
| OSPF | Open Shortest Path First |
| LACP | Link Aggregation Control Protocol |
| STP | Spanning Tree Protocol |
| RSTP | Rapid STP |
| ACL | Access Control List |
| NAT | Network Address Translation |
| PAT | Port Address Translation |
| SVI | Switch Virtual Interface |
| GRE | Generic Routing Encapsulation (non-secure site-to-site VPN) |
| MPLS | Multiprotocol Label Switching |
| CIR | Committed Information Rate |
| DSLAM | Digital Subscriber Line Access Multiplexer |
| WRED | Weighted Random Early Detection |

---

# DEEL 7: MASTER TROUBLESHOOT CHECKLIST

Gebruik dit in het Packet Tracer examen als iets niet werkt:

```
! Stap 1: Zijn de interfaces up?
show ip interface brief

! Stap 2: Routing correct?
show ip route

! Stap 3: OSPF neighbors gevonden?
show ip ospf neighbor

! Stap 4: VLANs correct?
show vlan brief

! Stap 5: Trunks correct?
show interfaces trunk

! Stap 6: EtherChannel werkt?
show etherchannel summary

! Stap 7: NAT vertalingen?
show ip nat translations

! Stap 8: ACL blokkeert iets?
show ip access-lists

! Stap 9: Volledige config bekijken
show running-config
```

## De "Ping werkt niet" Checklist

1. ✅ Interfaces `up/up`? (`show ip interface brief`)
2. ✅ Correct IP-adres op interface?
3. ✅ Route naar bestemming aanwezig? (`show ip route`)
4. ✅ ACL die blokkeert? (`show ip access-lists`)
5. ✅ NAT correct geconfigureerd? (`show ip nat translations`)
6. ✅ VLAN correct? Zit apparaat in juiste VLAN?
7. ✅ Default gateway op PC correct ingesteld?
8. ✅ Op switch: `no shutdown` op de SVI?

---

# SNELLE REFERENTIE — CONFIG SKELETONS

## Nieuw Packet Tracer project? Start hier:

### Switch basis (copy-paste en aanpassen):
```
hostname SW1
ip domain name lab.local
service password-encryption
enable secret cisco
username admin privilege 15 secret cisco
crypto key generate rsa
! → kies 1024
ip ssh version 2
line vty 0 15
 login local
 transport input ssh
!
spanning-tree mode rapid-pvst
spanning-tree extend system-id
```

### Router basis:
```
hostname RTR1
ip domain name lab.local
service password-encryption
enable secret cisco
username admin privilege 15 secret cisco
crypto key generate rsa
! → kies 1024
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
!
! Interfaces activeren niet vergeten:
interface GigabitEthernet0/0/0
 no shutdown
```

### OSPF snel:
```
router ospf 10
 router-id 1.1.1.1
 auto-cost reference-bandwidth 10000
 passive-interface loopback 0
 network [netwerk] [wildcard] area 0
```

### PAT snel (meest voorkomend):
```
access-list 1 permit [intern subnet] [wildcard]
ip nat inside source list 1 interface [outside int] overload
interface [inside int]
 ip nat inside
interface [outside int]
 ip nat outside
```

### Extended ACL snel:
```
ip access-list extended [NAAM]
 deny tcp [src] [wildcard] [dst] [wildcard] eq [poort]
 permit ip any any
interface [int]
 ip access-group [NAAM] in
```

---

> 📝 **Laatste tips voor het examen:**
> - Lees elke vraag twee keer — "network statements" vs "interface level" OSPF
> - Gebruik altijd het process-id dat gevraagd wordt
> - Implicit deny vergeten = meest voorkomende ACL-fout
> - `ip nat inside` / `ip nat outside` vergeten = NAT werkt niet
> - Bij twijfel over MCQ: altijd gokken (geen giscorrectie!)
