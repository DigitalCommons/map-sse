#!/bin/env ruby
require 'carmen'
require 'i18n_data'
require 'date'
require 'csv'
require './scheme'

Languages = ['EN','ES','FR','DE','ZH']
Prefixes = {
  reg: 'http://purl.org/essglobal/standard/regions-ica/'
}

class Country < Scheme::Term
  attr_reader :id, :name, :region
  def initialize(base_url, region, carmen_country)
    super(uri: base_url+carmen_country.alpha_2_code, 
          scheme: base_url,
          within: region && Prefixes[:reg]+region,
          pref_label: Languages.to_h {|l| [l, I18N[l][carmen_country.alpha_2_code]] })
    @id = carmen_country.alpha_2_code
    @name = name
    @region = region
  end
end

Countries = Carmen::Country.all
I18N = Languages.to_h {|l| [l, I18nData.countries(l)] }
IcaRegionIds = CSV.foreach('ica-regions.tsv', col_sep: "\t", headers: true)
                 .to_h {|r| [r['Region'], r['RID']] }
IsoCountries = CSV.foreach('iso-countries.tsv', col_sep: "\t", headers: true)
                 .filter {|r| r['ISO-Code-Match?'] == 'true' }
                 .to_h {|r| [r['ISO-Code'], IcaRegionIds[r['Region']]] }


base_url = 'http://purl.org/essglobal/standard/countries-iso/'
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
