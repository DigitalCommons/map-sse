#!/bin/env ruby
# coding: utf-8
# WORKAROUND for ActiveSupport error
require "active_support"
require "active_support/testing/time_helpers"

require 'carmen'
require 'i18n_data'
require 'date'
require 'csv'
require 'rdf'
require 'rdf/turtle'
require 'rdf/vocab'
#require './scheme'
require './known-prefixes.rb'

# Run this and pipe the output into countries-iso.ttl But copy the old
# one first!  The one thing you need to manually is translate the
# title "Countries", so you'll need the old ones and add the new ones.

Languages = ['EN','ES','FR','DE','ZH','KO']
Prefixes = {
  reg: 'http://purl.org/essglobal/standard/regions-ica/'
}

# if 0
# class Country < Scheme::Term
#   attr_reader :id, :name, :region
#   def initialize(base_url, region, carmen_country)
#     super(uri: base_url+carmen_country.alpha_2_code, 
#           scheme: base_url,
#           within: region && Prefixes[:reg]+region,
#           pref_label: Languages.to_h {|l| [l, I18N[l][carmen_country.alpha_2_code]] })
#     @id = carmen_country.alpha_2_code
#     @name = name
#     @region = region
#   end
# end
# end

Countries = Carmen::Country.all
I18N = Languages.to_h {|l| [l, I18nData.countries(l)] }
IcaRegionIds = CSV.foreach('ica-regions.tsv', col_sep: "\t", headers: true)
                 .to_h {|r| [r['Region'], r['RID']] }
IsoCountries = CSV.foreach('iso-countries.tsv', col_sep: "\t", headers: true)
                 .filter {|r| r['ISO-Code-Match?'] == 'true' }
                 .to_h {|r| [r['ISO-Code'], IcaRegionIds[r['Region']]] }


base_uri = 'http://purl.org/essglobal/standard/countries-iso/'


vocab = Class.new(RDF::Vocabulary(base_uri)) do
  ontology(
    base_uri,
    type: 'skos:ConceptScheme',
    'dc:creator': "Solidarity Economy Association",
    'dc:description': "A controlled vocabulary of countries compatible with ISO-3166-2 for SSE",
    'dc:language': "en-en",
    'dc:modified': Date.today,
    'dc:publisher': 'http://www.ripess.org/',
#    'dc:title': {de: "Länder",
#                 en: "Countries",
#                 es: "Países",
#                 fr: "Des Pays",
#                 ko: "국가",
#                 pt: "",
#                 zh: "国别"},
#  'dcterms:created': "2021-02-22"^^xsd:date;
#  'dcterms:creator': <http://solidarityeconomy.coop>;
#  'dcterms:publisher': "ESSGLOBAL" .
    
  )
  
  
  term :AD, inScheme: 'reg:I-EU-WE'
end


writer = RDF::Writer.for(:ttl)

# Dump the graph as TTL
puts writer.dump(
       vocab, nil,
       base_uri: base_uri,
       validate: false,
       canonicalize: false,
       standard_prefixes: true,
       prefixes: KnownPrefixes
     )

__END__

scheme = Scheme.new(
  base_url: base_url,
  title: "Countries",
  description: "A controlled vocabulary of countries compatible with ISO-3166-2 for SSE",
  modified: Date.today.to_s,
  created: '2021-02-22',
  prefixes: Prefixes,
  terms: Countries.collect do |c|
    Country.new(base_url, IsoCountries[c.alpha_2_code], c)
  end
)
  
  
scheme.write
