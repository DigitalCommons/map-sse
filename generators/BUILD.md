
# PREREQUISITES

You will need:

- Ruby 2.x or newer
- Bash 4.x or newer and the usual Unix shell utilities like grep, cat, date, getent
- raptor (included in raptor2-utils on Debian)
- rsync

# USAGE

    build <target>

Where valid target version are: 

- `sea`

Obsolete target versions are:

- `experimental`
- `ise`
- `1.1`

# DESCRIPTION

The script generates files into the directory
`generators/generated/<target>/`, substituting matches of the base URI
`http://purl.org/essglobal/` for the URI appropriate to the target.

Files are transformed as follows:
- `vocabs/vocab/essglobal-vocab.ttl` into
  - `vocab-content/essglobal-vocab.rdf`
  - `vocab-content/essglobal-vocab.html`
- `vocabs/standard/*.skos` into `vocab-content/*.skos`
- `vocabs/html/*.html` into `html-content/*.html`
- `vocabs/html/*.css` verbatim into `html-content/*.css`

Also, an Apache `.htaccess` file will be generated with the
appropriate redirections.
