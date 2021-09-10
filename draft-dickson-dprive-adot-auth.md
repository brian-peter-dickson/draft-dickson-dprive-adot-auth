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

FIXME

This requires that the name server _names_ are in a DNSSEC signed zone.

This also requires that the delegation of the zone served is protected by {{?I-D.dickson-dnsop-ds-hack}}, as the NS name is the key used for discovery of TLS transport support.

--- middle

# Introduction

There are new privacy goals and DNS server capability discovery goals, which cannot be met without the ability to validate the name of the name servers for a given domain at the delegation point.

Specifically, a query for NS records over an unprotected transport path returns results which do not have protection from tampering by an active on-path attacker, or against successful cache poisoning attackes.

This is true regardless of the DNSSEC status of the domain containing the authoritative information for the name servers for the queried domain.

For example, querying for the NS records for "example.com", at the name servers for the "com" TLD, where the published com zone has "example.com NS ns1.example.net", is not protected against MITM attacks, even if the domain "example.net" (the domain serving records for "ns1.example.net") is DNSSEC signed.

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

The methods developed for adding security to the Domain Name System, collectively refered to as DNSSEC, had as a primary requirement that they be backward compatible. The original specifications for DNS used the same Resourc Record Type (RRTYPE) on both the parent and child side of a zone cut (the NS record). The main goal of DNSSEC was to ensure data integrity by using cryptographic signatures. However, owing to this overlap in the NS record type  where the records above and below the zone cut have the same owner name  created an inherent conflict, as only the child zone is authoritative for these records.

The result is that the parental side of the zone cut has records needed for DNS resolution  which are not signed  and not validatable.

This has no impact on DNS zones which are fully DNSSEC signed (anchored at the IANA DNS Trust Anchor), but does impact unsigned zones  regardless of where the transition from secure to insecure occurs.

# New DNSKEY Algorithms {#algorithms}

These new DNSKEY algorithms conform to the structure requirements from {{!RFC4034}}, but are not themselves used as actual DNSKEY algorithms. They are assigned values from the DNSKEY algorithm table. No DNSKEY records are published with these algorithms.

They are used only as the input to the corresponding DS hashes published in the parent zone.

## Algorithm {TBD1}

This algorithm is used to validate the NS records of the delegation for the owner name.

The NS records are canonicalized and sorted according to the DNSSEC signing process {{!RFC4034}} section 6, including removing any label compression, and normalizing the character cases to lower case. The RDATA fields of the records are concatenated, and the result is hashed using the selected digest algorithm(s), e.g. SHA2-256 for DS digest algorithm 1.

### Example

Consider the delegation in the COM zone:
example.com NS ns1.example.net
example.com NS ns2.example.net

These two records have RDATA, which after canonicalization and sorting, would be
ns1.example.net
ns2.example.net

The input to the digest is the concatenation of those values in wire format.
For example, if the NS set's RDATA are "ns1.example.net" and "ns2.example.net",
the wire format would be

    0x03
    ns1
    0x07
    example
    0x03
    net
    0x00
    0x03
    ns2
    0x07
    example
    0x03
    net
    0x00

The Key Tag is calculated per {{!RFC4034}} using this value as the RDATA.

The resulting DS record is

    example.com DS KeyTag=0 Algorithm={TBD1} DigestType=2 \
    Digest=sha2-256()


## Algorithm {TBD2}

This algorithm is used to validate the glue A records required as glue for the delegation NS set associated with the owner name.

The glue A records are canonicalized and sorted according to the DNSSEC signing process {{!RFC4034}}, including removing any label compression, and normalizing the character cases. The entirety of the records are concatenated, and the result is hashed using the selected hash type(s), e.g. SHA2-256 for DS type 2.

### Example

For example, if the original "glue" (unsigned) A records are:

    ns1.example.net IN 3600 A standard-example-ip-1
    ns2.example.net IN 3600 A standard-example-ip-2

There would be one DS record for each of the glue "A" records, with the canonicalized
wire format of the entire record provided as input to the hash function.

    FIXME replace 0xfffffffx with real example IP addresses
    (per IANA table of example IPs)
    First A record's DS record:
    wire_format(ns1.example.net) 0x01 0x01 3600 0xfffffff0
    Second A record's DS record:
    wire_format(ns2.example.net) 0x01 0x01 3600 0xfffffff1

Then the resulting DS record is

    FIXME - who is the right owner to use here?
    (The glue owner name, or the zone owner name (bailiwick only)?)
    example.net DS KeyTag=0 Algorithm={TBD2} DigestType=2 \
    Digest=sha2-256()
    example.net DS KeyTag=0 Algorithm={TBD2} DigestType=2 \
    Digest=sha2-256()

## Algorithm {TBD3}

This algorithm is used to validate the glue AAAA records required as glue for the delegation NS set associated with the owner name.

The glue AAAA records are canonicalized and sorted according to the DNSSEC signing process {{!RFC4034}}, including removing any label compression, and normalizing the character cases. The entirety of the records are concatenated, and the result is hashed using the selected hash type(s), e.g. SHA2-256 for DS type 2.

### Example

For example, if the original "glue" (unsigned) AAAA records are:

    ns1.example.net IN 3600 AAAA standard-example-ip6-1
    ns2.example.net IN 3600 AAAA standard-example-ip6-2

There would be one DS record for each of the glue "A" records, with the canonicalized
wire format of the entire record provided as input to the hash function.

    FIXME replace 0xfffffffx with real example IP addresses
    (per IANA table of example IPs)
    First A record's DS record:
    wire_format(ns1.example.net) 0x01 0xXX 3600 0x32-hex-digits
    Second A record's DS record:
    wire_format(ns2.example.net) 0x01 0xXX 3600 0x32-hex-digits

Then the resulting DS record is

    FIXME - who is the right owner to use here?
    (The glue owner name, or the zone owner name (bailiwick only)?)
    example.net DS KeyTag=0 Algorithm={TBD2} DigestType=2 \
    Digest=sha2-256()
    example.net DS KeyTag=0 Algorithm={TBD2} DigestType=2 \
    Digest=sha2-256()

# Validation Using These DS Records

These new DS records are used to validate corresponding delegation records and glue, as follows:
- NS records are validated using {TBD1}
- Glue A records (if present) are validated using {TBD2}
- Glue AAAA records (if present) are validated using {TBD3}

The same method used for constructing the DS records, is used to validate their contents. The algorithm is replicated with the corresponding inputs, and the hash compared to the published DS record(s).

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
