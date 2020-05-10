# TODO
 - need to support `fuzzy` cli commands (like `query` which would preload queries - such as for `logdiff`)
 - diff target selection needs work
 - prevent blinkyness
    - idea: move all output to a particular file and tail it in the background into STDERR; kill the process before exiting

# Ideas
 - support hub things
 - clean up shortcuts in `fzf` global
 - build a JS specific workflow
     - madge dependency tree browsing???
 - build a PR workflow
     - using madge + hub?
     - it'd be nice to pick out a PR and use a series of tools to run static/etc analysis on it
 - it'd be nice to build a "locator" interface
     - query could be something like:
         `-- path/to/file %% -G 'foo'`
     - this would be used to search the log for commits changing that file and then provide a preview window with hunks containing `foo` in the changes (in any file from that commit)
     - this pattern could be repeated for several pairs
         - log + diff (where <CR> would enter `gf diff` mode)
         - pull-request list + a way of searching the patch

