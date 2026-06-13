Networks Advanced
=================

# Table of contents

---

## 1. Switching routing and wireless essentials
### 1.1 Basic device configuration
#### 1.1.1 Switch boot sequence

- **Step 1**: POST (power-on self-test) is loaded (stored in ROM), it checks the CPU ssubsystem, DRAM and the portion of the flash device that makes up the flash filessystem
- **Step 2**: Boot loader software is loaded (stored in ROM)
- **Step 3**: Low-level CPU initialization is performed by the boot loader, it initializes CPU registers
- **Step 4**: Boot loader initializes the flash file system on the system board
- **Step 5**: Boot loader locates and loads a default IOS operating software image into memory and gives control over to the IOS

#### 1.1.1.2 Duplex communication

**Full-duplex** communication allows both ends of a connection to transmit and receive data simultaneously, also known as bidirectional communication.

**Half-duplex** communication is unidirectional and creates performance issues because data can flow in only one direction at a time, often resulting in collisions. These connections are typically seen in older hardware.

---

### 1.2 Switching concepts
#### 1.2.1 Frame forwarding

- **Ingress**: This is used to describe the port where a frame enters the device
- **Egress**: This is used to describe the port that frames will use when leaving the device

A LAN switch maintains a table that is referenced when forwarding traffic through the switch. The only intelligence of a LAN switch is its ability to forward traffic. It does this based on the ingress port and the destination MAC address of an ethernet frame. (note: an ethernet frame will never be forwarded out the same port which it was received on)

##### 1.2.1.1 The switch MAC address table

Switches use destination MAC addresses to direct network communications through the switch out the appropriate port, towards the destination. A switch populates its MAC address table by recording the source MAC address of each device connected to each of its ports.

##### 1.2.1.2 The switch learn and forward method

**Step 1: Learn**: every frame that enters a switch is checked for new information to learn (done by examining the source MAC address of the frame and port number where the frame entered the switch):

- If the source MAC address does not exist in the MAC address table, the MAC address and incoming port number are added to the table
- If the source MAC address does exist, the switch updates the refresh timer for that entry (default: entries are kept for 5 minutes)
- If the source MAC address exists in the table but on a different port, the switch treats this as a new entry and replaces the old entry using the same MAC address but with the more current port number

**Step 2: Forward**: if the destination MAC addres is a unicast address, the switch will look for a match between the destination MAC address of the frame and an entry in its MAC address table:

- If the destination MAC address is in the table, it will forward the frame out the specified port
- If the destination MAC address is not in the table, the switch will forward the frame out all ports except the incoming port (unknown unicast)
- If the destination MAC address is a broadcast or multicast, the frame is also flooded out all ports except the incoming port

##### 1.2.1.3 Switching forwarding methods

Switches make **layer 2** decisions very quickly, they use one of two methods to switch frames:

- **Store-and-forward switching**: a forwarding decision is made on a frame after the switch has received the entire frame and checked it for errors (primary LAN switching method)
    - **Error checking**: is done using comparing frame check sequence value of the frame with the switch's own FCS calculations
    - **Automatic buffering**: makes it possible to support any mix of ethernet speeds
- **Cut-through switching**: the forwarding process is started afer the destination MAC address of an incoming frame and the egress port have been determined

#### 1.2.2 Collision and broadcasst domains
##### 1.2.2.1 Collision domains

**Collision domain**: A network segment where devices share the same communication medium, so simultaneous transmissions can cause collisions.

- **Hub (legacy device)**: All connected devices share one collision domain, so collisions are common
- **Switch**: Each port is its own collision domain, reducing collisions
- **Full-duplex**: No collisions because devices can send and receive simultaneously
- **Half-duplex**: Collisions can occur because devices cannot send and receive at the same time

##### 1.2.2.2 Broadcast domains

**Broadcast domain**: A network segment where a Layer 2 broadcast sent by one device is received by all devices in that domain

- **Switches**: Forward broadcasts to all ports, so connected switches remain in the same broadcast domain
- **Routers**: Separate broadcast domains and do not forward Layer 2 broadcasts

Too many broadcasts can cause network congestion and reduce performance.

---

### 1.3 VLANs
#### 1.3.1 Overview
##### 1.3.1.1 VLAN definitions

A **VLAN** is a logical network that groups devices together regardless of their physical location, creating separate broadcast domains on the same switch infrastructure.

- Each VLAN acts as an independent network
- Devices in the same VLAN can communicate directly
- Devices in different VLANs require a router or Layer 3 device to communicate
- Broadcast traffic stays within the VLAN and is not sent to other VLANs
- VLANs improve security, management, and performance by reducing broadcast traffic

##### 1.3.1.2 Benefits of a VLAN design

| Benefit                   | Description                                                                     |
| ------------------------- | ------------------------------------------------------------------------------- |
| Smaller Broadcast Domains | Dividing the LAN reduces the number of broadcast domains.                       |
| Improved Security         | Only users in the same VLAN can communicate directly.                           |
| Improved IT Efficiency    | VLANs can group devices with similar requirements (e.g., faculty vs. students). |
| Reduced Cost              | One switch can support multiple groups or VLANs.                                |
| Better Performance        | Smaller broadcast domains reduce traffic and improve bandwidth utilization.     |
| Simpler Management        | Similar groups can share the same applications and network resources.           |

##### 1.3.1.3 Types of VLANs

**Default VLAN**: VLAN 1 is the default VLAN on a Cisco switch, this means:
- All ports are assigned to VLAN 1 by default (but can be configured to be on another VLAN after)
- The native VLAN is VLAN 1 by default
- The management VLAN is VLAN 2 by default
- VLAN 1 cannot be renamed or deleted

**Data VLAN**: Dedicated to user-generated traffic

**Native VLAN**: the VLAN that carries untagged traffic on an 802.1Q trunk link.
- VLAN traffic between switches is normally tagged with a VLAN ID
- Untagged traffic received on a trunk port is assigned to the native VLAN
- On Cisco switches, this is by default VLAN 1 (but can be changed)
- Best practice is to use an unused VLAN as the native VLAN instead of VLAN 1 for security reasons

**Management VLAN**: used for SSH/telnet VTY traffic and should not have end user trafic

#### 1.3.2 VLAN trunks
##### 1.3.2.1 Defining VLAN trunks

A VLAN trunk is a link that carries traffic for multiple VLANs between network devices, usually switches. A point-to-point link between 2 network devices.

- Uses IEEE 802.1Q tagging to identify VLAN traffic
- Allows the same VLAN to span multiple switches
- A trunk port does not belong to a single VLAN
- Carries traffic for multiple VLANs over one physical link
- Required for communication between devices in the same VLAN on different switches

Without VLANs, all devices connected to the switches will receive all unicast, multicast and broadcast traffic

##### 1.3.2.2 VLAN identification with a tag

802.1Q tagging adds VLAN information to Ethernet frames so they can travel across trunk links between switches.

- A 4-byte VLAN tag is inserted into the Ethernet frame
- The tag identifies which VLAN the frame belongs to
- Frames sent over trunk ports are typically tagged
- The switch recalculates the Frame Check Sequence (FCS) after adding the tag

#### 1.3.3 Dynamic trunking protocol

DTP (Dynamic Trunking Protocol) is a Cisco proprietary protocol that automatically negotiates whether a switch port should become a trunk link.

- Used to automatically establish trunk links between Cisco switches
- Operates only between devices that support DTP
- Default mode on many Cisco switches is 'dynamic auto'
- Non-Cisco devices generally do not support DTP
- DTP can be disabled using ``switchport nonegotiate``

---

### 1.4 Inter-VLAN routing
#### 1.4.1 Inter-VLAN routing operation
##### 1.4.1.1 What is inter-VLAN routing?

Inter-VLAN Routing is the process of routing traffic between different VLANs. Since VLANs are separate networks, devices in different VLANs cannot communicate directly.

- Requires a router or Layer 3 switch
- Enables communication between devices in different VLANs
- Each VLAN is treated as a separate network/subnet

| Method                    | Description                                                                                  |
| ------------------------- | -------------------------------------------------------------------------------------------- |
| Legacy Inter-VLAN Routing | Uses a separate router interface for each VLAN; not scalable                                 |
| Router-on-a-Stick         | Uses one router interface with multiple subinterfaces; suitable for small to medium networks |
| Layer 3 Switch (SVIs)     | Uses Switch Virtual Interfaces (SVIs); most scalable solution                                |

##### 1.4.1.2 Legacy inter-VLAN routing

Legacy Inter-VLAN Routing uses a router with a separate physical interface connected to each VLAN.

- Each router interface acts as the default gateway for a VLAN
- Requires one physical router interface per VLAN
- Not scalable because routers have a limited number of interfaces
- Considered a legacy solution and is rarely used today

##### 1.4.1.3 Router-on-a-stick inter-VLAN routing

Router-on-a-Stick is an inter-VLAN routing method that uses one physical router interface to route traffic between multiple VLANs.

- The router interface is configured as an 802.1Q trunk
- Multiple subinterfaces are created on the router, one for each VLAN
- Each subinterface has its own IP address and acts as the default gateway for its VLAN
- VLAN traffic is tagged and sent over a single physical link
- More scalable than Legacy Inter-VLAN Routing but less scalable than a Layer 3 switch

##### 1.4.1.4 Inter-VLAN routing on a layer 3 switch

A Layer 3 switch performs inter-VLAN routing using Switch Virtual Interfaces (SVIs), which are virtual interfaces assigned to VLANs.

- Each VLAN gets an SVI with its own IP address
- The SVI acts as the default gateway for devices in that VLAN
- Routing occurs directly on the switch, without an external router
- Provides faster and more scalable inter-VLAN routing than Router-on-a-Stick

---

### 1.5 STP concepts
#### 1.5.1 Purpose of STP
##### 1.5.1.1 Spanning tree protocol (STP)

**Spanning tree protocol** is a loop-prevention network protocol that allows for redundancy while creating a loop-free layer 2 topology.

STP compensates for a failure in the network by recalibrating and opening up previously blocked ports.

##### 1.5.1.2 Issues with redundant switch links

**Redundant links** provide backup paths in a network but they can create layer 2 **loops** (Frames circulate endlessly between switches) if not controlled. These loops occur when multiple active paths exist between switches and can cause:
- Broadcast storms (Excessive broadcast traffic that overwhelms the network)
- MAC address table instability (MAC addresses constantly change ports due to looping frames)
- Link saturization
- High CPU utilization
- Network outages

Unlike IP packets, ethernet frames have no TTL mechanism to stop endless looping. **Spanning tree protocol** prevents layer 2 looping by blocking redundant paths.

##### 1.5.1.3 The spanning tree algorithm

The Spanning Tree Algorithm (STA) is the algorithm used by STP to create a loop-free network topology.

- Selects one switch as the Root Bridge
- Determines the lowest-cost path from each switch to the Root Bridge
- Blocks redundant links that could create loops
- Ensures only one active path exists between network devices
- Recalculates paths and activates backup links if a link fails

| Concept            | Description                                       |
| ------------------ | ------------------------------------------------- |
| Root Bridge        | Central reference switch in the STP topology      |
| Least-Cost Path    | Best path from a switch to the Root Bridge        |
| Blocked Port       | Redundant port disabled to prevent loops          |
| Loop-Free Topology | Network with only one active path between devices |
| STP Recalculation  | Process of updating paths after a topology change |

#### 1.5.2 STP operations

STP uses the Spanning Tree Algorithm (STA) to create a loop-free network in four steps:

1. Elect the Root Bridge – Switch with the lowest Bridge ID (BID)
2. Elect Root Ports – Best path from each non-root switch to the Root Bridge
3. Elect Designated Ports – Ports allowed to forward traffic on each network segment
4. Elect Alternate (Blocked) Ports – Redundant ports placed in a blocking state to prevent loops

| Term               | Description                                                            |
| ------------------ | ---------------------------------------------------------------------- |
| BPDU               | Bridge Protocol Data Unit used by switches to exchange STP information |
| BID (Bridge ID)    | Value used to elect the Root Bridge                                    |
| Bridge Priority    | Part of the BID; lower value is preferred                              |
| Extended System ID | Identifies the VLAN associated with the BPDU                           |
| MAC Address        | Used as a tie-breaker when priorities are equal                        |
| Root Bridge        | Switch with the lowest BID                                             |
| Root Port          | Best path to the Root Bridge                                           |
| Designated Port    | Forwarding port for a network segment                                  |
| Alternate Port     | Blocked port that prevents loops                                       |

The Bridge ID (BID) is used by STP to elect the Root Bridge.

| Component          | Description                                                 |
| ------------------ | ----------------------------------------------------------- |
| Bridge Priority    | Configurable value; lower is preferred (default: **32768**) |
| Extended System ID | VLAN identifier added to the priority value                 |
| MAC Address        | Used as a tie-breaker when priorities are equal             |

STP selects the switch with the lowest BID as the Root Bridge.

Election order:

1. Lowest Bridge Priority
2. Lowest Extended System ID (if applicable)
3. Lowest MAC Address (tie-breaker)

| Item                    | Value                                  |
| ----------------------- | -------------------------------------- |
| Default Bridge Priority | 32768                                  |
| Priority Range          | 0 – 61440                              |
| Increment               | 4096                                   |
| Best Priority           | Lowest value (0 is highest preference) |

If multiple switches have the same Bridge Priority, STP elects the switch with the lowest MAC address as the Root Bridge. To control the election, configure a lower bridge priority on the desired Root Bridge.

##### 1.5.2.1 Root bridge selection

The Root Bridge is the central reference switch used by STP to build a loop-free topology.

- All switches participate in the election process
- Switches exchange BPDUs (Bridge Protocol Data Units)
- Initially, each switch considers itself the Root Bridge
- The switch with the lowest Bridge ID (BID) becomes the Root Bridge
- Once elected, all switches use the Root Bridge as the reference point for path calculations

##### 1.5.2.2 Elect the root ports

A Root Port (RP) is the port on a non-root switch that provides the lowest-cost path to the Root Bridge.

- Every non-root switch has one Root Port
- The Root Port is chosen based on the lowest root path cost
- Root path cost is the sum of all port costs along the path to the Root Bridge
- The path with the lowest cost is preferred

##### 1.5.2.3 Elect the designated ports

A Designated Port (DP) is the port on a network segment that has the best path to the Root Bridge.

- Each network segment has one Designated Port
- Designated Ports are placed in the forwarding state
- They forward traffic toward and away from the Root Bridge
- All ports on the root bridge are designated ports
- If one end of a segment is a root port, the other end is a designated port
- All ports attached to end devices are designated ports
- On segments between two switches where neither of the switches is the root bridge, the port on the switch with the least-cost path to the root bridge is a designated port

##### 1.5.2.4 Elect alternate (blocked) ports

