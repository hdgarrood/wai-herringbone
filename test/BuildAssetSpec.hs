module BuildAssetSpec where

import Test.Hspec
import Test.HUnit
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Filesystem.Path.CurrentOS (FilePath, (</>))
import qualified Filesystem.Path.CurrentOS as F
import qualified Filesystem as F
import qualified Data.ByteString as B
import Data.Monoid
import Prelude hiding (FilePath)

import Network.Wai.Herringbone
import SpecHelper

spec :: Spec
spec = do
    let sourceDir = "test/resources/assets"
    let destDir   = hbDestDir testHB
    after (clean destDir) $ do
        context "without preprocessors" $ do
            let source = sourceDir </> "buildAsset.js"
            let dest   = destDir   </> "buildAsset.js"
            let logPath = lp "buildAsset.js"

            it "should copy a source file to the destination directory" $ do
                asset <- buildAsset testHB logPath source []

                assertIsRight asset
                assertFileExists dest
                assertFileContentsMatch source dest

            it "should not modify the source file" $ do
                _ <- buildAsset testHB logPath source []

                assertFileExists source

            it "should get the modification time of the source file" $ do
                sourceMTime <- F.getModified source
                Right asset <- buildAsset testHB logPath source []

                assertEqual' sourceMTime (assetModifiedTime asset)

        context "with preprocessors" $ do
            it "should run preprocessors" $ do
                let source = sourceDir </> "buildPreprocess.js.coffee"
                let dest   = destDir   </> "buildPreprocess.js"
                let logPath = lp "buildPreprocess.js"

                asset <- buildAsset testHB logPath source [coffee]

                assertRanPreprocessor "coffee" dest

assertRanPreprocessor :: Text -> FilePath -> Assertion
assertRanPreprocessor ext path = do
    contents <- fmap linesBS $ F.readFile path
    let message = "Ran preprocessor: " <> (T.encodeUtf8 ext)
    assertBool
        ("Preprocessor " ++ T.unpack ext ++ " was not run on " ++ es path)
        (message `elem` contents)
    where
    linesBS = tokenise "\n"
    tokenise x y =
        let (h,t) = B.breakSubstring x y
        in  h : if B.null t
                then []
                else tokenise x (B.drop (B.length x) t)
