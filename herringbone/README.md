herringbone
===========

herringbone is a Haskell library for compiling and serving web assets.  It
aims to make it dead simple to create a 'Network.Wai.Middleware' or
'Network.Wai.Application' which deals with all of your static assets, including
preprocessing for languages like Fay, CoffeeScript, Sass, and LESS.

It takes most of its inspiration from the Ruby library, [Sprockets], hence the
name.

Status
------

Alpha.

How to use it
-------------

```haskell
import Web.Herringbone

fay, sass :: PP

hb = Herringbone
hb = herringbone
    ( addSourceDir "assets"
    . setDestDir   "compiled_assets"
    . addPreprocessors [fay, sass]
    )

-- You can now access assets programmatically
asset <- findAsset hb (fromJust . makeLogicalPath $ ["application.js"])

-- Or serve them with a Wai application
app = toApplication hb
```

For more information, go and look at the documentation on [Hackage]!

[Sprockets]: https://github.com/sstephenson/sprockets
[Hackage]: http://hackage.haskell.org/package/herringbone