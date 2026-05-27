#!/bin/bash

set -v

./gen_countries.rb > countries-iso.ttl
./gen_regions.rb > regions-ica.ttl
./gen_super_regions.rb > super-regions-ica.ttl


for i in countries-iso regions-ica super-regions-ica; do
    rdfpipe -i ttl -o application/rdf+xml $i.ttl >$i.skos
done
