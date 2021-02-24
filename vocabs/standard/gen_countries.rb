#!/bin/env ruby
require 'carmen'
require 'i18n_data'
require 'date'
require 'csv'
require './scheme'

Languages = ['EN','ES','FR','DE','ZH']

class Country < Scheme::Term
  attr_reader :id, :name, :region
  def initialize(base_url, region, carmen_country)
    super(uri: base_url+carmen_country.alpha_2_code, 
          scheme: base_url,
          pref_label: Languages.to_h {|l| [l, I18N[l][carmen_country.alpha_2_code]] })
    @id = carmen_country.alpha_2_code
    @name = name
    @region = region
  end
end

Countries = Carmen::Country.all
I18N = Languages.to_h {|l| [l, I18nData.countries(l)] }
Regions = CSV.foreach('iso-countries.tsv', col_sep: "\t",headers: true)
            .filter {|r| r[3] == 'true' }
            .to_h {|r| [r[0], r[7]] }


base_url = 'http://purl.org/essglobal/standard/countries/' # FIXME what was Colm's name?
scheme = Scheme.new(
  base_url: base_url,
  title: "Countries",
  description: "A controlled vocabulary of countries compatible with ISO-3166-2 for SSE",
  modified: Date.today.to_s,
  created: '2021-02-22',
  terms: Countries.collect do |c|
    Country.new(base_url, Regions[c.alpha_2_code], c)
  end
)
  
  
scheme.write