An Alternate Port (or blocked port) is a redundant port that is not selected as a Root Port or Designated Port.

- Used as a backup path
- Placed in the blocking/discarding state
- Does not forward traffic
- Prevents Layer 2 loops
- Can become active if the primary path fails

##### 1.5.2.5 Elect a root port from multiple equal-cost paths

If a switch has multiple equal-cost paths to the Root Bridge, STP uses the following tie-breakers in order:
| Priority | Criteria                      |
| -------- | ----------------------------- |
| 1        | Lowest Sender BID (Bridge ID) |
| 2        | Lowest Sender Port Priority   |
| 3        | Lowest Sender Port ID         |

##### 1.5.2.6 STP timers and port states

STP uses three timers to control convergence and topology changes.

| Timer               | Default Value | Purpose                                              |
| ------------------- | ------------- | ---------------------------------------------------- |
| Hello Timer         | 2 seconds     | Time between BPDU messages                           |
| Forward Delay Timer | 15 seconds    | Time spent in Listening and Learning states          |
| Max Age Timer       | 20 seconds    | Time a switch waits before changing the STP topology |


STP port states:

| State      | Function                                           |
| ---------- | -------------------------------------------------- |
| Blocking   | Receives BPDUs but does not forward traffic        |
| Listening  | Processes BPDUs and determines port role           |
| Learning   | Learns MAC addresses but does not forward traffic  |
| Forwarding | Forwards traffic and learns MAC addresses          |
| Disabled   | Administratively down; does not participate in STP |

Port state transition:
Blocking → Listening → Learning → Forwarding

##### 1.5.2.7 Per-VLAN spanning tree (PVST)

PVST (Per-VLAN Spanning Tree) runs a separate STP instance for each VLAN.

- Each VLAN has its own Spanning Tree instance
- Each VLAN can have its own Root Bridge
- Allows different VLANs to use different optimal paths through the network
- Improves load balancing and network efficiency in multi-VLAN environments
- If only one VLAN exists, there is only one STP instance

#### 1.5.3 Evolution of STP
##### 1.5.3.1 RSTP concepts

RSTP (IEEE 802.1w) is an enhanced version of STP that provides much faster network convergence while maintaining compatibility with traditional STP.

- Uses the same basic spanning tree algorithm as STP
- Responds more quickly to network topology changes
- Can converge in milliseconds instead of the longer STP convergence times
- Alternate ports can transition to forwarding immediately when needed
- Cisco's per-VLAN implementation is called Rapid PVST+

##### 1.5.3.2 RSTP port states and port roles

RSTP implifies the STP port states from 5 to 3:

| STP State  | RSTP State |
| ---------- | ---------- |
| Disabled   | Discarding |
| Blocking   | Discarding |
| Listening  | Discarding |
| Learning   | Learning   |
| Forwarding | Forwarding |

RSTP keeps the STP root and designated port roles and adds 2 new roles:

| Port Role       | Description                                      |
| --------------- | ------------------------------------------------ |
| Root Port       | Best path to the Root Bridge                     |
| Designated Port | Forwarding port for a network segment            |
| Alternate Port  | Backup path to the Root Bridge                   |
| Backup Port     | Backup for a Designated Port on the same segment |

##### 1.5.3.3 Portfast and BPDU guard

**PortFast** allows a switch port to bypass the normal STP listening and learning states and immediately enter the forwarding state.

- Eliminates the normal 30-second STP delay
- Used on access ports connected to end devices
- Helps devices (e.g., DHCP clients) connect to the network immediately
- Should not be enabled on ports connected to other switches

**BPDU Guard** protects PortFast-enabled ports by disabling them if a BPDU is received.

- Used together with PortFast
- Detects if another switch is connected to an access port
- Places the port into an err-disabled state when a BPDU is received
- Prevents accidental Layer 2 loops and STP topology changes

---

### 1.6 Etherchannel
#### 1.6.1 Etherchannel operation

Link Aggregation combines multiple physical Ethernet links into a single logical link to increase bandwidth and provide redundancy.

- Implemented using EtherChannel
- Multiple physical links act as one logical connection
- Increases available bandwidth
- Provides redundancy and fault tolerance
- Prevents STP from blocking redundant links by treating them as a single link
- Commonly used between switches, routers, and servers

When an etherchannel is configured, the resulting virtual interface is called a port channel. The physical interfaces are bundled together into a port channel interface.

#### 1.6.2 Advantages of etherchannel

| Advantage                | Description                                                                   |
| ------------------------ | ----------------------------------------------------------------------------- |
| Simplified Configuration | Configure the Port Channel instead of each individual interface.              |
| Increased Bandwidth      | Combines multiple physical links into one logical link.                       |
| Load Balancing           | Traffic is distributed across member links.                                   |
| STP Efficiency           | STP treats the EtherChannel as a single logical link.                         |
| Redundancy               | If one physical link fails, the EtherChannel remains operational.             |
| No STP Recalculation     | Loss of a member link does not trigger STP topology changes.                  |
| Cost-Effective           | Increases bandwidth using existing interfaces without requiring faster links. |

#### 1.6.3 implementation restrictions

| Restriction              | Description                                                                                |
| ------------------------ | ------------------------------------------------------------------------------------------ |
| Same Interface Type      | Fast Ethernet and Gigabit Ethernet interfaces cannot be mixed.                             |
| Maximum Ports            | Up to 8 compatible ports per EtherChannel.                                                 |
| Consistent Configuration | All member ports must have the same settings on both ends.                                 |
| Matching Trunk Settings  | If configured as trunks, both sides must use the same trunk configuration and native VLAN. |
| Same Layer               | All member ports must be Layer 2 ports (for Layer 2 EtherChannels).                        |
| Port Channel             | Configuration applied to the Port Channel affects all member interfaces.                   |

---

### 1.7 DHCPv4
#### 1.7.1 DHCPv4 server and client

**DHCPv4** (Dynamic Host Configuration Protocol Version 4) automatically assigns IPv4 addresses and other network configuration information to devices on a network.

- Dynamically assigns IP addresses from a predefined address pool
- Provides configuration such as:
    - IP address
    - Subnet mask
    - Default gateway
    - DNS server
- Addresses are assigned as a lease for a specific period
- Eliminates the need to manually configure IP addresses on each device
- Can be provided by a dedicated DHCP server or a router

#### 1.7.2 DHCPv4 operation

DHCPv4 operates using a client-server model where a DHCP server leases IP addresses to clients.

- Clients request an IP address from the DHCP server
- The server assigns (leases) an IP address from its address pool
- The client uses the address until the lease expires
- The client periodically renews the lease
- When a lease expires and is not renewed, the address is returned to the pool for reassignment

#### 1.7.3 DHCP lease process

| Step | Message                       | Purpose                                     |
| ---- | ----------------------------- | ------------------------------------------- |
| 1    | DHCP Discover (DHCPDISCOVER)  | Client broadcasts to find DHCP servers      |
| 2    | DHCP Offer (DHCPOFFER)        | Server offers an available IP address       |
| 3    | DHCP Request (DHCPREQUEST)    | Client requests the offered address         |
| 4    | DHCP Acknowledgment (DHCPACK) | Server confirms the lease and configuration |

#### 1.7.4 DHCP lease renewal

Before a DHCP lease expires, the client renews it using a two-step process:
| Step | Message                       | Purpose                                      |
| ---- | ----------------------------- | -------------------------------------------- |
| 1    | DHCP Request (DHCPREQUEST)    | Client requests renewal of its current lease |
| 2    | DHCP Acknowledgment (DHCPACK) | Server approves and extends the lease        |

---

### 1.8 SLAAC and DHCPv6

We only briefly touched on IPv6 and barely used this so I am skipping it

---

### 1.9 FHRP concepts
#### 1.9.1 First hop redundancy protocols
##### 1.9.1.1 Default gateway limitations

A host can only be configured with one default gateway. If that gateway fails, the host loses access to external networks.

- Hosts rely on a single default gateway to reach remote networks
- If the gateway/router fails, traffic to other networks is dropped
- Hosts cannot automatically switch to a backup gateway
- First Hop Redundancy Protocols (FHRPs) provide gateway redundancy
- Layer 3 switches and routers can both serve as default gateways

**FHRP** provides a redundant default gateway so hosts can continue communicating if the primary gateway fails.

- Hosts normally use only one default gateway
- If that gateway becomes unavailable, hosts cannot reach external networks
- FHRP creates a virtual gateway shared by multiple routers or Layer 3 switches
- If the active gateway fails, a standby device automatically takes over
- Provides high availability and minimizes network downtime

##### 1.9.1.2 Router redundancy

**Router Redundancy** uses multiple routers (or Layer 3 switches) to provide a single, fault-tolerant default gateway for hosts.

- Multiple routers work together as a virtual router
- The virtual router has a virtual IP address and virtual MAC address
- Hosts use the virtual IP as their default gateway
- One router is active and forwards traffic
- One or more routers act as standby devices
- If the active router fails, a standby router automatically takes over
- The failover is transparent to end devices

##### 1.9.1.3 Steps for router failover

When the active router fails, the standby router automatically takes over the forwarding role.

Failover Steps:
- Standby router stops receiving Hello messages from the active router
- Standby router becomes the new active (forwarding) router
- The new active router assumes the virtual IP address and virtual MAC address
- Hosts continue using the same default gateway without any configuration changes
- Network connectivity is maintained with minimal disruption

##### 1.9.1.4 FHRP options

There are multiple options available for FHRPs, we will mostly talk about HSRP (hot standby router protocol), in the exercises I use vrrp (virtual router redundancy protocol).

#### 1.9.2 HSRP

**HSRP** is a Cisco proprietary First Hop Redundancy Protocol (FHRP) that provides a backup default gateway in case the primary router fails.

- Uses a virtual IP address as the default gateway for hosts
- Elects one router as the Active Router
- Elects another router as the Standby Router
- The Active Router forwards traffic
- The Standby Router monitors the Active Router and takes over if it fails
- Provides transparent failover with minimal disruption to users

##### 1.9.2.1 HSRP priority and preemption

HSRP Priority:
- Priority determines the Active Router
- Router with the highest HSRP priority becomes the Active Router
- Default HSRP priority = 100
- Priority range = 0–255
- If priorities are equal, the router with the highest IPv4 address wins

HSRP Preemption:
- By default, once a router becomes Active, it stays Active
- A higher-priority router coming online does not automatically take over
- Preemption allows a higher-priority router to reclaim the Active role when it returns

##### 1.9.2.2 HSRP states and timers

| State       | Description                                                                           |
| ----------- | ------------------------------------------------------------------------------------- |
| **Initial** | HSRP starts after configuration or when the interface becomes active.                 |
| **Learn**   | Router does not yet know the Virtual IP (VIP) and waits for Hello messages.           |
| **Listen**  | Router knows the VIP but is neither Active nor Standby. It listens for HSRP messages. |
| **Speak**   | Router sends Hello messages and participates in Active/Standby elections.             |
| **Standby** | Backup router that is ready to become Active if the Active router fails.              |
| **Active**  | Router currently forwarding traffic for the virtual gateway.                          |

| Timer           | Default Value | Purpose                                                               |
| --------------- | ------------- | --------------------------------------------------------------------- |
| **Hello Timer** | 3 seconds     | Interval between Hello messages.                                      |
| **Hold Timer**  | 10 seconds    | Time before declaring the Active router down if no Hello is received. |

Failover process:
1. Active router sends Hello messages every 3 seconds
2. Standby router monitors these messages
3. If no Hello is received for 10 seconds (Hold Timer), the Standby router becomes the new Active router

---

### 1.10 LAN security concepts
#### 1.10.1 Endpoint security

Endpoint Security:
- Endpoints (PCs, laptops, servers, IP phones) are common targets of malware attacks
- Best protection combines NAC, AMP, ESA, and WSA

Common Network Attacks:
- DDoS: Many devices overwhelm a service or website
- Data Breach: Unauthorized access to steal confidential data
- Malware: Malicious software such as ransomware

Security devices:
| Device     | Purpose                                   |
| ---------- | ----------------------------------------- |
| VPN Router | Secure remote access                      |
| NGFW (next generation firewall)       | Firewall with advanced threat protection  |
| NAC (network access control device)  | Controls and authenticates network access |
| ESA (email security appliance)        | Protects email traffic                    |
| WSA (web security appliance)        | Protects web traffic                      |

#### 1.10.2 AAA (authenticaiton, authorization, accounting)

| Component      | Function                   |
| -------------- | -------------------------- |
| Authentication | Verifies identity          |
| Authorization  | Determines allowed actions |
| Accounting     | Logs user activity         |

Authentication methods:
- **Local AAA**: User database stored on device
- **Server-based AAA**: Uses centralized RADIUS (Remote Authentication Dial-In User Service) or TACACS+ (Terminal Access Controller Access Control System) servers

#### 1.10.3 Layer 2 security threats

| Attack Type      | Description                      |
| ---------------- | -------------------------------- |
| MAC Table Attack | Floods switch MAC table          |
| VLAN Attack      | VLAN hopping / double-tagging    |
| DHCP Attack      | Starvation or spoofing           |
| ARP Attack       | Spoofing or poisoning            |
| Address Spoofing | Fake MAC/IP addresses            |
| STP Attack       | Manipulates root bridge election |

Layer 2 security solutions:

| Security Feature             | Protects Against               |
| ---------------------------- | ------------------------------ |
| Port Security                | MAC flooding, DHCP starvation  |
| DHCP Snooping                | DHCP starvation, DHCP spoofing |
| Dynamic ARP Inspection (DAI) | ARP spoofing, ARP poisoning    |
| IP Source Guard (IPSG)       | MAC/IP spoofing                |

#### 1.10.4 LAN attacks

**VLAN Hopping Attack**
- Attacker tricks a switch into forming a trunk connection
- Gains access to traffic from multiple VLANs
- Mitigation:
    - Disable trunking on access ports
    - Disable auto-trunking (DTP)
    - Use a dedicated native VLAN

**VLAN Double-Tagging Attack**
- Attacker inserts two VLAN tags
- Frame reaches a VLAN it should not access
- Works only when attacker is in the native VLAN
- Same mitigation as VLAN hopping

**DHCP Starvation**
- Attacker uses fake MAC addresses to consume all available IP leases
- Causes a DoS for legitimate clients
- Mitigation: DHCP Snooping

**DHCP Spoofing**
- Rogue DHCP server provides false network settings
- Can redirect traffic or create DoS conditions
- Mitigation: DHCP Snooping

**ARP Spoofing / Poisoning**
- Attacker sends fake ARP replies
- Victims associate attacker’s MAC address with a legitimate IP (often the gateway)
- Enables Man-in-the-Middle attacks
- Mitigation: Dynamic ARP Inspection (DAI)

