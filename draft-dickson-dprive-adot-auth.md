---
title: Authenticated DNS over TLS to Authoritative Servers
abbrev: Authenticated ADoT
docname: draft-dickson-dprive-adot-auth-00
category: info

ipr: trust200902
area: Operations
workgroup: DPRIVE Working Group
keyword: Internet-Draft

stand_alone: yes
pi: [toc, sortrefs, symrefs]

author:
 -
    ins: B Dickson
    name: Brian Dickson
    organization: GoDaddy
    email: brian.peter.dickson@gmail.com

normative:
  RFC2119:

informative:

--- abstract

This Internet Draft proposes a mechanism for DNS resolvers to discover support for TLS transport to authoritative DNS servers, to validate this indication of support, and to authenticate the TLS certificates involved.

This requires that the name server _names_ are in a DNSSEC signed zone.

This also requires that the delegation of the zone served is protected by {{?I-D.dickson-dnsop-ds-hack}}, since the NS names are the keys used for discovery of TLS transport support.

FIXME

--- middle

# Introduction

The Domain Name System (DNS) predates any concerns over privacy, including the possibility of pervasive surveillance. The original transports for DNS were UDP and TCP, unencrypted. Additionally, DNS did not originally have any form of data integrity protection, including against active on-path attackers.

DNSSEC (DNS Security extensions) added data integrity protection, but did not address privacy concerns. The original DNS over TLS {{RFC7858}} and DNS over HTTPS {{RFC8484}} specifications were limited to client-to-resolver traffic.

The remaining privacy component is recursive-to-authoritative servers. This Internet Draft is designed to provide a solution to this problem.

FIXME

More infomation can be found in {{?I-D.nottingham-for-the-users}}. (An exmple
of an informative reference to a draft in the middle of text. Note that 
referencing an Internet draft involves replacing "draft-" in the name with 
"I-D.")

# Conventions and Definitions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 {{RFC2119}} {{!RFC8174}}
when, and only when, they appear in all capitals, as shown here.

# Background

The result is that the parental side of the zone cut has records needed for DNS resolution  which are not signed  and not validatable.

# Purpose, Requirements, and Limitations

Authoritative DNS over TLS is intended to provide the following for communications from recursive resolvers to authoritative servers:
* Enable discovery of support for ADoT by use of SVCB, specifically using the RRTYPE "DNS" (service binding for DNS)
* Validate the name server names serving specific domain names/zones, by use of DS records which encode the NS delegation names
* Validate the IP addresses of those name server names, by use of DS records for the domain serving the NS names, or by indirect validation of NS names of the server names for the NS domain
* Validate the TLS certificates used for the TLS connection to the server names at the corresponding IP addresses, either directly (End Entity) or indirectly (Sigining Certifiate) obtained by TLSA lookup
* Authenticate the server name by requiring a match between the server name and the TLS certificate sent by the server on the TLS connection
* Provide privacy via the end-to-end encrypted transport provided by TLS session which was validated by the above components

This protocol depends on correct configuration and operation of the respective components, and that those are maintained according to Best Current Practices:
* DS records for the protection of the delegation to the authoritive name servers
* DNSSEC signing of the zone serving the authoritative name servers' names
* DNSSEC signing of any other zones involved in serving the authoritative name servers' names (e.g. zones containing names of the name servers for the authoritative name servers).
* Proper management of key signing material for DNSSEC
* Ongoing management of RRSIGs on a timely basis (avoiding RRSIG expiry)
* Ensuring TLSA records are kept synchronized with the TLS certificates for the name servers in question doing ADoT
* Proper management of TLS private keys for TLS certificates

There are external dependencies that impact the system security of any DNSSEC zone, which are inherently unavoidable in establishing this scheme. Specifially, the original DS record enrollment and any updates to the DS records involved in DNSSEC delegations are presumed secure and outside of the scope of the DNS protocol per se.

Other risks relate to normal information security practices, including access controls, role based access, audits, multi-factor authentication, multi-party controls, etc. These are out of scope for this protocol itself.

# New SVCB Binding for DNS and DoT

(Note: To be separated out into its own draft and expanded fully.)
This SVCB binding will be given the RRTYPE value {TBD} with mnemonic name DNS.

## Default Ports for DNS

This scheme uses an SVCB binding for DNS. The binding has default ports UDP/53 and TCP/53 as the default-alpn. These are assumed unless "no-default-alpn" is added as an optional SvcParam.

## Optional Port for DoT

This scheme uses the defined ALPN for DNS-over-TLS with the assigned label "dot". Use of ADoT is signaled if and only if the the SvcParam of "alpn=dot" is present.

