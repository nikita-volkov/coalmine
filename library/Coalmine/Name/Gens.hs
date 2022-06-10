module Coalmine.Name.Gens where

import Coalmine.InternalPrelude
import qualified Coalmine.Name.Charsets as Charsets
import qualified Coalmine.Name.Constants as Constants
import qualified Data.ByteString as ByteString
import qualified Data.Text as Text
import qualified Data.Text.Encoding as TextEncoding
import qualified Data.Vector as BVec
import Test.QuickCheck.Gen

parts :: Gen (BVec Text)
parts = do
  partsAmount <- chooseInt (0, Constants.maxParts)
  BVec.replicateM partsAmount part

part :: Gen Text
part = do
  partSize <- chooseInt (1, Constants.maxBytesInPart)
  text <- Text.pack <$> replicateM partSize partChar
  if ByteString.length (TextEncoding.encodeUtf8 text) > Constants.maxBytesInPart
    then part
    else return text

partChar :: Gen Char
partChar =
  elements $ toList $ Charsets.part