**IP Spoofing**
- Attacker uses another device's IP address
- Mitigation: IP Source Guard (IPSG)

**MAC Spoofing**
- Attacker changes MAC address to impersonate another host
- Mitigation: IP Source Guard (IPSG)

**STP Attack**
- Attacker sends fake BPDUs claiming a lower bridge priority
- Becomes root bridge and can intercept traffic
- Mitigation: BPDU Guard on access ports

**CDP Reconnaissance**
- CDP broadcasts device information such as:
    - IP address
    - IOS version
    - Platform
    - Native VLAN
- Attackers can use this information for reconnaissance
- Mitigation: Disable CDP on untrusted ports (``no cdp enable``)

---

### 1.11 Switch security configuration

Mostly practical implementations of security features, we never used these in class except disabling unused ports.

---

### 1.12 WLAN concepts
#### 1.12.1 Introduction to wireless
##### 1.12.1.1 Benefits of wireless

A Wireless LAN (WLAN):

- Provides mobility
- Eliminates cabling requirements
- Adapts easily to changing environments
- Common in homes, businesses, and campuses

##### 1.12.1.2 Types of wireless networks

| Network | Standard    | Range           |
| ------- | ----------- | --------------- |
| WPAN    | IEEE 802.15 | 20–30 ft        |
| WLAN    | IEEE 802.11 | ~300 ft         |
| WMAN    | IEEE 802.16 | City-wide       |
| WWAN    | Cellular    | National/Global |

##### 1.12.1.3 Wireless technologies

**Bluetooth**
- IEEE 802.15
- WPAN
- Up to 100m
Variants:
- BLE (Bluetooth Low Energy)
- BR/EDR (audio streaming)

**WiMAX**
- IEEE 802.16
- Up to 50 km

**Cellular Broadband**
Uses:
- GSM
- CDMA

**Satellite Broadband**
- Requires line-of-sight
- Often used in rural areas

##### 1.12.1.4 802.11 standards & radio frequencies

These standards define how radio frequencies are used for wireless links. Most of the standards specify that wireless devices have one antenna to transmit and receive wireless signales on the specified radio frenquency (2.4 GHz or 5 GHz). Some of the newer standards that transmit and receive at higher speeds require access points and wireless clients to have multiple antennas using the multiple input and multiple ouput technology.

##### 1.12.1.5 Wireless standards organizations

**ITU (International Telecommunication Union)**
Responsible for:
- Radio spectrum allocation
- Satellite orbit regulation

**IEEE**
Creates wireless standards:
- 802.11
- 802.15
- 802.16

**Wi-Fi Alliance**
Ensures:
-Vendor interoperability
- Wi-Fi certification

#### 1.12.2 Antenna types

**Omnidirectional**
- 360° coverage
Used in:
- Homes
- Offices

**Directional**
- Focuses signal
Examples:
- Yagi
- Parabolic dish

**MIMO**
Uses multiple antennas (up to 8) to increase bandwidth

#### 1.12.3 WLAN operation

**Ad Hoc Mode**
- Peer-to-peer
- No AP required

**Infrastructure Mode**
- Clients connect through AP
- Most common WLAN topology

**Tethering**
- Smartphone acts as hotspot

##### 1.12.3.1 BSS and ESS

**BSS (Basic Service Set)**
- One AP
- Connected clients

**ESS (Extended Service Set)**
- Multiple APs
- Connected through wired distribution system
- Allows roaming

##### 1.12.3.2 CSMA/CA

Because WLANs are half-duplex and a client cannot "hear" while it is sending, it is impossible to detect collisions. Using CSMA/CA a wireless client does the following:

1. Listen
2. RTS (Ready To Send)
3. CTS (Clear To Send)
4. Wait random time if denied
5. Send data
6. Receive ACK

No ACK = Assume collision

##### 1.12.3.3 Wireless client and AP association

Wireless clients must:
- Discover AP
- Authenticate
- Associate

The client and AP must agree on:
- SSID (name of the network)
- Password (required for the client to authenticate to the AP)
- Network mode (802.11 standard being used)
- Security mode (WEP, WPA, WPA2)
- Channel settings (frequency bands in use)

##### 1.12.3.4 Passive vs active discovery

**Passive**
AP sends:
``Beacon Frames``

Containing:
- SSID
- Security settings
- Supported standards

**Active**
Client sends:
``Probe Request``

Searching for AP

#### 1.12.4 CAPWAP operation

Control and Provisioning of Wireless Access Points which enables a WLC to manage multiple APs and WLANs. It uses UDP ports 5246 and 5247 providing AP management and client traffic tunneling, it supports IPv4 and IPv6.

#### 1.12.5 Channel management

For the 2.4 GHz band each channel is 22MHz bandwidth and is seperated from the next channel by 5 MHz. The best non-overlapping channels are: 1, 6 and 11.

For the 5GHz band there are 24 channels where each channel is seperated from the next channel by 20MHz. Here the non-overlapping channels are: 36, 48 and 60.

#### 1.12.6 WLAN threats

**Interception of Data**:
Sniffing traffic

**Wireless Intruders**:
Unauthorized users

**DoS Attacks**:
Disrupt service

**Rogue APs**:
Unauthorized AP connected to network

Can be used to:
- Capture traffic
- Steal credentials
- Launch MITM attacks

Often created by:
- Unauthorized employee
- Personal hotspot

**Evil twin attack**:
Type of MITM attack, attacker creates AP with same SSID as legitimate AP, victims connect unknowingly

#### 1.12.7 WLAN security

**SSID cloaking**
- Hides SSID from beacon broadcasts
- Clients must manually enter SSID
- Provides only limited security

**MAC Address Filtering**
- Allows or denies devices based on MAC address
- Weak security because MACs can be spoofed

##### 1.12.7.1 Authentication methods

**Open Authentication**:
No password

Examples:
- Airport Wi-Fi
- Hotel Wi-Fi
- Cafés

**Shared Key Authentication**

Uses:
- WEP
- WPA
- WPA2
- WPA3

| Method | Encryption        | Status      |
| ------ | ----------------- | ----------- |
| WEP    | RC4               | Obsolete    |
| WPA    | TKIP              | Legacy      |
| WPA2   | AES               | Recommended |
| WPA3   | Enhanced Security | Best        |

---

### 1.13 WLAN configuration

This is the practical implementation of 1.12 so I will not be covering it here.

---

### 1.14 Routing Concepts
#### 1.14.1 Path Determination
##### 1.14.1.1 Two Functions of a Router

A router has two primary functions:

1. **Path Determination** – Determine the best path to a destination network.
2. **Packet Forwarding** – Forward packets toward that destination.

Routers use their routing table to make forwarding decisions.

##### 1.14.1.2 Longest Match

Routers select routes using the **longest prefix match** principle.

- Multiple routes may match a destination address
- The route with the most matching leftmost bits is selected
- The most specific route is always preferred

##### 1.14.1.3 Building the Routing Table

Routes can come from:

| Route Source       | Description                            |
| ------------------ | -------------------------------------- |
| Directly Connected | Network attached to a router interface |
| Static Route       | Manually configured route              |
| Dynamic Route      | Learned through a routing protocol     |
| Default Route      | Used when no specific route exists     |


#### 1.14.2 Packet Forwarding
##### 1.14.2.1 Packet Forwarding Process

When a router receives a packet:

1. Reads the destination IP address
2. Searches the routing table
3. Finds the longest matching route
4. Encapsulates the packet for the outgoing interface
5. Forwards the packet

If no route exists and no default route is configured, the packet is dropped.

##### 1.14.2.2 Forwarding Possibilities

A router can:

- Forward directly to a destination device
- Forward to a next-hop router
- Drop the packet

##### 1.14.2.3 Packet Forwarding Mechanisms

| Mechanism                      | Description                                               |
| ------------------------------ | --------------------------------------------------------- |
| Process Switching              | CPU processes every packet                                |
| Fast Switching                 | Uses a cache of previous forwarding decisions             |
| Cisco Express Forwarding (CEF) | Uses prebuilt forwarding tables and is the default method |

**CEF** is the fastest and most commonly used forwarding mechanism.

#### 1.14.3 IP Routing Table
##### 1.14.3.1 Route Sources

Common route sources:

| Code | Meaning   |
| ---- | --------- |
| L    | Local     |
| C    | Connected |
| S    | Static    |
| O    | OSPF      |

##### 1.14.3.2 Routing Table Principles

1. Every router makes forwarding decisions independently.
2. Routing tables on different routers may contain different information.
3. A route to a destination does not automatically provide a return path.

##### 1.14.3.3 Routing Table Entries

A routing table entry typically contains:

- Route source
- Destination network
- Administrative distance
- Metric
- Next-hop address
- Exit interface

##### 1.14.3.4 Administrative Distance (AD)

Administrative Distance measures the trustworthiness of a route source.

- Lower values are preferred.
- Used when multiple routing sources provide the same destination.

##### 1.14.3.5 Metric

A metric represents the cost of reaching a destination.

- Lower metrics are preferred.
- Different routing protocols calculate metrics differently.

##### 1.14.3.6 Directly Connected Routes

Directly connected routes are automatically added when:

- An interface is configured with an IP address.
- The interface is active.

##### 1.14.3.7 Static Routes

Static routes are manually configured.

**Advantages:**

- Simple
- Predictable
- Low overhead

**Disadvantages:**

- Require manual maintenance
- Do not automatically adapt to topology changes

##### 1.14.3.8 Dynamic Routing Protocols

Dynamic routing protocols automatically:

- Discover networks
- Exchange routing information
- Adapt to network changes

##### 1.14.3.9 Default Route

A default route is used when no more specific route exists.

It is often referred to as the **Gateway of Last Resort**.

---

### 1.15 IP Static Routing
#### 1.15.1 Static Routes
##### 1.15.1.1 Static Route Overview

A static route is a manually configured route that tells a router how to reach a specific destination network.

Static routes:

- Are configured by a network administrator
- Do not automatically adapt to network changes
- Can be used with IPv4 and IPv6
- Are commonly used in small or predictable networks

##### 1.15.1.2 Advantages of Static Routing

- Easy to understand
- No routing protocol overhead
- Improved security because routes are not advertised
- Predictable path selection

##### 1.15.1.3 Disadvantages of Static Routing

- Requires manual configuration
- Does not automatically recover from failures
- Difficult to manage in large networks

#### 1.15.2 Types of Static Routes
##### 1.15.2.1 Standard Static Route

A route manually configured to reach a specific network.

##### 1.15.2.2 Default Static Route

A route used when no more specific route exists in the routing table.

##### 1.15.2.3 Floating Static Route

A backup route that becomes active when the primary route fails.

##### 1.15.2.4 Summary Static Route

A route that represents multiple networks using a single route entry.

Benefits:

- Reduces routing table size
- Simplifies route management

#### 1.15.3 Next-Hop Options

Static routes can be configured using different methods.

##### 1.15.3.1 Next-Hop Route

Specifies only the IP address of the next-hop router.

- Router determines the outgoing interface automatically
- Commonly used method

##### 1.15.3.2 Directly Connected Static Route

Specifies only the outgoing interface.

- Often used on point-to-point links

##### 1.15.3.3 Fully Specified Static Route

Specifies both:

- Outgoing interface
- Next-hop IP address

Benefits:

- Removes ambiguity
- Useful on multi-access networks

#### 1.15.4 IPv6 Static Routes

IPv6 static routes function similarly to IPv4 static routes.

##### 1.15.4.1 IPv6 Link-Local Addresses

IPv6 routes can use link-local addresses as next-hop addresses.

When using a link-local address:

- The exit interface must also be specified
- A fully specified static route is required

Reason:

- Link-local addresses are only unique on the local link

#### 1.15.5 Verifying Static Routes

Static routes should be verified after configuration.

Verification confirms:

- The route is installed
- The correct next hop is being used
- End-to-end connectivity exists

Methods:

- Viewing the routing table
- Connectivity testing
- Route tracing


#### 1.15.6 Default Static Routes
##### 1.15.6.1 Default Route Overview

A default route is used when a destination is not found in the routing table.

It acts as the:

- Gateway of Last Resort

##### 1.15.6.2 Common Uses

Default routes are commonly used on:

- Stub networks
- Branch offices
- Edge routers connected to an ISP

##### 1.15.6.3 Benefits

- Reduces routing table size
- Simplifies network administration
- Provides connectivity to unknown destinations

##### 1.15.6.4 Route Selection

A default route is only used when:

- No more specific route exists

Routers always prefer the most specific route available.

#### 1.15.7 Floating Static Routes
##### 1.15.7.1 Purpose

Floating static routes provide backup connectivity.

They are used when:

- A primary route fails
- Redundant paths exist

##### 1.15.7.2 Administrative Distance (AD)

Administrative Distance determines route preference.

Rules:

- Lower AD = More preferred
- Higher AD = Less preferred

By default:

- Static route AD = 1

##### 1.15.7.3 Floating Route Operation

A floating static route:

- Has a higher AD than the primary route
- Remains inactive while the primary route exists
- Becomes active if the primary route is lost

##### 1.15.7.4 Benefits

- Automatic failover
- Increased reliability
- No dynamic routing protocol required

#### 1.15.8 Host Routes

##### 1.15.8.1 Host Route Overview

A host route identifies a single device rather than an entire network.

Host routes use:

- IPv4: /32 mask
- IPv6: /128 prefix

##### 1.15.8.2 Local Host Routes

Routers automatically create local host routes when an interface receives an IP address.

Purpose:

- Allows packets destined for the router itself to be processed correctly

##### 1.15.8.3 Static Host Routes

Administrators can manually configure host routes to reach specific devices.

Common uses:

- Servers
- Management interfaces
- Critical network devices

##### 1.15.8.4 IPv6 Host Routes

When using an IPv6 link-local next-hop address:

- The exit interface must be specified
- A fully specified route is required

#### 1.15.9 Summary Routes
##### 1.15.9.1 Summary Route Overview

A summary route combines multiple networks into a single route entry.

Benefits:

- Smaller routing tables
- Reduced resource usage
- Easier route management

##### 1.15.9.2 Advantages

- Improves scalability
- Simplifies routing
- Reduces routing updates

#### 1.15.10 Route Selection

When multiple routes exist, routers use the following order:

- Longest prefix match
- Lowest Administrative Distance
- Lowest metric (if applicable)

---

### 1.16 Troubleshoot Static and Default Routes
#### 1.16.1 Packet Processing with Static Routes
##### 1.16.1.1 Static Routes and Packet Forwarding

When a host sends a packet to a destination on another network:

- The packet is sent to the default gateway.
- The router receives the packet and removes the Layer 2 frame information.
- The router examines the destination IP address.
- The router searches its routing table for a matching route.

##### 1.16.1.2 Route Lookup Results

