module Web.Herringbone.Preprocessor.StdIO (
    makeStdIOPP
) where

import Control.Monad.IO.Class
import Data.Monoid
import Data.ByteString (ByteString)
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as C8
import System.Exit (ExitCode(..))
import System.Process.ByteString (readProcessWithExitCode)
import Web.Herringbone

-- | Make a preprocessor which works over standard IO; reading input from
-- stdin, and writing output to stdout.
makeStdIOPP :: PPSpec 
            -> String   -- ^ Program name
            -> [String] -- ^ Arguments
            -> PP
makeStdIOPP spec progname args = PP
    { ppSpec   = spec
    , ppAction = compile progname args
    }
    
compile :: String
        -> [String]
        -> ByteString
        -> PPM (Either CompileError ByteString)
compile progname args source = do
    liftIO $ readAllFromProcess progname args source

-- | Read from a process returning both std err and out.
readAllFromProcess :: String        -- ^ Program
                   -> [String]      -- ^ Args
                   -> ByteString    -- ^ Stdin
                   -> IO (Either ByteString ByteString)
readAllFromProcess program args input = do
    (code,out,err) <- readProcessWithExitCode program args input
    return $ case code of
        ExitFailure 127 -> Left $ "cannot find executable " <> C8.pack program
        ExitFailure _   -> Left $ join (err, out)
        ExitSuccess     -> Right $ join (err, out)
  where
  join (err, out) = if B.null err
                        then out
                        else err <> "\n" <> out
