# honeybee
The `honeybee` package is an experimental port of backend functions from the 
ALA package `galah`. Its' purpose is to take user-defined queries from `galah`
(generated with `galah_filter`, `galah_identify` etc) and convert them into a 
valid URL that interacts with the API of the selected system. 

This change will enable `galah` to focus on user experience, without lots of
bespoke functions to customize that experience for a given atlas. As a 
consequence, all information relating to what atlases are available, how they 
work, and how to configure them, will now be migrated to `honeybee`.

**This package is experimental, and remains in early development. Do not expect
it to do anything sensible yet.**

It is called `honeybee` because it queries APIs of biodiversity infrastructures,
and the members of the genus *Apis* are commonly known as honey bees. Further,
honey bees are a globally distributed taxon, and `honeybee` queries atlases
from around the world.

## Intended features

* take a set of query modifiers (possibly a `galah_call` object) and return a valid URL, or vector of URLs where a loop is involved.
* `solr` or `elasticsearch` queries formatted automatically
* map base URLs and paths to functions across different infrastructures, probably through a lookup table (though S3 could work too)
* return sensible error messages for services that are unavailabe