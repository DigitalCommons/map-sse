#!/bin/env ruby
require 'date'
require 'csv'
require './scheme'

class SuperRegion < Scheme::Term
  attr_reader :id, :name
  def initialize(base_url, id, name)
    super(uri: base_url+id.to_s,
          scheme: base_url,
          pref_label: name)
    @id = id
    @name = name
  end
end

languages = ['EN'] #,'ES','FR','DE','ZH']

base_url = 'http://purl.org/essglobal/standard/super-regions-ica/'
scheme = Scheme.new(
  base_url: base_url,
  title: "Super Regions",
  description: "A controlled vocabulary of ICA country super-regions for SSE",
  modified: Date.today.to_s,
  created: '2021-02-22',
  terms: CSV.foreach('ica-super-regions.tsv', col_sep: "\t",headers: true)
            .collect {|r| SuperRegion.new(base_url, *r.fields) }
)

scheme.write