If the destination IP address:

- Matches a static route, the router uses the configured next-hop address or exit interface.
- Does not match a specific route, the router uses the default route if one exists.
- Does not match any route, the router drops the packet and sends an ICMP unreachable message to the source.

##### 1.16.1.3 Forwarding the Packet

After finding a matching route:

- The router encapsulates the packet in a new Layer 2 frame.
- The packet is forwarded out the appropriate interface.
- Each router along the path repeats this process until the destination network is reached.

##### 1.16.1.4 Destination Network Processing

When the packet reaches the router connected to the destination network:

- The router determines that the destination network is directly connected.
- The router checks its ARP table for the destination device MAC address.
- If no ARP entry exists, the router sends an ARP request.
- The destination host replies with its MAC address.
- The router creates a new frame using:
  - Destination MAC = Host MAC address
  - Source MAC = Router interface MAC address
- The frame is forwarded to the destination host.

#### 1.16.2 Troubleshooting Static and Default Routes
##### 1.16.2.1 Causes of Network Failures

Network connectivity problems can occur because:

- An interface fails.
- A link goes down.
- A service provider connection is lost.
- Network links become congested.
- An administrator enters an incorrect configuration.

##### 1.16.2. Troubleshooting Approach

A network administrator should:

- Verify connectivity.
- Check interface status.
- Examine routing tables.
- Verify neighboring devices.
- Identify incorrect route entries.


#### 1.16.3 Common Troubleshooting Commands
##### 1.16.3.1 ping

Purpose:

- Verify Layer 3 connectivity to a destination.

Benefits:

- Confirms reachability.
- Helps isolate connectivity problems.
- Extended ping provides additional testing options.

##### 1.16.3.2 traceroute

Purpose:

- Verify the path packets take to a destination.

Benefits:

- Displays each hop along the route.
- Helps locate routing failures.
- Identifies where packets stop progressing.

##### 1.16.3.3 show ip route

Purpose:

- Display the routing table.

Benefits:

- Verify route entries.
- Confirm static routes exist.
- Verify default route configuration.

##### 1.16.3.4 show ip interface brief

Purpose:

- Display interface status and IP addressing information.

Benefits:

- Verify interfaces are operational.
- Confirm IP addresses are configured correctly.
- Quickly identify interfaces that are down.

##### 1.16.3.5 show cdp neighbors

Purpose:

- Display directly connected Cisco devices.

Benefits:

- Verify Layer 1 connectivity.
- Verify Layer 2 connectivity.
- Confirm neighboring devices and interfaces.


#### 1.16.4 Solving Connectivity Problems
##### 1.16.4.1 Troubleshooting Process

When connectivity fails:

- Test end-to-end connectivity.
- Test connectivity between intermediate routers.
- Examine routing tables.
- Locate incorrect route entries.
- Correct routing information.
- Verify connectivity is restored.

##### 1.16.4.2 Example Problem

Symptoms:

- PC1 cannot communicate with PC3.
- Pings between routers are successful.
- End-to-end communication fails.

Investigation:

- Routing table analysis reveals an incorrect static route.

Solution:

- Remove the incorrect static route.
- Configure the correct static route.
- Verify the updated route appears in the routing table.
- Retest connectivity.

#### 1.16.5 Packet Forwarding Review
##### 1.16.5.1 End-to-End Packet Flow

The packet forwarding process consists of:

1. Host sends packet to default gateway.
2. Router receives and decapsulates packet.
3. Router examines destination IP address.
4. Router searches routing table.
5. Router selects best route.
6. Router encapsulates packet into a new frame.
7. Router forwards packet to the next hop.
8. Process repeats at each router.
9. Destination router locates destination host MAC address.
10. Packet is delivered to the destination host.

##### 1.16.5.2 Route Selection Summary

Routers use:

- Specific static routes first.
- Default routes when no specific match exists.
- ICMP unreachable messages when no route exists.

---

### 2.1 OSPF Features and Characteristics

#### 2.1.1 Introduction to OSPF

Open Shortest Path First (OSPF) is a link-state routing protocol developed to overcome the limitations of distance-vector protocols such as RIP. OSPF provides fast convergence, efficient route calculation, and support for large enterprise networks.

OSPF uses the Shortest Path First (SPF) algorithm, also known as Dijkstra's algorithm, to determine the best path to a destination network.

A link in OSPF can represent:
- A router interface
- A network segment connecting routers
- A stub network connected to a router

Each router gathers information about its directly connected links and advertises this information to other routers in the OSPF area.

Link-state information:
- Network address
- Prefix length
- Cost
- Neighbor relationships

#### 2.1.2 Components of OSPF

OSPF routers exchange routing information and maintain several databases to build an accurate view of the network topology.

The main OSPF packet types are:
- Hello
- Database Description (DBD)
- Link-State Request (LSR)
- Link-State Update (LSU)
- Link-State Acknowledgment (LSAck)

OSPF maintains three databases:

- Adjacency Database (Neighbor Table)
  - Contains information about neighboring OSPF routers.
  - Created through the exchange of Hello packets.

- Link-State Database (LSDB)
  - Contains all link-state advertisements learned within the area.
  - All routers in the same area maintain identical LSDBs.

- Forwarding Database (Routing Table)
  - Contains the best routes calculated by the SPF algorithm.
  - Used to forward packets.

#### 2.1.3 Link-State Operation

OSPF routers build a complete map of the network topology by exchanging link-state information.

The link-state operation consists of the following steps:
- Discover neighbors
- Establish adjacencies
- Exchange topology information
- Build the LSDB
- Run the SPF algorithm
- Populate the routing table

Unlike distance-vector protocols, OSPF routers do not send their entire routing table periodically. Instead, they exchange link-state information when network changes occur.

Because all routers in an area maintain the same LSDB, each router independently calculates identical shortest paths.

#### 2.1.4 Single-Area and Multiarea OSPF

OSPF can be deployed as either a single-area or multiarea routing protocol.

In a single-area OSPF network:
- All routers belong to the same area.
- The entire topology is contained within one LSDB.

In a multiarea OSPF network:
- The routing domain is divided into multiple areas.
- Each area maintains its own LSDB.
- Routing information is exchanged between areas through Area Border Routers (ABRs).

The backbone area is Area 0 and serves as the central point through which all other areas communicate.

#### 2.1.5 Multiarea OSPF

Multiarea OSPF improves scalability by reducing the size of routing databases and limiting SPF calculations.

Benefits of multiarea OSPF:
- Smaller routing tables
- Smaller LSDBs
- Reduced routing update traffic
- Faster convergence
- Improved scalability

Area Border Routers (ABRs) connect areas to the backbone and exchange routing information between areas.

All non-backbone areas must connect directly or indirectly to Area 0.

#### 2.1.6 OSPFv3

OSPFv3 is the version of OSPF designed for IPv6 networks.

OSPFv3 retains the same operational principles as OSPFv2 while providing support for IPv6 addressing.

Characteristics of OSPFv3:
- Support for IPv6 routing
- Use of link-local addresses for neighbor adjacencies
- Support for IPv6 prefixes
- Use of the SPF algorithm
- Support for areas and hierarchical design

OSPFv3 maintains the same concepts of neighbor discovery, LSDB synchronization, and route calculation as OSPFv2.

#### 2.1.7 OSPF Packets

OSPF routers exchange information using several packet types. Each packet serves a specific purpose during neighbor discovery, database synchronization, and topology maintenance.

##### 2.1.7.1 Types of OSPF Packets

OSPF uses five packet types:

- Hello Packet
  - Discovers and maintains neighbor relationships.

- Database Description (DBD) Packet
  - Summarizes the contents of the LSDB.

- Link-State Request (LSR) Packet
  - Requests specific LSAs from neighboring routers.

- Link-State Update (LSU) Packet
  - Sends requested LSAs and topology updates.

- Link-State Acknowledgment (LSAck) Packet
  - Acknowledges receipt of LSAs.

##### 2.1.7.2 Link-State Updates

Link-State Updates (LSUs) contain one or more Link-State Advertisements (LSAs).

LSAs describe:
- Networks
- Router interfaces
- Neighbor relationships
- Route metrics

When a topology change occurs:
- A router generates a new LSA.
- The LSA is flooded throughout the area.
- Routers update their LSDBs.
- SPF calculations are performed again if necessary.

This process ensures that all routers maintain a synchronized view of the network topology.

##### 2.1.7.3 Hello Packet

Hello packets are used to:
- Discover neighboring routers
- Maintain neighbor relationships
- Verify bidirectional communication
- Elect Designated Routers (DRs) and Backup Designated Routers (BDRs)

Hello packets are sent periodically on OSPF-enabled interfaces.

Neighbors must agree on several parameters before forming an adjacency, including:
- Area ID
- Hello interval
- Dead interval
- Authentication settings
- Network type

#### 2.1.8 OSPF Operation

OSPF operation consists of discovering neighbors, synchronizing databases, calculating routes, and maintaining topology information.

Routers exchange LSAs to build a synchronized LSDB and use the SPF algorithm to determine the best routes.

##### 2.1.8.1 OSPF Operational States

OSPF routers transition through several states while establishing adjacencies:

- Down
  - No Hello packets have been received.

- Init
  - A Hello packet has been received.

- Two-Way
  - Bidirectional communication has been established.

- ExStart
  - Routers determine master and slave roles.

- Exchange
  - DBD packets are exchanged.

- Loading
  - Missing LSAs are requested and received.

- Full
  - LSDBs are synchronized and adjacency is complete.

##### 2.1.8.2 Establish Neighbor Adjacencies

OSPF routers discover neighbors through Hello packets.

When routers successfully exchange Hello packets and verify compatible settings, they establish neighbor relationships.

Certain network types require routers to form full adjacencies with selected neighbors, while others maintain only neighbor relationships.

Once an adjacency is formed, routers begin exchanging database information.

##### 2.1.8.3 Synchronizing OSPF Databases

After adjacency formation, routers synchronize their LSDBs.

The synchronization process follows these steps:
- Exchange DBD packets
- Compare LSDB contents
- Request missing LSAs using LSR packets
- Send requested LSAs using LSU packets
- Confirm receipt with LSAck packets

When synchronization is complete, both routers possess identical LSDBs for the area.

##### 2.1.8.4 The Need for a DR

On multiaccess networks such as Ethernet, establishing full adjacencies between all routers would generate excessive OSPF traffic.

To reduce overhead, OSPF elects:
- A Designated Router (DR)
- A Backup Designated Router (BDR)

The DR acts as the central point for exchanging LSAs.

This reduces the number of adjacencies required on the network and improves efficiency.

##### 2.1.8.5 LSA Flooding with a DR

When a DR is present:
- Routers send LSAs to the DR.
- The DR distributes the information to all other routers.
- The BDR maintains a synchronized copy of the database and can assume the DR role if needed.

Using a DR and BDR reduces the amount of LSA flooding and minimizes processing requirements on multiaccess networks.

All routers in the area continue to maintain identical LSDBs despite the use of a DR and BDR.

---

### 2.2 Single-area OSPF configuration

Practical explanation of 2.1 so I will not be covering it here.

---

### 2.3 Security Concepts
#### 2.3.1 Security Fundamentals

Network security protects devices, data, applications, and network infrastructure from unauthorized access, misuse, modification, or destruction.

Important security terms:

- Asset: Anything of value to an organization
- Vulnerability: A weakness that can be exploited
- Threat: A potential danger to an asset
- Exploit: A method used to take advantage of a vulnerability
- Mitigation: A countermeasure that reduces risk
- Risk: The likelihood that a threat exploits a vulnerability

Risk increases when valuable assets contain unmitigated vulnerabilities.

#### 2.3.2 Threat Actors

Threat actors are individuals or groups that perform cyberattacks.

Common threat actors:

- Cyber criminals
- Nation-state attackers
- Hacktivists
- Insider threats
- Script kiddies
- Terrorist organizations

Motivations:

- Financial gain
- Political objectives
- Espionage
- Revenge
- Ideological beliefs

#### 2.3.3 Common Attack Vectors

An attack vector is the path used to gain unauthorized access to a system.

Common attack vectors:

- Email attachments
- Phishing attacks
- Social engineering
- Weak passwords
- Unpatched software
- Removable media
- Cloud services
- Wireless networks

#### 2.3.4 Malware

Malware is malicious software designed to damage systems, steal information, or disrupt operations.

Common malware types:

- Virus
  - Attaches itself to legitimate files
  - Requires user action to spread

- Worm
  - Self-replicates automatically
  - Spreads across networks without user intervention

- Trojan Horse
  - Appears legitimate but contains malicious functionality

- Ransomware
  - Encrypts data and demands payment for decryption

- Spyware
  - Collects information without user knowledge

- Adware
  - Displays unwanted advertisements

- Rootkit
  - Provides privileged access while hiding its presence

#### 2.3.5 Social Engineering

Social engineering manipulates users into revealing information or performing actions.

Common techniques:

- Phishing
- Spear phishing
- Whaling
- Vishing
- Smishing
- Pretexting
- Tailgating

Humans are often considered the weakest security link.

#### 2.3.6 Network Attacks

Common network attacks:

- Denial of Service (DoS)
  - Attempts to make a service unavailable

- Distributed Denial of Service (DDoS)
  - Attack originates from multiple compromised devices

- Man-in-the-Middle (MitM)
  - Attacker intercepts communications between two parties

- Spoofing
  - Attacker impersonates another device or user

- Packet Sniffing
  - Capturing network traffic for analysis or theft

#### 2.3.7 IP Vulnerabilities

IPv4 and IPv6 are vulnerable because they were not originally designed with strong security features.

Common vulnerabilities:

- IP spoofing
- Address scanning
- Packet interception
- Session hijacking

#### 2.3.8 TCP and UDP Vulnerabilities

TCP vulnerabilities:

- SYN flood attacks
- Session hijacking
- Sequence number prediction

UDP vulnerabilities:

- UDP flood attacks
- Reflection attacks
- Amplification attacks

#### 2.3.9 Security Best Practices

Recommended security measures:

- Apply software updates regularly
- Use strong passwords
- Implement multi-factor authentication (MFA)
- Follow the principle of least privilege
- Use firewalls
- Use antivirus and anti-malware software
- Encrypt sensitive data
- Perform regular backups
- Train users on security awareness
- Monitor network activity

#### 2.3.10 Cryptography

Cryptography protects confidentiality, integrity, and authenticity of data.

Security goals:
- Confidentiality
- Integrity
- Availability (CIA Triad)

Hashing:
- Produces a fixed-length digest
- Used to verify data integrity
- One-way process

Encryption:
- Converts plaintext into ciphertext
- Requires a key

Symmetric encryption:
- Same key used for encryption and decryption
- Faster than asymmetric encryption

