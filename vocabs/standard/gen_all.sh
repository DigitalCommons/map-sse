#!/bin/bash

set -v

./gen_countries.rb > countries.ttl
./gen_regions.rb > regions.ttl
./gen_super_regions.rb > super-regions.ttl


for i in countries regions super-regions; do
    rdfpipe -i ttl -o application/rdf+xml $i.ttl >$i.skos
done
