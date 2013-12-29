module LocateAssetsSpec where

import Test.Hspec
import Test.Hspec.HUnit
import Test.HUnit hiding (path)
import Data.Text (Text)
import Filesystem.Path.CurrentOS (FilePath, (</>))
import Prelude hiding (FilePath)

import Network.Wai.Herringbone.LocateAssets
import Network.Wai.Herringbone.Types
import TestResources
import TestUtils

spec :: Spec
spec = describe "LocateAssets" $ do
    fromHUnitTest $ testWithInputs "getExtraExtensions"
        test_getExtraExtensions
        data_getExtraExtensions

    fromHUnitTest $ testWithInputs "resolvePPs"
        test_resolvePPs
        data_resolvePPs

    fromHUnitTest $ testWithInputs "lookupPP"
        test_lookupPP
        data_lookupPP

    fromHUnitTest $ testWithInputs "locateAssets"
        test_locateAssets
        data_locateAssets

test_getExtraExtensions :: (FilePath, FilePath, Maybe [Text]) -> Assertion
test_getExtraExtensions (pathWithExts, path, expected) =
    assertEqual' expected (getExtraExtensions pathWithExts path)

data_getExtraExtensions :: [(FilePath, FilePath, Maybe [Text])]
data_getExtraExtensions =
    [ ("game.js"   , "game.js.coffee"     , Just ["coffee"])
    , ("style.css" , "game.js.coffee"     , Nothing)
    , ("game.js"   , "game.js.coffee.erb" , Just ["erb", "coffee"])
    ]

test_resolvePPs :: (PPs, FilePath, FilePath, Maybe [PP]) -> Assertion
test_resolvePPs (pps, assetPath, sourcePath, expected) =
    assertEqual' expected (resolvePPs pps assetPath sourcePath)

data_resolvePPs :: [(PPs, FilePath, FilePath, Maybe [PP])]
data_resolvePPs =
    [ (noPPs        , "test.js"   , "test.js"            , Just [])
    , (noPPs        , "test.js"   , "test.js.coffee"     , Nothing)
    , (coffeeAndErb , "test.js"   , "test.js.coffee"     , Just [coffee])
    , (coffeeAndErb , "test.js"   , "test.js.coffee.erb" , Just [erb, coffee])
    , (coffeeAndErb , "style.css" , "test.js.coffee"     , Nothing)
    ]

test_lookupPP :: (Text, PPs, Maybe PP) -> Assertion
test_lookupPP (ext, pps, expected) =
    assertEqual' expected (lookupPP ext pps)

data_lookupPP :: [(Text, PPs, Maybe PP)]
data_lookupPP =
    [ ("sass" , noPPs        , Nothing)
    , ("sass" , coffeeAndErb , Nothing)
    , ("erb"  , coffeeAndErb , Just erb)
    ]

test_locateAssets :: (LogicalPath, [(FilePath, [PP])]) -> Assertion
test_locateAssets (logPath, expected) = do
    assets <- locateAssets testHB logPath
    assertSameElems expected assets

data_locateAssets :: [(LogicalPath, [(FilePath, [PP])])]
data_locateAssets =
    [ (lp "test.js",   [(base1 </> "test.js", [])])
    , (lp "style.css", [ (base1 </> "style.css", [])
                         , (base1 </> "style.css.erb", [erb])
                         , (base2 </> "style.css", [])
                         ])
    , (lp "html/index.html", [(base1 </> "html/index.html", [])])
    ]
    where
    base1 = "test/resources/assets"
    base2 = "test/resources/assets2"