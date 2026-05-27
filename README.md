# map-sse

Metadata Application Profile for the Social and Solidarity Economy.

This repository contains the source files for the MAP-SSE (previously referred to as DCAP-SSE). Until October 2016, these were maintained on a server at [essglobal.org](http://essglobal.org/dcap-sse/). A reason for moving them is to allow other people to get involved in the maintenance and development of the MAP-SSE.

- In October 2016 the primary home was moved to https://github.com/essglobal-linked-open-data/map-sse=
- In December 2020 primary home was moved to https://github.com/SolidarityEconomyAssociation/map-sse,
- Then in January 2025 the primary home was moved to https://github.com/DigitalCommons/map-sse,

This is now a Digital Commons Cooperative project. Please follow the
[contribution guidelines](https://github.com/DigitalCommons#-contributing) if you
wish to participate.

## Documentation sources

### ESSGlobal RDF Vocabulary

[ESSGlobal RDF Vocabulary](vocabs/html/essglobal.html) - HTML source view.

_TODO: add link to view in browser_

### ESSGLOBAL Technical Guidelines

[ESSGLOBAL technical guidelines](doc/2014-07-ESSglobal_interop_guidelines.pdf), July 2014.

This is a copy of the [document on the ripess.eu site](http://ripess.eu/wp-content/uploads/2014/07/ESSglobal_interop_guidelines.pdf), retained here for safe keeping.

The Technical Guidelines document describes the reasoning behind the ESSGLOBAL vocab, and the thinking on how it is intended to be used.

### Taxonomy overview

Each taxonomy describes a different facet of an SSE Initiative.

| Taxonomy | Overview (English) | Linked Data definition |
| -------- | ------------------ | --------------- |
| Products and services | [Simple list](viewers/views/products-services.md) | [SKOS](vocabs/standard/products-services.skos) |
| Activities | [Simple list](viewers/views/activities.md) | [SKOS](vocabs/standard/activities.skos) |
| Themes | [Simple list](viewers/views/themes.md) | [SKOS](vocabs/standard/themes.skos) |
| Qualifiers | [Simple list](viewers/views/qualifiers.md) | [SKOS](vocabs/standard/qualifiers.skos) |
| Type of labour | [Simple list](viewers/views/type-of-labour.md) | [SKOS](vocabs/standard/type-of-labour.skos) |
| Legal form | [Simple list](viewers/views/legal-form.md) | [SKOS](vocabs/standard/legal-form.skos) |

Each of these is described in detail in the [ESSGLOBAL technical guidelines](doc/2014-07-ESSglobal_interop_guidelines.pdf).


## Generating and deploying RDF serializations

There is a [script](generators/build) for generating various RDF
serialializations.  For more information, see the documentation in
[BUILD.md](generators/BUILD.md) in that directory.

## Release versions

### V1.0 (git tag `v1.0`)

Consists of `.ttl`, `.rdf` and `.skos` files copied from the `essglobal.org` server.

| File type | Origin on essglobal.org |
| --------- | ----------------------- |
| `.ttl`, `.rdf` | `vocabs/vocab/v1.0` |
| `.skos` | `vocabs/standard` |

### V1.1 (git tag `v1.1`)

Consists of `.ttl` and `.rdf` copied from the `essglobal.org` server.

| File type | Origin on essglobal.org |
| --------- | ----------------------- |
| `.ttl`, `.rdf` | `vocabs/vocab/v1.1` |
| `.skos` | unchanged |

### V2a (git tag `v2a`)

New Solidarity Economy Association context. Probably intended to be an
alpha version 2, hence the unusual version format? (Note: the tag was
added retrospectively to show the transition to the new version. A
change in the line-up of the maintainers led to an inadvertant change
in the process for representing the version.)

Major changes (partially inferred from the commit subjects):

- The makefile build was replaced with a Ruby script build (intended to simplify)
- The project was renamed from "dcap-sse" to "map-sse"
- Use the lod.coop Permanent URL redirector instead of w3id.org or w3id.solidarityeconomy.coop.
- New activities vocabs were added: Activities (Modified) and Activities (ICA)
- Various changes to the vocabulary terms.
- An HTML documentation snapshot added from essglobal.org.
- Content negotiation added.
- Deployment automation added.
- Bugfixes and documentation

### V2.1 (git tag `v2.1`)

Updated to make a non-alpha release which supports the ICA's
data. (Note: as before, this tag was added retrospectively.)

The ICA data we were using had two concepts of a "Country" associated
with each organisation:

- The country in which an organisation's address was based
- The region in which an organisation's members were based

The latter was usually the same as the former. However, not always. It might be:
- Simply a different country entirely.
- Not a country - sometimes it was a larger domain than that: a region, a super-region, or global.

To support this, new vocabularies were introduced. Some of the new
vocab files were generated from TSV files, which were easier to edit
and manage.

Major changes:
- Use TTL as source format instead of RDF/XML (AKA .skos files, which are less readable).
- Add countries-iso vocab (ISO 3166-1 alpha-2 country codes)
- Add regions-ica, super-regions-ica and territories-ica vocabs
  (defining ICA's definitions of a "region", "super-region"
  and "territories",
- To stay in line with ICA terminology (although note that the filenames remained
  the same), the following vocabs were re-titled:
  - "Activities ICA" became "Economic Activities"
  - "Base Membership Type" became "Typology"
  - "Organisational Structure" became "Structure Type"
- More translations, including (an intention for) full support for
  Spanish, German, French and English.
- Minor corrections, bugfixes.

### V2.1.1

Note that this release was not made explicitly and the version remains
2.1. The tag `v2.2.1` has been added retrospectively to show the
transition, but the distinction is not yet "official". This would need
to be done in future work by adding a target for this release.

The intention for this iteration was not so much to change the vocab,
but to support a new ICA map for an ICA conference in South Korea that
had Korean translations.

"Phrasetabs" were devised as a means to round-trip SKOS -> TSV -> XLS
-> TSV -> SKOS. This was so that translations could be viewed and
edited in a spreadsheet. A "Phrase table" is a TSV file which includes
columns for "term" and "property", as well as a single non-localised
value, and N localised values. This allowed the failthful preservation
of the SKOS structure, in which each vocabulary term can have many
properties, and each property is either not a localised value (like
"altLabel") or localised (like "prefLabel"). TSV rows without a term
were used to represent properties of the vocabulary as a whole, as
opposed to a single term.

Major changes:
- Korean translations were added
- Phrasetabs added as a new representation format for vocabs, with
  scripts for the round-tripping process to and from TSV and SKOS
  (.ttl).

Note that the .ttl files remained the "source of truth", not the .tsv
phrasetab files.

## Use of branches in this repository

We are following exactly the process documented at http://nvie.com/posts/a-successful-git-branching-model/. Please make sure you are completely familiar with this process before making any changes here. As a consequence of following this branching model:

  - The `master` branch is updated only on release
  - The `develop` branch is the place to look for current activity.
  - The `develop` branch is the default branch for this repository.

Note: when tagging in a local checkout, you must explicitly push tags up to the origin (just as for branches). See [Git Basics -- Tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging).