Asymmetric encryption:
- Uses a public key and a private key
- Public key encrypts
- Private key decrypts

Digital signatures:
- Verify authenticity
- Verify integrity
- Provide non-repudiation

Certificates:
- Bind a public key to an identity
- Issued by a Certificate Authority (CA)

---

### 2.4 ACL Concepts
#### 2.4.1 Purpose of ACLs

An Access Control List (ACL) is a series of IOS commands used to filter packets based on information contained in the packet header. ACLs are a fundamental security feature used to control which traffic is permitted or denied through a router interface.

By default, routers do not have ACLs configured. When an ACL is applied to an interface, every packet passing through that interface is evaluated against the ACL before a forwarding decision is made.

ACLs consist of Access Control Entries (ACEs), which are individual permit or deny statements processed sequentially from top to bottom. The first matching ACE determines the action taken on the packet.

ACLs can be used to:

- Limit network traffic and improve performance
- Control traffic flow
- Provide a basic level of network security
- Filter traffic based on traffic type
- Permit or deny access to specific network services
- Prioritize certain classes of network traffic

#### 2.4.2 Packet Filtering

Packet filtering controls access to a network by analyzing packets and either forwarding or discarding them according to defined criteria. Packet filtering can operate at:

- Layer 3 (Network Layer)
- Layer 4 (Transport Layer)

Cisco routers support two ACL types:

- Standard ACLs
  - Filter only on the source IPv4 address.

- Extended ACLs
  - Filter on source IPv4 address
  - Filter on destination IPv4 address
  - Filter on protocol type
  - Filter on TCP and UDP port numbers
  - Provide much finer traffic control

#### 2.4.3 ACL Operation

ACLs can be applied in two directions:

- Inbound
- Outbound

Important characteristics:

- ACLs do not filter traffic generated by the router itself.
- Inbound ACLs examine packets before routing decisions occur.
- Outbound ACLs examine packets after routing decisions occur.

Inbound ACLs are generally more efficient because unwanted packets are discarded before the router performs route lookups. 

When a packet enters an interface with an inbound ACL:

1. The router extracts the source IPv4 address
2. The router compares the packet against ACEs sequentially
3. When a match occurs, the corresponding permit or deny action is executed
4. ACL processing stops immediately after a match
5. If no ACE matches, the packet is discarded because of the implicit deny rule

#### 2.4.4 Implicit Deny

Every ACL automatically ends with an invisible rule:

```text
deny any
```

This rule is called the implicit deny.

If a packet does not match any ACE in the ACL, it is automatically denied. Therefore, every ACL should contain at least one permit statement if traffic is expected to pass through it.

#### 2.4.5 Wildcard Masks

Wildcard masks are used by ACLs to determine which bits of an IPv4 address must match and which bits should be ignored.

Wildcard mask rules:

- 0 = Match the corresponding bit
- 1 = Ignore the corresponding bit

Unlike subnet masks:

- Subnet mask: 1 = match, 0 = ignore
- Wildcard mask: 0 = match, 1 = ignore

#### 2.4.6 Wildcard Mask Examples

Match a single host:

```text
192.168.1.1 0.0.0.0
```

All bits must match exactly.

Match an entire /24 network:

```text
192.168.1.0 0.0.0.255
```

The first three octets must match. The last octet is ignored.

Match a range of networks:

```text
192.168.16.0 0.0.15.255
```

Matches all hosts in:

```text
192.168.16.0/24
through
192.168.31.0/24
```

#### 2.4.7 Calculating Wildcard Masks

A simple method for calculating a wildcard mask is:

```text
255.255.255.255 - Subnet Mask = Wildcard Mask
```

Examples:

Network:

```text
192.168.3.0/24
```

Subnet mask:

```text
255.255.255.0
```

Wildcard:

```text
0.0.0.255
```

Network:

```text
192.168.3.32/28
```

Subnet mask:

```text
255.255.255.240
```

Wildcard:

```text
0.0.0.15
```

Network summary:

```text
192.168.10.0/23
```

Subnet mask:

```text
255.255.254.0
```

Wildcard:

```text
0.0.1.255
```

#### 2.4.8 Wildcard Keywords

Cisco IOS provides two useful keywords:

Host keyword:

```text
host 192.168.1.1
```

Equivalent to:

```text
192.168.1.1 0.0.0.0
```

Any keyword:

```text
any
```

Equivalent to:

```text
0.0.0.0 255.255.255.255
```

The any keyword matches every IPv4 address.

#### 2.4.9 ACL Limits Per Interface

A dual-stack router interface can support up to four ACLs:

- One inbound IPv4 ACL
- One outbound IPv4 ACL
- One inbound IPv6 ACL
- One outbound IPv6 ACL

The exact number used depends on the organization's security requirements.

#### 2.4.10 ACL Best Practices

When designing ACLs:

- Base ACLs on organizational security policies
- Clearly define what the ACL should accomplish
- Use a text editor to create and store ACLs
- Document ACLs using remarks
- Test ACLs in a lab environment before deployment

Poor ACL design can result in downtime, security issues, and difficult troubleshooting.

#### 2.4.11 Types of IPv4 ACLs

There are two ACL categories:

Standard ACLs:

- Filter only on source IPv4 address.

Extended ACLs:

- Filter on source IPv4 address
- Filter on destination IPv4 address
- Filter on protocol type
- Filter on TCP and UDP ports
- Provide more granular control

#### 2.4.12 Numbered ACLs

Standard numbered ACL ranges:

```text
1 - 99
1300 - 1999
```

Extended numbered ACL ranges:

```text
100 - 199
2000 - 2699
```

#### 2.4.13 Named ACLs

Named ACLs are the preferred method of ACL creation because they clearly identify the ACL's purpose. 

Example:

```text
FTP-FILTER
```

is much more descriptive than:

```text
ACL 100
```

Named ACLs improve readability and simplify administration.

#### 2.4.14 ACL Placement

ACL placement affects network efficiency.

General placement rules:

- Standard ACLs should be placed as close to the destination as possible.
- Extended ACLs should be placed as close to the source as possible.

Reasoning:

- Standard ACLs only examine source addresses, so placing them too close to the source may block traffic intended for other destinations.
- Extended ACLs can identify specific traffic and should stop unwanted traffic before it consumes bandwidth. 

#### 2.4.15 Factors Influencing ACL Placement

ACL placement decisions may depend on:

- Organizational control
  - Whether the organization controls both source and destination networks.

- Bandwidth
  - Filtering at the source prevents unwanted traffic from consuming network bandwidth.

- Ease of configuration
  - Filtering at the destination may be easier to implement.
  - Filtering at the source may require ACLs on multiple devices but improves efficiency. 

#### 2.4.16 Standard ACL Placement

Because standard ACLs only evaluate source addresses, they should generally be placed near the destination network.

This prevents unintentionally blocking traffic destined for other networks

#### 2.4.17 Extended ACL Placement

Because extended ACLs can filter on source, destination, protocol, and port information, they should generally be placed as close to the source as possible.

Benefits:

- Conserves bandwidth
- Prevents unwanted traffic from traversing the network
- Provides more efficient filtering

---

### 2.5 ACLs for IPv4 Configuration

An Access Control List (ACL) is a set of rules used by a router to filter network traffic. ACLs can permit or deny packets based on defined criteria and are commonly used to improve security, control traffic flow, and restrict administrative access.

ACLs process entries sequentially from top to bottom. As soon as a packet matches an entry, processing stops and the corresponding action is taken. Every ACL ends with an implicit deny statement that drops all traffic not explicitly permitted.

#### 2.5.1 Configure Standard IPv4 ACLs

Standard IPv4 ACLs filter traffic based only on the source IPv4 address.

ACLs should be carefully planned before implementation. When creating complex ACLs it is recommended to:

- Define the required traffic policy
- Document ACL entries
- Use remarks to describe the purpose of entries
- Test the ACL after deployment

Standard ACLs can be configured using either numbered ACLs or named ACLs.

##### 2.5.1.1 Numbered Standard ACLs

Numbered standard ACLs use ACL numbers in the ranges:

- 1 to 99
- 1300 to 1999

Each Access Control Entry (ACE) can:

- Permit traffic
- Deny traffic
- Include remarks for documentation
- Generate log messages when matched

##### 2.5.1.2 Named Standard ACLs

Named ACLs use descriptive names instead of numbers.

Characteristics of named ACLs:

- Names are alphanumeric
- Names are case-sensitive
- Names must be unique

Named ACLs make configurations easier to understand and maintain.

##### 2.5.1.3 Applying Standard ACLs

After an ACL is created, it must be applied to an interface or service before it affects traffic.

ACLs can be applied:

- Inbound (traffic entering an interface)
- Outbound (traffic leaving an interface)

Verification can be performed using:

- `show access-lists`
- `show ip interface`
- `show running-config`

#### 2.5.2 Modify IPv4 ACLs

ACLs often require updates after deployment.

Two methods can be used to modify ACLs:

##### 2.5.2.1 Text Editor Method

This method is recommended for ACLs containing multiple ACEs.

The process is:

- Copy the ACL from the running configuration
- Paste it into a text editor
- Make the required modifications
- Remove the existing ACL from the router
- Reapply the updated ACL

This approach reduces configuration mistakes and simplifies editing.

##### 2.5.2.2 Sequence Number Method

Each ACE is automatically assigned a sequence number.

Sequence numbers allow administrators to:

- Insert new ACEs
- Delete existing ACEs
- Reorder entries

An existing ACE cannot be directly overwritten.

To modify an entry:

- Remove the original ACE
- Add the corrected ACE using the desired sequence number

Named ACLs and extended ACLs both support sequence numbers.

##### 2.5.2.3 ACL Statistics

ACLs maintain counters that record how many packets match each ACE.

These statistics help verify ACL operation and troubleshoot filtering issues.

Important characteristics:

- Match counters increase whenever traffic matches an ACE
- The implicit deny entry does not maintain statistics
- An explicit deny statement can be added if statistics for denied traffic are required

ACL counters can be cleared when needed.

#### 2.5.3 Secure VTY Ports with a Standard IPv4 ACL

Standard ACLs can be used to restrict remote administrative access to router VTY lines.

The process consists of two steps:

- Create an ACL identifying permitted management hosts
- Apply the ACL to the VTY lines

This ensures that only authorized hosts can establish remote management sessions.

ACLs can be used to restrict access for:

- SSH
- Telnet

Using ACLs on VTY lines provides an additional layer of security by preventing unauthorized administrative access attempts.

Verification should confirm:

- Authorized hosts are allowed access
- Unauthorized hosts are denied access
- ACL counters increase appropriately when matches occur

#### 2.5.4 Configure Extended IPv4 ACLs

Extended ACLs provide much greater filtering capability than standard ACLs.

Extended ACLs can filter based on:

- Source IPv4 address
- Destination IPv4 address
- Protocol type
- Port numbers

Supported protocols commonly:

- IP
- TCP
- UDP
- ICMP

Because extended ACLs can identify specific traffic flows, they are typically placed as close to the source as possible.

##### 2.5.4.1 Numbered and Named Extended ACLs

Extended ACLs can be configured as:

- Numbered extended ACLs
- Named extended ACLs

Named ACLs are generally easier to manage because their purpose is immediately visible from the ACL name.

##### 2.5.4.2 Protocol and Port Filtering

Extended ACLs can filter traffic based on application protocols and port numbers.

Examples:

- HTTP (TCP port 80)
- HTTPS (TCP port 443)
- SSH (TCP port 22)
- Telnet (TCP port 23)
- DNS (port 53)
- FTP (ports 20 and 21)

Filtering by protocol and port allows administrators to permit only specific applications while blocking others.

##### 2.5.4.3 TCP Established ACLs

Extended ACLs can provide limited stateful filtering through the TCP established keyword.

This allows:

- Internal hosts to initiate TCP connections
- Return traffic from existing connections to be permitted
- Unsolicited inbound TCP sessions to be blocked

A packet is considered part of an established connection when the TCP ACK or RST flags are present.

This mechanism provides basic protection similar to a simple stateful firewall.

##### 2.5.4.4 Editing Extended ACLs

Extended ACLs can be modified using:

- A text editor for large changes
- Sequence numbers for small modifications

When using sequence numbers:

- Remove the incorrect ACE
- Insert the corrected ACE
- Verify the ACL after modification

##### 2.5.4.5 Verifying Extended ACLs

Several commands can be used to verify extended ACL operation.

Verification tasks:

- Confirming the ACL is applied to the correct interface
- Confirming the ACL direction (inbound or outbound)
- Reviewing match counters
- Validating configured ACEs

Traffic must be generated through the ACL before match counters will increase.

Regular verification ensures that ACLs are functioning as intended and enforcing the desired security policy.

---

### 2.6 NAT for IPv4

Network Address Translation (NAT) is a technology that enables private IPv4 networks to communicate with public networks by translating private addresses into public addresses. NAT was developed primarily to conserve public IPv4 addresses and remains widely used in modern networks.

#### 2.6.1 NAT Characteristics
##### 2.6.1.1 IPv4 Address Space

Most internal networks use private IPv4 addresses defined in RFC 1918.

Private IPv4 address ranges are:

- 10.0.0.0/8
- 172.16.0.0/12
- 192.168.0.0/16

Private addresses cannot be routed across the public internet. When devices using private addresses need to access external networks, their addresses must be translated into public addresses.

NAT performs this translation between private and public IPv4 addresses.

##### 2.6.1.2 Purpose of NAT

The primary purpose of NAT is to conserve public IPv4 addresses.

NAT allows:
- Internal devices to use private IPv4 addresses
- Multiple devices to share public IPv4 addresses
- Communication between private networks and the internet

NAT is typically implemented on a border router located between the internal network and the public network.

##### 2.6.1.3 How NAT Works

When a packet leaves an internal network:

- The NAT router examines the source address
- The private source address is translated into a public address
- A translation entry is created in the NAT table
- The packet is forwarded to the destination

When return traffic arrives:

- The NAT router checks the NAT table
- The public address is translated back into the original private address
- The packet is forwarded to the internal device

The NAT table maintains the relationship between private and public addresses.

##### 2.6.1.4 NAT Terminology

NAT terminology is always described from the perspective of the translated device.

###### Inside Local Address

The address of the internal device as seen inside the network.

- Usually a private IPv4 address

###### Inside Global Address

The address representing the internal device as seen outside the network.

- Usually a public IPv4 address

###### Outside Global Address

The real address of the external destination device

###### Outside Local Address

The destination address as seen from inside the network.

- Often identical to the outside global address

#### 2.6.2 Types of NAT

Three primary NAT implementations are commonly used.

##### 2.6.2.1 Static NAT

Static NAT creates a permanent one-to-one mapping between a private address and a public address.

Characteristics:

