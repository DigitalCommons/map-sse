#!/bin/env ruby
require 'date'
require 'csv'
require './scheme'

Languages = ['EN'] #,'ES','FR','DE','ZH']
Prefixes = {
  sreg: 'http://purl.org/essglobal/standard/super-regions-ica/'
}
IcaSuperRegionIds = CSV.foreach('ica-super-regions.tsv', col_sep: "\t", headers: true)
                      .to_h {|r| [r['Super-region'], r['ID']] }
base_url = 'http://purl.org/essglobal/standard/regions-ica/'

class Region < Scheme::Term
  attr_reader :id, :srid, :name, :super_region
  def initialize(base_url, rid, name, srid, super_region)
    super(uri: base_url+rid.to_s,
          scheme: base_url,
          within: super_region && Prefixes[:sreg]+IcaSuperRegionIds[super_region],
          pref_label: name)
    @id = rid
    @srid = srid
    @name = name
    @super_region = super_region
  end
end

scheme = Scheme.new(
  base_url: base_url,
  title: "Regions",
  description: "A controlled vocabulary of ICA country regions for SSE",
  modified: Date.today.to_s,
  created: '2021-02-22',
  prefixes: Prefixes,
  terms: CSV.foreach('ica-regions.tsv', col_sep: "\t",headers: true)
            .collect {|r| Region.new(base_url, *r.fields) }
)

scheme.write

