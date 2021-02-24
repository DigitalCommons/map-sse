#!/bin/env ruby
require 'date'
require 'csv'
require './scheme'

class Region < Scheme::Term
  attr_reader :id, :name, :super_region
  def initialize(base_url, id, name, super_region)
    super(uri: base_url+id.to_s,
          scheme: base_url,
          pref_label: name)
    @id = id
    @name = name
    @super_region = super_region
  end
end

languages = ['EN'] #,'ES','FR','DE','ZH']

base_url = 'http://purl.org/essglobal/standard/super-regions/'
scheme = Scheme.new(
  base_url: base_url,
  title: "Regions",
  description: "A controlled vocabulary of ICA country regions for SSE",
  modified: Date.today.to_s,
  created: '2021-02-22',
  terms: CSV.foreach('ica-regions.tsv', col_sep: "\t",headers: true)
            .collect {|r| Region.new(base_url, *r.fields) }
)

scheme.write

