#!/bin/env ruby
require 'carmen'
require 'i18n_data'
require 'date'
require 'ostruct'
require 'csv'

class Scheme
  attr_reader :base_url, :title, :modified, :created, :terms

  def self._prefix_sort(**prefixes)
    prefixes
      .to_a
      .collect {|e| [e[0].to_sym, e[1]] }
      .sort {|a, b| a[1].length <=> b[1].length }
  end

  # shorten a uri with prefixes / base_url if poss
  def _suri(value)
    if (value.start_with? @base_url)
      return value.slice(@base_url.length..-1)
    end

    @prefixes.each do |p|
      if (value.start_with? p[1])
        return p[0].to_s+':'+value.slice(p[1].length..-1)
      end
    end
    
    return value
  end

  def uri(value)
    value.gsub('<', '\u0096').gsub('>', '%\u0098')
  end

  def suri(value)
    uri(_suri(value))
  end

  def qstr(value)
    value.gsub(/\\/, '\\\\').gsub(/'/, '\\\'')
  end
  
  def qqstr(value)
    value.gsub(/\\/, '\\\\').gsub(/"/, '\\"')
  end
  
  def initialize(base_url:, title:,
                 modified:, created:,
                 description:,
                 terms:, prefixes: {}, languages: nil)
    @base_url = base_url
    @title = title
    @description = description
    @modified = modified
    @created = created
    @terms = terms
    @languages = languages

    @prefixes = Scheme._prefix_sort(
      **prefixes,
      dc: "http://purl.org/dc/elements/1.1/",
      dcterms: "http://purl.org/dc/terms/",
      rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      rdfs: "http://www.w3.org/2000/01/rdf-schema#",
      skos: "http://www.w3.org/2004/02/skos/core#",
      xml: "http://www.w3.org/XML/1998/namespace",
      xsd: "http://www.w3.org/2001/XMLSchema#",
      ossr: "http://data.ordnancesurvey.co.uk/ontology/spatialrelations/",
    )
  end

  def write(iostream = $stdout)
    @prefixes.sort.each do |prefix, url|
      iostream.puts "@prefix #{prefix}: <#{url}> ."
    end

    iostream.puts <<HERE
@base <#{uri @base_url}> .

<> a skos:ConceptScheme ;
    dc:title "#{qqstr @title}";
    dc:description "#{qqstr @description}" ;
    dc:creator "Solidarity Economy Association";
    dc:language "en-en";
    dcterms:creator <http://solidarityeconomy.coop>; # ?
    dcterms:created "#{qqstr @created}"^^xsd:date;
    dcterms:publisher "ESSGLOBAL";
    dc:publisher <http://www.ripess.org/>;
    dc:modified "#{qqstr @modified}"^^xsd:date.

HERE

    @terms.each do |term| 

      # Non-language specific
      iostream.puts <<HERE
<#{suri term.uri}> a skos:Concept;
    skos:inScheme <#{suri term.scheme}>;
HERE

      if (term.within)
        iostream.puts <<HERE
    ossr:within <#{suri term.within}>;
HERE
      end

      pref_labels = term.pref_label.respond_to?(:each_pair)? term.pref_label : {'EN'=>term.pref_label}
      languages = @languages || pref_labels.keys

      # Language-specific
      languages.each do |l|
        next unless pref_labels.has_key? l
        iostream.puts <<HERE
    skos:prefLabel "#{qqstr pref_labels[l]}"@#{l};
HERE
        #    skos:altLabel "#{term[:official]}";
      end
      
      iostream.puts '.'
    end
  end



  class Term
    attr_reader :uri, :scheme, :pref_label, :alt_labels, :within
    
    def initialize(uri:, scheme:, pref_label:, within: nil, alt_labels: [])
      @uri = uri
      @scheme = scheme
      @pref_label = pref_label
      @within = within
      @alt_labels = alt_labels
    end
  end
end


