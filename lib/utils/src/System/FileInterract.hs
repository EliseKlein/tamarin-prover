-- |
-- Copyright   : (c) 2012 Simon Meier
-- License     : GPL v3 (see LICENSE)
--
-- Maintainer  : Simon Meier <iridcode@gmail.com>
--
-- Various utility functions for interacting with the user.
module System.FileInterract (
    -- * File handling
    writeFileWithDirs
    , appendFileWithDirsIO
    , appendFileWithDirs
    , appendFileWithDirsM

  ) where


import System.FilePath
import System.Directory
import System.IO.Unsafe


------------------------------------------------------------------------------
-- File Handling
------------------------------------------------------------------------------

-- | Write a file and ensure that its containing directory exists.
writeFileWithDirs :: FilePath -> String -> IO ()
writeFileWithDirs file output = do
    createDirectoryIfMissing True (takeDirectory file)
    writeFile file output

-- | Append text to a file and ensure that its containing directory exists.
appendFileWithDirsIO :: FilePath -> String -> IO ()
appendFileWithDirsIO file output = do
    createDirectoryIfMissing True (takeDirectory file)
    appendFile file output

appendFileWithDirs :: FilePath -> String -> a -> a
appendFileWithDirs file output expr = unsafePerformIO $ do
    appendFileWithDirsIO file output
    return expr

appendFileWithDirsM :: Applicative f => FilePath -> String -> f ()
appendFileWithDirsM file output = appendFileWithDirs file output $ pure ()