- Fixed mapping.
- Manually configured.
- Always remains the same.

Static NAT is commonly used for:

- Web servers
- Mail servers
- Devices requiring permanent public accessibility

Each internal device requires its own public IPv4 address.

##### 2.6.2.2 Dynamic NAT

Dynamic NAT uses a pool of public IPv4 addresses.

Characteristics:

- Public addresses are assigned automatically
- Addresses are allocated on a first-come, first-served basis
- Mappings are temporary

When an internal device initiates communication:

- An available address is selected from the pool
- A temporary mapping is created
- The mapping is removed when no longer needed

If all public addresses are in use, additional devices must wait until an address becomes available.

##### 2.6.2.3 Port Address Translation (PAT)

Port Address Translation (PAT), also called NAT overload, allows multiple internal devices to share a single public IPv4 address.

PAT works by translating:

- IPv4 addresses
- TCP port numbers
- UDP port numbers

Each session is identified using a unique port number.

Benefits of PAT:

- Significantly reduces public address requirements
- Supports many simultaneous users with a single public IPv4 address
- Most commonly deployed NAT solution

##### 2.6.2.4 Port Allocation in PAT

PAT attempts to preserve the original source port number.

If the port is already in use:

- PAT selects the next available port number
- A unique translation entry is created

Port ranges:

- 0–511
- 512–1023
- 1024–65535

If no ports remain available for an address, PAT can use another address from the pool if one exists.

##### 2.6.2.5 NAT and PAT Comparison

Static and Dynamic NAT:

- Translate only IPv4 addresses
- Create one-to-one mappings
- Require a unique public address for each active internal host

PAT:

- Translates IPv4 addresses and port numbers.
- Supports many internal hosts using one public address
- Conserves public IPv4 addresses much more efficiently

##### 2.6.2.6 NAT for Protocols without Ports

Some protocols do not use TCP or UDP port numbers.

For example:

- ICMP uses Query IDs rather than port numbers

PAT uses protocol-specific identifiers to maintain unique translations for these protocols.

#### 2.6.3 NAT Advantages and Disadvantages

##### 2.6.3.1 Advantages of NAT

NAT provides several benefits:

- Conserves public IPv4 addresses
- Allows use of private addressing schemes
- Simplifies internal addressing
- Hides internal IPv4 addresses from external networks
- Provides flexibility when changing ISPs or public address ranges
- Supports address sharing through PAT

##### 2.6.3.2 Disadvantages of NAT

NAT also introduces limitations:

- Increases packet processing time
- Adds forwarding delay
- Breaks end-to-end addressing
- Makes end-to-end traceability more difficult
- Complicates protocols such as IPsec
- Can interfere with applications that require inbound connections
- May affect some UDP-based services

#### 2.6.4 Static NAT

##### 2.6.4.1 Static NAT Operation

Static NAT creates a permanent relationship between:

- One inside local address
- One inside global address

This mapping remains in the NAT table regardless of whether traffic is flowing.

Static NAT allows external devices to initiate connections to internal devices.

This makes it ideal for:

- Public web servers
- Public DNS servers
- Public mail servers

##### 2.6.4.2 Static NAT Translation Process

When traffic arrives from the outside:

- The router receives the packet
- The inside global address is located in the NAT table
- The address is translated to the corresponding inside local address
- The packet is forwarded to the internal device

For return traffic:

- The inside local address is translated back to the inside global address.
- The packet is forwarded toward the external network.

##### 2.6.4.3 Verifying Static NAT

Static NAT translations are always present because the mapping is permanent.

Verification can display:

- Current translations
- Active sessions
- NAT statistics
- Inside and outside interfaces
- Translation hits and misses

#### 2.6.5 Dynamic NAT

##### 2.6.5.1 Dynamic NAT Operation

Dynamic NAT automatically maps inside local addresses to available public addresses from a predefined pool.

Characteristics:

- Temporary translations
- Automatic assignment
- Address reuse after expiration

The pool is shared among all internal hosts.

##### 2.6.5.2 Dynamic NAT Translation Process

When an internal device initiates communication:

- The packet is checked against translation criteria
- An available public address is selected from the pool
- A translation entry is created
- The packet is forwarded using the assigned public address

When return traffic arrives:

- The NAT table is consulted
- The public address is translated back to the original private address
- The packet is delivered to the correct internal device

##### 2.6.5.3 Dynamic NAT Translation Entries

Dynamic translations remain active while traffic is being exchanged.

By default:

- Dynamic translations expire after 24 hours

Expired entries are removed and their public addresses become available for reuse.

##### 2.6.5.4 Verifying Dynamic NAT

Verification can display:

- Active translations
- Translation timers
- Address pool information
- Allocated and available addresses
- Translation statistics

The NAT table shows the relationship between inside local and inside global addresses.

#### 2.6.6 Port Address Translation (PAT)

##### 2.6.6.1 PAT Operation

PAT allows many internal devices to share one public IPv4 address.

Instead of assigning a unique public address to each host:

- A single public address is used
- Unique port numbers identify individual sessions

This enables thousands of simultaneous translations using one public IPv4 address.

##### 2.6.6.2 PAT Translation Process

When traffic leaves the internal network:

- The source IPv4 address is translated
- The source port number is examined
- If necessary, a unique port number is assigned
- A translation entry is created

When return traffic arrives:

- The destination port is examined
- The NAT table identifies the correct internal host
- The original address and port are restored

##### 2.6.6.3 PAT with a Single Public Address

PAT can use:
- The public address assigned to an interface

All internal hosts share that single public address.

Session uniqueness is maintained through port numbers.

##### 2.6.6.4 PAT with an Address Pool

PAT can also operate using a pool of public addresses.

Characteristics:
- Multiple public addresses are available
- Port numbers are still used
- Additional addresses are used only when required

This combines the scalability of PAT with the flexibility of dynamic NAT.

##### 2.6.6.5 Verifying PAT

Verification confirms:
- Shared public addresses
- Unique port assignments
- Active translations
- Pool usage
- Translation statistics

The NAT table displays both addresses and port numbers for each active session.

#### 2.6.7 NAT64

##### 2.6.7.1 NAT and IPv6

IPv6 was designed to eliminate the address shortage that led to widespread NAT deployment in IPv4.

IPv6 includes Unique Local Addresses (ULAs), but these are not intended to provide address conservation in the same way as IPv4 private addresses.

ULAs are intended only for local communications within a site.

##### 2.6.7.2 NAT64

NAT64 provides translation between:

- IPv6-only networks
- IPv4-only networks

NAT64 enables communication between devices using different IP versions without requiring dual-stack operation.

##### 2.6.7.3 Purpose of NAT64

NAT64 is intended as a migration technology.

Its purpose is to:

- Facilitate the transition from IPv4 to IPv6
- Allow IPv6-only devices to communicate with IPv4-only resources
- Provide interoperability during migration

NAT64 is considered a temporary solution rather than a permanent networking design.

---

### 2.7 WAN Concepts
#### 2.7.1 Purpose of WANs
##### 2.7.1.1 LANs and WANs

A Wide Area Network (WAN) is a telecommunications network that spans large geographical areas and connects networks beyond the boundaries of a LAN.

LANs provide networking services within a limited geographic area, while WANs interconnect remote users, branch offices, and networks across cities, countries, or continents.

A LAN is typically owned and managed by a single organization. A WAN is usually operated by service providers that offer connectivity services for a recurring fee.

##### 2.7.1.2 Private and Public WANs

A private WAN is dedicated to a single customer and typically provides:

- Guaranteed service levels
- Consistent bandwidth
- Improved security

A public WAN uses shared provider infrastructure and typically provides:

- Lower costs
- Shared bandwidth
- Less predictable performance

Public WANs often rely on VPN technology to provide secure communications.

##### 2.7.1.3 WAN Topologies

Common WAN topologies:

- Point-to-Point
- Hub-and-Spoke
- Dual-Homed
- Fully Meshed
- Partially Meshed

A point-to-point topology provides a direct connection between two locations.

A hub-and-spoke topology connects all branch locations to a central site. Communication between branches passes through the hub.

A dual-homed topology provides redundant connections to improve availability.

A fully meshed topology provides direct connections between all locations, offering maximum redundancy at the highest cost.

A partially meshed topology provides direct connections only between selected locations, balancing cost and redundancy.

##### 2.7.1.4 Carrier Connections

Organizations connect to WAN services through service providers.

Connectivity models:
- Single-carrier connections
- Dual-carrier connections

Dual-carrier designs improve redundancy by using multiple service providers.

#### 2.7.2 WAN Operations
##### 2.7.2.1 WAN Standards

WAN technologies are developed and maintained by standards organizations:
- ISO
- IEEE
- TIA/EIA

These organizations define standards that ensure interoperability between vendors.

##### 2.7.2.2 WAN Layers

Most WAN technologies operate at:

- Layer 1 (Physical Layer)
- Layer 2 (Data Link Layer)

Layer 1 standards define the physical transmission of data.

Layer 2 standards define framing, addressing, and encapsulation mechanisms used across WAN links.

##### 2.7.2.3 Common WAN Terminology

Important WAN terms:
- Customer Premises Equipment (CPE)
- Data Terminal Equipment (DTE)
- Data Communications Equipment (DCE)
- Demarcation Point
- Local Loop
- Central Office (CO)
- Point of Presence (POP)

The demarcation point separates customer-owned equipment from provider-owned equipment.

The local loop connects the customer site to the provider network.

A central office is a provider facility that connects customers to the WAN infrastructure.

A point of presence is a provider access location where customers connect to the service provider network.

##### 2.7.2.4 WAN Devices

Common WAN devices:
- Modems
- DSL Modems
- Cable Modems
- CSU/DSUs
- Optical Converters
- WAN Routers

These devices provide connectivity between customer networks and service provider networks.

##### 2.7.2.5 Serial and Parallel Communication

Serial communication sends data one bit at a time over a single channel.

Parallel communication sends multiple bits simultaneously using multiple channels.

WAN technologies primarily use serial communication because it is more reliable over long distances.

##### 2.7.2.6 Circuit Switching

Circuit-switched communication establishes a dedicated path before data transfer begins.

Characteristics:
- Dedicated communication path
- Consistent performance
- Reserved resources

Examples:
- PSTN
- ISDN

##### 2.7.2.7 Packet Switching

Packet-switched communication divides data into packets and forwards them independently through the network.

Characteristics:
- Shared infrastructure
- Efficient resource utilization
- Lower costs

Examples:
- MPLS
- Metro Ethernet
- Frame Relay
- ATM

##### 2.7.2.8 Optical Transport Technologies

SONET and SDH are optical transmission standards used in provider backbones.

Dense Wavelength Division Multiplexing (DWDM) increases fiber capacity by transmitting multiple wavelengths of light simultaneously over a single fiber.

#### 2.7.3 Traditional WAN Connectivity
##### 2.7.3.1 Leased Lines

A leased line provides a dedicated point-to-point connection between two sites.

Common leased-line technologies:
- T1
- T3
- E1
- E3

Leased lines offer:
- Predictable performance
- Consistent bandwidth
- High reliability

Disadvantages:
- High cost
- Limited flexibility

##### 2.7.3.2 PSTN

The Public Switched Telephone Network (PSTN) is a circuit-switched network originally designed for voice communications.

PSTN can also provide data connectivity using dial-up modem connections.

##### 2.7.3.3 ISDN

Integrated Services Digital Network (ISDN) is a digital circuit-switched technology that supports voice and data services.

ISDN offers higher performance than traditional dial-up connections but has largely been replaced by broadband technologies.

##### 2.7.3.4 Frame Relay

Frame Relay is a Layer 2 packet-switched WAN technology.

Characteristics:
- Use of virtual circuits
- Shared provider infrastructure
- Lower cost than leased lines

Frame Relay has largely been replaced by MPLS and Ethernet WAN services.

##### 2.7.3.5 ATM

Asynchronous Transfer Mode (ATM) is a cell-switching technology that uses fixed-size cells for data transmission.

ATM supports:
- Voice
- Video
- Data

ATM has largely been replaced by newer technologies such as MPLS and Ethernet WAN.

#### 2.7.4 Modern WAN Connectivity
##### 2.7.4.1 Ethernet WAN

Ethernet WAN services extend Ethernet technology across metropolitan and wide-area networks.

Benefits:
- Lower costs
- Simplified management
- Easy integration with existing LANs

Common implementations:
- Metro Ethernet
- Ethernet over MPLS
- Virtual Private LAN Service (VPLS)

##### 2.7.4.2 MPLS

Multiprotocol Label Switching (MPLS) is a packet-forwarding technology used in provider networks.

Instead of forwarding packets solely based on IP addresses, MPLS uses labels to make forwarding decisions.

Benefits:
- High performance
- Traffic engineering
- Quality of Service (QoS)
- VPN support
- Scalability

MPLS supports both IPv4 and IPv6 traffic.

#### 2.7.5 Internet-Based Connectivity
##### 2.7.5.1 Broadband Connections

Broadband services provide high-speed internet connectivity through:

- DSL
- Cable
- Fiber
- Wireless technologies

These services are commonly used for branch offices and remote users.

##### 2.7.5.2 DSL

Digital Subscriber Line (DSL) uses existing telephone wiring to provide broadband connectivity.

Common DSL variants:
- ADSL
- SDSL

ADSL provides faster download speeds than upload speeds.

SDSL provides equal upload and download speeds.

##### 2.7.5.3 DSL Components

DSL deployments use:
- DSL Modems
- DSL Access Multiplexers (DSLAMs)

The DSL modem connects the customer to the provider network.

The DSLAM aggregates multiple DSL customer connections at the provider site.

##### 2.7.5.4 PPP over Ethernet (PPPoE)

PPPoE combines PPP features with Ethernet networks.

PPPoE provides:
- User authentication
- IP address assignment
- Link management

PPPoE is commonly used by DSL providers.

##### 2.7.5.5 Cable Broadband

Cable broadband uses coaxial cable television infrastructure to provide internet connectivity.

Cable networks use:

- DOCSIS standards
- Cable Modem Termination Systems (CMTS)

Unlike DSL, bandwidth is shared among subscribers connected to the same cable segment.

##### 2.7.5.6 Fiber Broadband

Fiber broadband provides connectivity using optical fiber.

Common deployment models:
- Fiber to the Home (FTTH)
- Fiber to the Building (FTTB)
- Fiber to the Node (FTTN)

Fiber provides the highest bandwidth and lowest latency among broadband technologies.

##### 2.7.5.7 Wireless Broadband

Wireless broadband technologies:
- Cellular networks
- Satellite internet
- Municipal Wi-Fi
- WiMAX

Wireless solutions are particularly useful where wired infrastructure is unavailable.

##### 2.7.5.8 VPN Technology

A Virtual Private Network (VPN) creates a secure encrypted tunnel through a public network.

