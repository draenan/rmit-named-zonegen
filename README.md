# named-zonegen.sh - Generate BIND zone statements from Infoblox API query

We were about to have a planned network outage that would take out our
Infoblox-based DNS servers, so we needed to spin up a secondary DNS server at
our Internet provider that would serve the zones while the Infoblox grid was
offline.  This script was created as a Proof of Concept for the benefit of the
people involved in order to ease the process of generating named.conf entries
for the new server.

Essentially it queries the Infoblox API for a list of zones that the Grid is
authoritative for, and uses the results to build a series of "zone" statements
suitable for use with BIND.