### Example

## DANE TLSA Records for ADoT

The presence of ADoT requires additionally that a TLSA record be provided. This record will be published at the locaion _853._tcp.NS_NAME, where NS_NAME is the name of the name server. Any valid TLSA record type is permitted. The use of types 0 and 1 is NOT RECOMMENDED. The use of type 2 TLSA records may provide more flexibility in provisioning, including use of wild cards.

### Example

## Signaling DNS Transport for a Name Server

This transport signaling MUST only be trusted if the name server names for the domain containing the relevant name servers' names are protected with {{?I-D.dickson-dnsop-ds-hack}} (the DS hack).
The name servers must also be in a DNSSEC signed zone (i.e. securely delegated where the delegation has been successfully DNSSEC validated).
Similarly, any other NS names must be protected with {{?I-D.dickson-dnsop-ds-hack}}, and glue A and AAAA records required must also be protected with {{?I-D.dickson-dnsop-ds-hack}}.

The specific DNS transport that a name server supports is indicated via use of an RRSet of RRTYPE "DNS". This is a SVCB binding, and normally will use the TargetName of "." (meaning the same name). The default ALPN (transport mechanisms) are TCP/53 and UDP/53. The ADoT transport support is signaled by "alpn=dot". There is an existing entry for "dot" in the ALPN table, with port TCP/853.

### Example

## Signaling DNS Transport for a Domain

A domain inherits the signaled transport for the name servers serving the domain.

This transport signaling MUST only be trusted for use of ADoT if the delegated name server names for the domain are protected with {{?I-D.dickson-dnsop-ds-hack}}.

The delegation to NS names "A" and "B", along with the DS record protecting/encoding "A" and "B", results in the DNS transport that is signaled for "A" and "B" being applied to the domain being delegated. This transport will include ADoT IFF the transport for "A" and "B" has included ADoT via DNS records.

### Example

# Validation Using DS Records, DNS Records, TLSA Records, and DNSSEC Validation

These new DS records are used to validate corresponding delegation records and glue, as follows:
- NS records are validated using {TBD1}
- Glue A records (if present) are validated using {TBD2}
- Glue AAAA records (if present) are validated using {TBD3}

The same method used for constructing the DS records, is used to validate their contents. The algorithm is replicated with the corresponding inputs, and the hash compared to the published DS record(s).

# Signaling Support and Desire for ADoT

## Server Side Support Signaling

A DNS server (e.g. recursive resolver or forwarder) MAY signal to clients that it offers the use of ADoT.
The mechanism used is to set the EDNS option "ADOTA".
The values for this option are "Always", "Upon Request", and "Never".
The value "Always" indicates the server will always attempt to use ADoT without regards to client requests for ADoT.
The value "Upon Request" indicates that the server will ONLY use ADoT for upstream queries if the client requests that ADoT be used.
These values have no effect on answers served from the resolver's cache.
(The "Never" case is unusual, in that it signals the server understands the option, but does not perform ADoT. Generally this would be used to allow a client to track changes in the status, if the client is interested in uses of ADoT.)

## Client Side Desire Signaling

A DNS client (e.g. stub or forwarder) MAY signal the desire to have the resolver use ADoT.
The mechanism used is to set the EDNS option "ADOTD".
The values for this option are "Force", "If Available", and "Never".
The value "Force" indicates the server should attempt to use ADoT, and return a failure code of XXXX and an EDE value of YYYY if the authoritative server does not offer ADoT, or any other ADoT failure occurs.
The value "If Available" indicates that the server should use ADoT for upstream queries if it is availble, but SHOULD NOT allow any downgrades if the authoritative server signals that ADoT is available.
These values have no effect on answers served from the resolver's cache.
(The "Never" case is unusual, in that it signals the client understands the option, but does not perform ADoT. Generally this would be used to allow a server to track changes in the client base, so the server operator can make informed decisions about enabling ADoT.)

# Security Considerations

As outlined above, there could be security issues in various use
cases.

# IANA Considerations

This document has no IANA actions.
(Well, actually, TBD1, TBD2, and TBD3 need to be assigned from the DNSSEC DNSKEY Algorithm Table.)

--- back

# Acknowledgments
{:numbered="false"}

Thanks to everyone who helped create the tools that let everyone use Markdown to create 
Internet Drafts, and the RFC Editor for xml2rfc.

Thanks to Dan York for his Tutorial on using Markdown for writing IETF drafts.

Thanks to YOUR NAME HERE for contributions, reviews, etc.