VPNs provide:
- Confidentiality
- Data integrity
- Authentication

VPNs allow organizations to use the internet as a secure WAN transport medium.

##### 2.7.5.9 Site-to-Site VPNs

A site-to-site VPN connects entire networks together.

The VPN is established between networking devices, making the tunnel transparent to end users.

##### 2.7.5.10 Remote Access VPNs

A remote access VPN allows individual users to securely connect to a corporate network from remote locations.

The user establishes the VPN connection using VPN client software or web-based access.

##### 2.7.5.11 ISP Connectivity Options

Organizations can connect to ISPs using different redundancy models:

- Single-Homed
- Dual-Homed
- Multihomed
- Dual-Multihomed

Single-homed designs use one ISP connection.

Dual-homed designs use multiple connections to the same ISP.

Multihomed designs use multiple ISPs.

Dual-multihomed designs use multiple connections to multiple ISPs and provide the highest level of availability and redundancy.

---

### 2.8 VPN and IPsec Concepts

#### 2.8.1 VPN Technology

##### 2.8.1.1 Virtual Private Networks

A Virtual Private Network (VPN) creates a secure connection across a public network such as the internet.

VPNs allow organizations to securely connect users, branch offices, and networks without requiring expensive dedicated WAN connections.

A VPN is considered:
- Virtual because it uses a shared public infrastructure.
- Private because traffic is encrypted and protected from unauthorized access.

##### 2.8.1.2 Benefits of VPNs

VPNs provide several advantages:
- Reduced WAN costs
- Secure communications
- Scalability
- Flexibility

Organizations can use existing internet connections while maintaining secure communications between locations.

##### 2.8.1.3 Site-to-Site VPNs

A site-to-site VPN connects entire networks together.

The VPN tunnel is established between VPN gateways such as routers or firewalls.

Characteristics:
- Transparent to end users
- Commonly used between branch offices and headquarters
- Provides secure network-to-network connectivity

##### 2.8.1.4 Remote Access VPNs

A remote access VPN allows individual users to securely connect to an organization's network.

These VPNs are commonly used by:
- Teleworkers
- Mobile users
- Remote employees

The VPN tunnel is established between the user's device and the VPN gateway.

##### 2.8.1.5 Enterprise-Managed and Service Provider-Managed VPNs

Enterprise-managed VPNs are configured and maintained by the organization itself.

Service provider-managed VPNs are maintained by a service provider and commonly use MPLS technologies to separate customer traffic.

#### 2.8.2 VPN Types

##### 2.8.2.1 Clientless VPNs

A clientless VPN allows users to connect through a web browser without installing VPN software.

Characteristics:
- Browser-based access
- Easy deployment
- No VPN client required

Access is usually limited to web-based resources.

##### 2.8.2.2 Client-Based VPNs

A client-based VPN requires VPN software to be installed on the user's device.

Characteristics:
- Full VPN functionality
- Access to more network resources
- Secure encrypted tunnel between the client and VPN gateway

##### 2.8.2.3 SSL VPNs

SSL VPNs use SSL/TLS to provide secure remote access.

Advantages:
- Broad device compatibility
- Browser-based access
- Simplified deployment

SSL VPNs are commonly used when users connect from unmanaged or public devices.

##### 2.8.2.4 IPsec VPNs

IPsec VPNs provide secure communications at the network layer.

Characteristics:
- Strong encryption
- Strong authentication
- Support for all IP traffic

IPsec is commonly used for site-to-site VPN deployments.

##### 2.8.2.5 SSL VPNs and IPsec VPNs

SSL VPNs:

- Primarily support remote-access connections
- Can operate through a web browser
- Easier for end users to access

IPsec VPNs:

- Support both remote-access and site-to-site connections
- Protect all IP traffic
- Commonly used between networks

##### 2.8.2.6 GRE Tunnels

Generic Routing Encapsulation (GRE) is a tunneling protocol that encapsulates packets inside another packet.

GRE supports:
- Unicast traffic
- Multicast traffic
- Broadcast traffic
- Routing protocol updates

GRE does not provide encryption or authentication.

##### 2.8.2.7 GRE over IPsec

GRE is often combined with IPsec.

In a GRE over IPsec deployment:
- GRE provides the tunnel.
- IPsec provides security.

This combination allows routing protocols and multicast traffic to be transported securely across a VPN.

##### 2.8.2.8 Dynamic Multipoint VPN (DMVPN)

Dynamic Multipoint VPN (DMVPN) is a Cisco VPN solution designed for scalable VPN deployments.

Benefits:
- Reduced configuration complexity
- Dynamic tunnel creation
- Support for direct spoke-to-spoke communication

DMVPN is commonly used in hub-and-spoke VPN designs.

#### 2.8.3 IPsec

##### 2.8.3.1 Purpose of IPsec

IPsec is a framework used to secure communications across IP networks.

IPsec protects traffic travelling across untrusted networks such as the internet.

IPsec provides:
- Confidentiality
- Integrity
- Authentication
- Secure key exchange

##### 2.8.3.2 Confidentiality

Confidentiality ensures that only authorized users can read transmitted data.

IPsec achieves confidentiality through encryption.

Encrypted traffic cannot be interpreted by unauthorized users.

##### 2.8.3.3 Integrity

Integrity ensures that data has not been modified during transmission.

Integrity checks allow the receiving device to verify that the packet contents remain unchanged.

##### 2.8.3.4 Authentication

Authentication verifies the identity of the communicating peers.

Authentication prevents unauthorized devices from participating in VPN communications.

##### 2.8.3.5 Authentication Header (AH)

Authentication Header (AH) provides:
- Authentication
- Integrity

AH does not provide confidentiality because packet contents are not encrypted.

##### 2.8.3.6 Encapsulating Security Payload (ESP)

Encapsulating Security Payload (ESP) provides:
- Confidentiality
- Integrity
- Authentication

ESP is the most commonly used IPsec protocol because it supports encryption.

##### 2.8.3.7 Authentication Methods

IPsec peers must authenticate each other before establishing a VPN tunnel.

Common authentication methods:
- Pre-Shared Keys (PSKs)
- RSA Digital Certificates

Pre-shared keys are simple to configure but do not scale well.

Digital certificates provide stronger scalability and are commonly used in enterprise environments.

##### 2.8.3.8 Security Associations

A Security Association (SA) defines the security parameters used by IPsec.

Security Associations specify how the VPN tunnel will protect traffic, including the authentication and encryption methods used by the communicating peers.

---

### 2.9 QoS Concepts

#### 2.9.1 Network Transmission Quality

Quality of Service (QoS) is a collection of techniques used to manage network resources and prioritize important traffic during periods of congestion.

Without QoS, all traffic is treated equally. During congestion, delay-sensitive traffic such as voice and video can experience poor performance due to delays and packet loss. QoS becomes active when congestion occurs and allows network devices to prioritize critical traffic.

##### 2.9.1.1 Bandwidth

Bandwidth is the amount of data that can be transmitted across a network link in one second and is measured in bits per second (bps).

Congestion occurs when more traffic is presented to an interface than it can handle. Common congestion points:
- Traffic aggregation points
- Speed mismatches between interfaces
- LAN-to-WAN transitions

##### 2.9.1.2 Delay and Jitter

Delay (latency) is the time required for a packet to travel from source to destination.

Common sources of delay:
- Packetization delay
- Queuing delay
- Serialization delay
- Propagation delay

Jitter is the variation in packet delay. Excessive jitter negatively affects real-time applications such as VoIP and video conferencing.

##### 2.9.1.3 Packet Loss

Packet loss occurs when network devices drop packets due to congestion or buffer exhaustion.

Packet loss is especially harmful to:
- Voice traffic
- Real-time video traffic

A properly designed network should experience minimal packet loss.

#### 2.9.2 Traffic Characteristics

Different traffic types have different QoS requirements.

##### 2.9.2.1 Voice Traffic

Voice traffic is:
- Predictable
- Delay-sensitive
- Jitter-sensitive
- Packet-loss sensitive

Recommended voice requirements:
- Latency less than 150 ms
- Jitter less than 30 ms
- Packet loss less than 1%

Because voice commonly uses UDP, lost packets cannot be retransmitted and should therefore receive high priority. :contentReference[oaicite:1]{index=1}

##### 2.9.2.2 Video Traffic

Video traffic is:
- Bursty
- Bandwidth-intensive
- Delay-sensitive
- Packet-loss sensitive

Recommended video requirements:
- Latency less than 200–400 ms
- Jitter less than 30–50 ms
- Packet loss less than 1%

Video generally requires significantly more bandwidth than voice.

##### 2.9.2.3 Data Traffic

Data traffic is generally less sensitive to delay and packet loss because many applications use TCP, which can retransmit lost packets.

Characteristics:
- Can be smooth or bursty
- May consume large amounts of bandwidth
- Less sensitive to delay
- Less sensitive to packet loss

Examples:
- Email
- Web browsing
- File transfers

#### 2.9.3 Queuing Algorithms

Queuing algorithms determine how packets are processed when congestion occurs.

##### 2.9.3.1 First In First Out (FIFO)

FIFO is the default queuing method.

Characteristics:
- Single queue
- Packets are transmitted in order of arrival
- No prioritization
- All traffic treated equally

##### 2.9.3.2 Weighted Fair Queuing (WFQ)

WFQ automatically classifies traffic into flows and allocates bandwidth fairly among them.

Characteristics:
- Fair bandwidth distribution
- Prioritizes smaller flows when necessary
- Uses traffic characteristics to classify packets

##### 2.9.3.3 Class-Based Weighted Fair Queuing (CBWFQ)

CBWFQ extends WFQ by allowing administrators to create custom traffic classes.

Characteristics:
- User-defined traffic classes
- Guaranteed bandwidth per class
- Separate queue for each class
- More granular control than WFQ

##### 2.9.3.4 Low Latency Queuing (LLQ)

LLQ adds a strict priority queue to CBWFQ.

Characteristics:
- Designed for delay-sensitive traffic
- Voice traffic is typically placed in the priority queue
- Priority traffic is transmitted before other traffic

LLQ is commonly used to support VoIP deployments.

#### 2.9.4 QoS Models

Three QoS models are commonly discussed.

##### 2.9.4.1 Best-Effort Model

Best-effort is the default behavior of IP networks.

Characteristics:
- No QoS guarantees
- All traffic treated equally
- No prioritization
- Highly scalable

This model is simple but unsuitable for applications requiring guaranteed performance.

##### 2.9.4.2 Integrated Services (IntServ)

IntServ provides end-to-end QoS guarantees by reserving resources for individual traffic flows.

Characteristics:
- Resource reservation
- Guaranteed service
- Uses RSVP (Resource Reservation Protocol)
- Per-flow management

Although IntServ provides strong QoS guarantees, it is not highly scalable because network devices must maintain information for each flow.

##### 2.9.4.3 Differentiated Services (DiffServ)

DiffServ classifies traffic into classes and applies QoS policies on a hop-by-hop basis.

Characteristics:
- Highly scalable
- Traffic is grouped into classes
- Different service levels can be assigned to different classes
- Most common QoS model used today

DiffServ does not provide strict end-to-end guarantees but offers a practical balance between scalability and performance.

#### 2.9.5 QoS Implementation Techniques

QoS is implemented using several tools and mechanisms.

##### 2.9.5.1 Classification and Marking

Traffic must first be classified before QoS policies can be applied.

Classification can be based on:
- Interfaces
- ACLs
- Protocols
- Applications
- NBAR (Network Based Application Recognition)

After classification, traffic is marked so other devices can identify its priority level.

##### 2.9.5.2 Layer 2 Marking

Layer 2 QoS marking uses IEEE 802.1p.

802.1p defines Class of Service (CoS) values ranging from:

- 0 (Best Effort)
- 7 (Highest Priority)

Common values:

- CoS 3 – Call signaling
- CoS 4 – Video conferencing
- CoS 5 – Voice traffic

##### 2.9.5.3 Layer 3 Marking

IPv4 and IPv6 support QoS marking using:

- IP Precedence (IPP)
- Differentiated Services Code Point (DSCP)

DSCP uses 6 bits, providing 64 possible service classes.

Important DSCP values:

- DSCP 0 (Best Effort)
- EF (Expedited Forwarding) = 46, commonly used for voice traffic
- AF (Assured Forwarding) classes for differentiated service levels

##### 2.9.5.4 Trust Boundaries

A trust boundary is the point where QoS markings are accepted and trusted.

Traffic should be classified and marked as close to the source as possible.

Marking can occur at:

- End devices
- Access switches
- Layer 3 switches
- Routers

##### 2.9.5.5 Congestion Avoidance

Congestion avoidance mechanisms attempt to prevent congestion before queues become full.

Weighted Random Early Detection (WRED) is commonly used.

WRED:
- Monitors queue depth
- Drops lower-priority packets before congestion becomes severe
- Helps prevent tail drops
- Improves TCP performance

##### 2.9.5.6 Traffic Shaping

Traffic shaping smooths traffic flows by buffering excess packets and transmitting them later.

Characteristics:
- Outbound process
- Reduces bursts
- Helps prevent congestion
- Creates a more consistent transmission rate

##### 2.9.5.7 Traffic Policing

Traffic policing enforces a configured traffic rate.

Characteristics:
- Typically applied inbound
- Drops or remarks traffic exceeding the configured rate
- Commonly used by service providers to enforce bandwidth contracts

##### 2.9.5.8 QoS Design Guidelines

General QoS recommendations:
- Classify and mark traffic close to the source
- Enable queuing throughout the network path
- Use shaping and policing where appropriate
- Prioritize voice and critical traffic
- Apply QoS consistently across the entire path

---

### 2.10 Network Management

Network management involves monitoring, maintaining, and troubleshooting network devices to ensure reliable network operation.

#### 2.10.1 Cisco Discovery Protocol (CDP)

Cisco Discovery Protocol (CDP) is a Cisco proprietary Layer 2 protocol used to discover information about directly connected Cisco devices.

CDP allows administrators to learn information about neighboring devices:
- Device name
- Device type
- IP address
- Interface information
- Device capabilities

CDP is commonly used to map Cisco network topologies and assist with troubleshooting.

#### 2.10.2 Link Layer Discovery Protocol (LLDP)

Link Layer Discovery Protocol (LLDP) is an open-standard Layer 2 discovery protocol.

LLDP performs a similar function to CDP but can operate in multi-vendor environments.

LLDP allows devices to exchange information such as:
- Device identity
- Capabilities
- Interface information
- Management addresses

LLDP is commonly used when devices from multiple manufacturers are present in the network.

#### 2.10.3 Network Time Protocol (NTP)

Network Time Protocol (NTP) synchronizes the clocks of network devices.

