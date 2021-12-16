#!/bin/env ruby
require 'carmen'
require 'i18n_data'
require 'date'
require 'ostruct'
require 'csv'

# test for
# non-lang labels
# multiple labels
# subdelimited labels
# escaped chars \; \t

# This writes a SKOS schema to a stream via #write
class Scheme
  attr_reader :base_uri, :title, :modified, :created, :terms

  KnownPrefixes = {
    dc: "http://purl.org/dc/elements/1.1/",
    dcterms: "http://purl.org/dc/terms/",
    skos: "http://www.w3.org/2004/02/skos/core#",
    xsd: "http://www.w3.org/2001/XMLSchema#", # for xsd:date
    
    ossr: "http://data.ordnancesurvey.co.uk/ontology/spatialrelations/", # for within
  }

  MandatoryPrefixes = [:dc, :dcterms, :skos, :xsd]

  def self._prefix_sort(**prefixes)
    prefixes
      .to_a
      .collect {|e| [e[0].to_sym, e[1]] }
      .sort {|a, b| a[1].length <=> b[1].length }
  end

  # shorten a uri with prefixes / base_uri if poss
  def _suri(value)
    if (value.start_with? @base_uri)
      return value.slice(@base_uri.length..-1)
    end

    @prefixes.each do |p|
      if (value.start_with? p[1])
        return p[0].to_s+':'+value.slice(p[1].length..-1)
      end
    end
    
    return value
  end

  def uri(value)
    q = value.gsub('<', '\u0096').gsub('>', '%\u0098')
    # don't quote anything with a prefix (except http/https)
    return "<#{q}>" if value =~ /^https?:/i
    return q if value =~ /:/
    return "<#{q}>"
  end

  def suri(value)
    uri(_suri(value))
  end

  def qstr(value)
    "'"+value.to_s.gsub(/\\/, '\\\\').gsub(/'/, '\\\'')+"'"
  end
  
  def qqstr(value)
    '"'+value.to_s.gsub(/\\/, '\\\\').gsub(/"/, '\\"')+'"'
  end

  def qqstrs(values, indent: false)
    qqvalues =
      case values
      when String
        [qqstr(values)] # single value string (Strings are Enumerable)
        
      when Hash
        # A hash represents localised values, with keys the language
        # (may be nil for no language), and values the phrases
        # (may be an array for a list of phrases, or nil if none)
        values.flat_map do |key, val|
          # compute the postfix from the key, if any
          postfix = if key
                      '@'+key
                    else
                      ''
                    end
          
          case val
          when nil # Empty value
            []
            
          when Array # Multiple values
            val.collect do |v|
              qqstr(v)+postfix 
            end
            
          else # Just one value
            qqstr(val)+postfix
          end
        end
        
      when Enumerable
        values.map do |key, val|
          qqstr key # plain list of values
        end.join(", ")
        
      else
        [qqstr(values.to_s)] # single non-string value
        
      end

    delim = if indent
              indent = 4 unless indent.is_a? Numeric
              ",\n" + (" " * indent)
            else
              ", "
            end
    

    return qqvalues.join(delim)
  end
  
  def initialize(base_uri:, title:,
                 modified:, created:,
                 description:,
                 terms:, prefixes: {}, languages: nil)
    @base_uri = base_uri
    @title = title
    @description = description
    @modified = modified
    @created = created
    @terms = terms
    @languages = languages

    @prefixes = Scheme._prefix_sort(
      **prefixes,
      **KnownPrefixes.slice(*MandatoryPrefixes)
    )
  end

  # Write a skos property
  # Note, expects values to be a single string or a hash of language => value strings
  def write_text_property(label, values, iostream)
    # Normalise values into a hash of language terms
    unless values.respond_to?(:keys)
      values = { nil => values.to_s }
    end

    # Enforce elements for the schema-wide langage list, if set, else
    # just use those available
    if @languages
      @languages.each do |lang|
        values = values.merge({lang => nil}) 
      end
    end
    
    # Language-specific terms
    iostream.puts <<HERE
    #{label}
        #{qqstrs values, indent: 8};
HERE
  end
  
  def write(iostream = $stdout)
    @prefixes.sort.each do |prefix, url|
      iostream.puts "@prefix #{prefix}: <#{url}> ."
    end

    iostream.puts <<HERE
@base #{uri @base_uri} .

<> a skos:ConceptScheme;
    dc:creator "Solidarity Economy Association";
    dc:description
        #{qqstrs @description, indent: 8};
    dc:language "en-en";
    dc:modified #{qqstr @modified}^^xsd:date;
    dc:publisher <http://www.ripess.org/>;
    dc:title
        #{qqstrs @title, indent: 8};
    dcterms:created #{qqstr @created}^^xsd:date;
    dcterms:creator <http://solidarityeconomy.coop>;
    dcterms:publisher "ESSGLOBAL";
.
HERE

    @terms.each do |term| 

      # Non-language specific
      iostream.puts <<HERE
#{suri term.uri} a skos:Concept;
    skos:inScheme #{suri term.scheme};
HERE

      term.properties.each_pair do |label, value|
        write_text_property label, value, iostream
      end
      
      iostream.puts '.'
    end
  end


  # This represents a SKOS term
  class Term
    attr_reader :uri, :scheme, :properties
    
    def initialize(uri:, scheme:, properties:)
      @uri = uri
      @scheme = scheme
      @properties = properties
    end
  end
end


