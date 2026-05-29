# OVERVIEW

The recommended method of building and deployment is to use
`redeploy-all`. However, that is simply a wrapper to invoke `build`
and `deploy` with the correct parameters, so all of these are
described here.

# PREREQUISITES

You will need:

- Ruby 2.x or newer
- Bash 4.x or newer and the usual Unix shell utilities like grep, cat, date, getent
- raptor (included in raptor2-utils on Debian)

For deployment:
- rsync
- ssh
- appropriate configuration and permissions to ssh to your target
  deployment host

# BUILDING

## USAGE

    build <target>[-dev]

Where valid target version are: 

- `V2a`
- `2.1`

Obsolete target versions are:

- `experimental`
- `ise`
- `1.1`
- `sea`

The `-dev` suffix can be added to deploy development builts, which
have the `dev.` prefix to URLs. Note that the output goes into the
same file structure!

## DESCRIPTION

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

# DEPLOYMENT

## USAGE

    deploy <source> <target>
	
The script `deploy` accepts two arguments:

- `<source>` - the source directory to deploy
- `<target>` - the destination to deploy to

Both should be in a form accepted by `rsync`, which is used to
implement the operation. 

## DESCRIPTION

The script simply validates the parameters and ensues the destination
directory is created, before copying all the data from the source,
recursively, to the destination (typically a directory on a remote
host).

Note that it assumes that the files should be deployed as the
`www-data:www-data` ownership.

# REDEPLOYING ALL

## USAGE

    redeploy-all

To use, first check the parameters are as you expect - you may need to
adjust the destination hostname, or add an alias for it in your
[~/.ssh/config](https://www.ssh.com/academy/ssh/config) file. You
should also make sure you understand the parameters passed to the
`build` command.

Note that you can alter or comment out lines temporarily if you wish
to skip deployment of one version, or deploy elsewhere.

After running, check that the update has occurred as expected.

## DESCRIPTION

The script `redeploy-all` performs the build and deployment with one
invocation.  This includes the typical parameters for both commands,
and deploys all the currently released versions, so it is currently
the recommended method for doing that. However, do that cautiously, as
it could destructively overwrite the destination directories.

Note that for linked data, all versions are made available on
different URLs so that even old version are accessible to those who
need them.