Accurate time synchronization is important for:
- Log analysis
- Troubleshooting
- Security monitoring
- Event correlation

NTP uses a hierarchical structure called strata.

- Stratum 0 devices are highly accurate time sources such as atomic clocks or GPS clocks
- Stratum 1 servers receive time directly from Stratum 0 devices
- Stratum 2 servers synchronize with Stratum 1 servers
- Additional strata continue further down the hierarchy

Lower stratum numbers indicate more accurate time sources.

#### 2.10.4 Simple Network Management Protocol (SNMP)

Simple Network Management Protocol (SNMP) is used to monitor and manage network devices.

SNMP enables administrators to:

- Monitor network performance
- Collect device statistics
- Detect faults
- Manage devices remotely

An SNMP environment consists of three main components:

- SNMP Manager
- SNMP Agent
- Management Information Base (MIB)

The SNMP manager is the system that collects and analyzes information.

The SNMP agent runs on the managed device and provides access to device information.

The MIB contains the information that can be monitored and managed.

#### 2.10.5 SNMP Operations

SNMP managers communicate with agents using several message types.

GET operations retrieve information from a managed device.

SET operations modify information on a managed device.

TRAP messages are sent automatically by the agent to notify the manager of important events.

Examples:
- Interface failures
- Device restarts
- Resource shortages

#### 2.10.6 SNMP Versions

Three major SNMP versions exist.

SNMPv1:

- Original version
- Uses community strings
- Limited security

SNMPv2c:

- Improved performance
- Supports bulk data transfers
- Still relies on community strings

SNMPv3:

- Provides authentication
- Provides message integrity
- Supports encryption
- Most secure SNMP version

SNMPv3 is the preferred version in modern networks.

#### 2.10.7 Management Information Base (MIB)

The Management Information Base (MIB) is a database that stores information about a managed device.

The SNMP manager uses information stored in the MIB to monitor device operation.

Examples of information stored in a MIB:
- Interface statistics
- CPU utilization
- Memory usage
- Routing information

Each managed value is identified using an Object Identifier (OID).

#### 2.10.8 Syslog

Syslog is a protocol used to collect and store log messages generated by network devices.

Syslog provides:
- Event monitoring
- Troubleshooting information
- Historical logging
- Security auditing

Devices can send log messages to a centralized Syslog server, allowing administrators to manage logs from multiple devices in one location.

#### 2.10.9 Syslog Severity Levels

Each Syslog message contains a severity level indicating the importance of the event.

Severity levels range from 0 to 7.

| Level | Description |
|---------|------------|
| 0 | Emergency |
| 1 | Alert |
| 2 | Critical |
| 3 | Error |
| 4 | Warning |
| 5 | Notification |
| 6 | Informational |
| 7 | Debugging |

Lower numbers indicate more severe events.

#### 2.10.10 Device Storage Locations

Cisco devices use several storage locations.

RAM:

- Stores the running configuration
- Stores active processes
- Contents are lost after a reboot

NVRAM:

- Stores the startup configuration
- Contents are retained after a reboot

Flash Memory:

- Stores the Cisco IOS image
- Stores other system files
- Contents are retained after a reboot

Understanding the purpose of each storage location is important for device management and troubleshooting.

---

### 2.11 Network Design

Network design focuses on creating networks that are scalable, reliable, resilient, and capable of supporting future growth. Modern enterprise networks use hierarchical designs to simplify management, improve performance, and reduce the impact of failures.

#### 2.11.1 Hierarchical Network Design

A hierarchical network divides the network into multiple layers, each with a specific function.

Benefits of a hierarchical design:
- Improved scalability
- Simplified management
- Easier troubleshooting
- Better performance
- Increased resilience

Hierarchical networks support growth without requiring a complete redesign of the infrastructure.

#### 2.11.2 Three-Tier Network Model

The three-tier model divides the network into three layers:
- Access Layer
- Distribution Layer
- Core Layer

Each layer performs specific functions and contributes to overall network efficiency and scalability.

#### 2.11.3 Access Layer

The Access Layer provides connectivity for end devices.

Functions of the Access Layer:
- Connecting end devices to the network
- Providing access to network resources
- Forwarding traffic toward higher layers

Devices commonly connected at the access layer:
- PCs
- Printers
- IP phones
- Wireless access points

#### 2.11.4 Distribution Layer

The Distribution Layer acts as the boundary between the access and core layers.

Functions of the Distribution Layer:
- Routing between networks
- Implementing security policies
- Applying Quality of Service (QoS)
- Limiting broadcast domains
- Aggregating traffic from access switches

The distribution layer helps contain network failures and improves overall stability.

#### 2.11.5 Core Layer

The Core Layer serves as the high-speed backbone of the network.

Functions of the Core Layer:
- Fast transport of traffic
- Interconnecting distribution layers
- Providing high availability
- Supporting fault tolerance

The core layer is optimized for speed and reliability.

#### 2.11.6 Two-Tier Network Model

A two-tier network combines the distribution and core functions into a single layer.

This design is known as a collapsed core design.

Advantages:
- Reduced cost
- Simpler deployment
- Easier management

Two-tier designs are commonly used in smaller campus environments.

#### 2.11.7 Switched Networks

Modern networks use switched LANs instead of flat hub-based networks.

Advantages of switched networks:
- Better performance
- Improved traffic management
- Enhanced security
- Support for QoS
- Support for voice, video, and wireless services

Switched networks form the foundation of modern enterprise networks.

#### 2.11.8 Scalability

A scalable network can grow without sacrificing reliability or performance.

Methods used to improve scalability:
- Redundancy
- Multiple links
- Scalable routing protocols
- Wireless expansion

A scalable design allows organizations to expand while maintaining network availability.

#### 2.11.9 Redundancy

Redundancy reduces the impact of failures by eliminating single points of failure.

Methods of redundancy:
- Duplicate devices
- Backup links
- Failover services

Redundant paths provide alternative routes for traffic when failures occur.

Because redundant Layer 2 links can create loops, Spanning Tree Protocol (STP) is required to prevent switching loops.

#### 2.11.10 Failure Domains

A failure domain is the area of the network affected by a device or link failure.

Good network design minimizes failure domains so that problems affect only a limited portion of the network.

Hierarchical networks help contain failures and improve overall network stability.

#### 2.11.11 EtherChannel

EtherChannel combines multiple physical links into a single logical connection.

Benefits:
- Increased bandwidth
- Load balancing
- Redundancy
- Simplified management

Because multiple links appear as a single logical link, traffic can be distributed across all available connections.

#### 2.11.12 Wireless Network Expansion

Wireless LANs (WLANs) provide flexibility and support network growth.

Advantages of wireless networking:
- Mobility
- Reduced cabling requirements
- Easier expansion
- Support for mobile devices

Important design considerations:
- Coverage requirements
- Interference
- Security
- Device compatibility

#### 2.11.13 OSPF and Scalable Networks

Open Shortest Path First (OSPF) is a link-state routing protocol commonly used in large enterprise networks.

OSPF improves scalability by:
- Supporting hierarchical network designs
- Using areas to organize the network
- Maintaining neighbor relationships
- Synchronizing routing information
- Quickly adapting to topology changes

These features make OSPF suitable for large and complex networks.

#### 2.11.14 Switch Selection Considerations

When selecting switches, administrators should consider:
- Cost
- Port density
- Port speed
- Reliability
- Scalability
- Power requirements

The chosen switch should meet current requirements while allowing future growth.

#### 2.11.15 Power over Ethernet (PoE)

Power over Ethernet (PoE) allows Ethernet cables to carry both data and electrical power.

Common devices that use PoE:
- IP phones
- Wireless access points
- Security cameras

PoE simplifies installations by reducing the need for separate power connections.

#### 2.11.16 Multilayer Switches

Multilayer switches combine Layer 2 switching and Layer 3 routing capabilities.

Benefits:
- High-speed packet forwarding
- Support for routing functions
- Reduced latency
- Improved scalability

Multilayer switches are commonly deployed in distribution and core layers.

#### 2.11.17 Router Functions

Routers forward packets between different networks using destination IP addresses.

Key router functions:
- Path selection
- Inter-network communication
- Broadcast containment
- Traffic filtering
- Security enforcement

Routers also provide default gateway services for end devices and enable communication between different networks.

---

### 2.12 Network Troubleshooting

Network troubleshooting is the process of identifying, isolating, and resolving network problems using a structured and systematic approach.

#### 2.12.1 Network Documentation

Accurate documentation is essential for effective troubleshooting.

Common network documentation:
- Physical topology diagrams
- Logical topology diagrams
- Network device documentation
- Network performance baseline documentation

Documentation should be kept current and stored in a central location.

#### 2.12.2 Physical and Logical Topologies

A physical topology shows how devices are physically connected.

A logical topology shows how traffic flows through the network and how devices communicate.

Both are important when locating and isolating network problems.

#### 2.12.3 Network Baseline

A network baseline represents normal network performance under normal operating conditions.

Baseline information can be used to:
- Compare current performance against expected performance
- Identify congestion and bottlenecks
- Detect abnormal behavior
- Assist with capacity planning

Common metrics collected:

- Interface utilization
- CPU utilization
- Traffic patterns

#### 2.12.4 Troubleshooting Process

Using a structured troubleshooting process reduces troubleshooting time and improves accuracy.

A common troubleshooting process:
1. Define the problem
2. Gather information
3. Analyze information
4. Eliminate possible causes
5. Propose a hypothesis
6. Test the hypothesis
7. Solve the problem and document the solution

#### 2.12.5 Gathering Information

Information gathering is one of the most important troubleshooting steps.

Useful information:
- Error messages
- User reports
- Device status
- Network documentation
- Baseline information

Questions should be used to determine:
- What is not working
- Who is affected
- When the problem occurs
- Whether the problem is constant or intermittent
- Whether anything recently changed

#### 2.12.6 Troubleshooting with Layered Models

The OSI and TCP/IP models can be used to isolate network problems.

By identifying the layer where the problem occurs, troubleshooting becomes more efficient.

Examples:
- Physical layer issues involve cables and interfaces.
- Data link layer issues involve switching and frame forwarding.
- Network layer issues involve IP addressing and routing.
- Transport layer issues often involve ACLs or NAT.
- Application layer issues involve network services and applications.

#### 2.12.7 Troubleshooting Methods

Several structured troubleshooting approaches can be used.

##### Bottom-Up

Troubleshooting begins at the Physical Layer and moves upward through the OSI model.

This approach is useful when physical connectivity problems are suspected.

##### Top-Down

Troubleshooting begins at the Application Layer and moves downward.

This approach is useful when applications are failing but lower-layer connectivity appears operational.

##### Divide-and-Conquer

Troubleshooting begins at a middle layer, typically the Network Layer.

Results determine whether troubleshooting continues upward or downward.

This is one of the most commonly used troubleshooting approaches.

##### Follow-the-Path

The administrator follows the traffic path from source to destination to locate the failure point.

##### Substitution

A suspected faulty device or component is replaced with a known working component.

##### Comparison

A non-functioning device is compared to a properly functioning device to identify differences.

##### Educated Guess

An experienced administrator uses previous knowledge and experience to identify likely causes.

#### 2.12.8 Troubleshooting Tools

Various software and hardware tools assist with troubleshooting.

Common tools:
- Network Management Systems (NMS)
- Knowledge bases
- Baselining tools
- Protocol analyzers
- Syslog servers
- Cable testers
- Cable analyzers
- Digital multimeters

#### 2.12.9 Protocol Analyzers

A protocol analyzer captures and examines network traffic.

Protocol analyzers can:
- Capture packets
- Analyze protocol operation
- Identify communication failures
- Troubleshoot performance issues

Wireshark is a common protocol analyzer.

#### 2.12.10 Syslog

Syslog is used to collect and store log messages from network devices.

Benefits:
- Centralized logging
- Historical event tracking
- Easier troubleshooting
- Faster problem identification

Cisco devices classify log messages into severity levels ranging from:
- Level 0 (Emergencies)
- Level 7 (Debugging)

Lower numbers indicate more severe events.

#### 2.12.11 Physical Layer Troubleshooting

Common symptoms of Physical Layer problems:
- Loss of connectivity
- Poor performance
- High CPU utilization
- Network congestion
- Error messages

Common causes:
- Faulty cables
- Loose connections
- Hardware failures
- Electromagnetic interference (EMI)
- Interface configuration errors
- Duplex mismatches
- Device overload

#### 2.12.12 Data Link Layer Troubleshooting

Common symptoms:
- Connectivity failures
- Poor performance
- Excessive broadcasts
- Line protocol down messages

Common causes:
- Encapsulation errors
- Address mapping problems
- Framing errors
- STP failures
- Switching loops

#### 2.12.13 Network Layer Troubleshooting

Common symptoms:
- Complete network failure
- Partial connectivity
- Suboptimal performance

Common causes:
- Incorrect routing information
- Missing routes
- Neighbor adjacency failures
- Topology database inconsistencies
- Recent network changes

When troubleshooting, routing tables and neighbor relationships should always be verified.

#### 2.12.14 Transport Layer Troubleshooting

Transport layer issues are often related to ACLs and NAT.

Common ACL problems:
- Incorrect interface placement
- Incorrect traffic direction
- Incorrect rule order
- Implicit deny statements
- Incorrect port numbers
- Incorrect wildcard masks

Common NAT issues:
- DHCP communication problems
- DNS issues
- SNMP communication issues
- Tunneling and encryption protocol incompatibilities

#### 2.12.15 Application Layer Troubleshooting

Application layer troubleshooting focuses on network services and applications.

Common services:
- DNS
- HTTP
- FTP
- TFTP
- SMTP
- POP
- SSH
- Telnet
- SNMP

Failures at this layer often result in services becoming unreachable even when lower-layer connectivity exists.

#### 2.12.16 Troubleshooting End-to-End Connectivity

A common troubleshooting workflow for connectivity issues is:
1. Verify the Physical Layer.
2. Check for duplex mismatches.
3. Verify local addressing.
4. Verify the default gateway.
5. Verify the routing path.
6. Verify Transport Layer operation.
7. Verify ACL operation.
8. Verify DNS functionality.

This bottom-up approach systematically eliminates possible causes until the fault is identified.

#### 2.12.17 Common Troubleshooting Utilities

Several utilities are frequently used during troubleshooting:
- ``ping`` — Tests connectivity to a destination.
- ``traceroute`` — Displays the path packets take through the network.
- ``show interfaces`` — Displays interface status and errors.
- ``show ip route`` — Displays the routing table.
- ``show ip interface brief`` — Displays interface status summaries.
- ``show protocols`` — Displays Layer 3 protocol status.
- ``arp`` — Displays ARP cache entries.
- ``nslookup`` — Verifies DNS name resolution.

These tools are commonly used to isolate and verify network problems.