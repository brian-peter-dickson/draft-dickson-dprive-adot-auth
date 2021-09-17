%%%
title = "Authenticated DNS over TLS to Authoritative Servers"
abbrev = "Authenticated ADoT"
docName = "draft-dickson-dprive-adot-auth"
category = "info"

[seriesInfo]
name = "Internet-Draft"
value = "draft-dickson-dprive-adot-auth-01"
stream = "IETF"
status = "informational"


ipr = "trust200902"
area = "Operations"
workgroup = "DPRIVE Working Group"
keyword = ["Internet-Draft"]

[pi]
toc = "yes"
sortrefs = "yes"
symrefs = "yes"
stand_alone = "yes"

[[author]]
initials = "B."
surname = "Dickson"
fullname = "Brian Dickson"
organization = "GoDaddy"
  [author.address]
  email = "brian.peter.dickson@gmail.com"

%%%


.# Abstract

This Internet Draft proposes a mechanism for DNS resolvers to discover support for TLS transport to authoritative DNS servers, to validate this indication of support, and to authenticate the TLS certificates involved.

This requires that the name server _names_ are in a DNSSEC signed zone.

This also requires that the delegation of the zone served is protected by [@?I-D.dickson-dnsop-ds-hack], since the NS names are the keys used for discovery of TLS transport support.

{mainmatter}
{{README.md}}
{backmatter}

# Acknowledgments

Thanks to everyone who helped create the tools that let everyone use Markdown to create 
Internet Drafts, and the RFC Editor for xml2rfc.

Thanks to Dan York for his Tutorial on using Markdown (specificially mmark) for writing IETF drafts.

Thanks to YOUR NAME HERE for contributions, reviews, etc.
