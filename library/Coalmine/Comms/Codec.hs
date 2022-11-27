module Coalmine.Comms.Codec where

import Coalmine.Comms.Decoding qualified as Decoding
import Coalmine.Comms.Schema qualified as Schema
import Coalmine.InternalPrelude hiding (product, sum)
import Coalmine.PtrKit.Streamer qualified as Streamer
import Coalmine.PtrKit.Writer qualified as Writer
import Data.Vector qualified as BVec

serializeAsByteStringWithSchema :: Codec a -> ByteString
serializeAsByteStringWithSchema =
  error "TODO"

serializeAsByteStringWithoutSchema :: Codec a -> ByteString
serializeAsByteStringWithoutSchema =
  error "TODO"

-- |
-- Encoder, decoder and structure metadata all united in a single composable abstraction.
--
-- Guarantees to provide isomorphic encoder and decoder and
-- a schema that matches them.
data Codec a = Codec
  { schema :: Schema.Schema,
    write :: a -> Writer.Writer,
    stream :: a -> Streamer.Streamer,
    decode :: Decoding.StreamingPtrDecoder a
  }

product :: ProductCodec a a -> Codec a
product ProductCodec {..} =
  Codec (Schema.ProductSchema (toList schema)) write stream decode

sum :: [VariantCodec a] -> Codec a
sum variants =
  Codec schema write stream decode
  where
    schema =
      variants
        & fmap (\variant -> (variant.name, variant.schema))
        & Schema.SumSchema
    write val =
      foldr step finish variants (0 :: Word)
      where
        step variant next !idx =
          case variant.write val of
            Nothing -> next (succ idx)
            Just encoding -> Writer.varLengthUnsignedInteger idx <> encoding
        finish idx =
          Writer.varLengthUnsignedInteger idx
    stream =
      error "TODO"
    decode = do
      idx <- fromIntegral <$> Decoding.varLengthNatural
      case vec BVec.!? idx of
        Just decoder -> decoder
        Nothing -> Decoding.failure $ "Invalid index: " <> showAs idx
      where
        vec =
          BVec.fromList $ fmap (.decode) $ variants

-- |
-- Variable length representation of unsigned integers.
--
-- Uses the 8th bit of each octet to specify, whether another octet is needed.
varLengthUnsignedInteger :: (Integral a, Bits a) => Codec a
varLengthUnsignedInteger =
  Codec schema write stream decode
  where
    schema =
      error "TODO"
    write =
      Writer.varLengthUnsignedInteger
    stream =
      Streamer.varLengthUnsignedInteger
    decode =
      error "TODO"

-- |
-- Composable codec of product fields.
data ProductCodec i o = ProductCodec
  { schema :: Acc (Text, Schema.Schema),
    write :: i -> Writer.Writer,
    stream :: i -> Streamer.Streamer,
    decode :: Decoding.StreamingPtrDecoder o
  }

instance Functor (ProductCodec i) where
  fmap = error "TODO"

instance Applicative (ProductCodec i) where
  pure a =
    ProductCodec
      mempty
      (const mempty)
      (const mempty)
      (pure a)
  ProductCodec lSchema lWrite lStream lDecode <*> ProductCodec rSchema rWrite rStream rDecode =
    ProductCodec
      (lSchema <> rSchema)
      (\i -> lWrite i <> rWrite i)
      (\i -> lStream i <> rStream i)
      (lDecode <*> rDecode)

instance Profunctor ProductCodec where
  dimap f1 f2 codec =
    ProductCodec
      codec.schema
      (codec.write . f1)
      (codec.stream . f1)
      (fmap f2 codec.decode)

field :: Text -> Codec a -> ProductCodec a a
field name codec =
  error "TODO"

data VariantCodec a = VariantCodec
  { name :: Text,
    schema :: Schema.Schema,
    write :: a -> Maybe Writer.Writer,
    stream :: a -> Maybe Streamer.Streamer,
    decode :: Decoding.StreamingPtrDecoder a
  }

variant :: Text -> (a -> Maybe b) -> (b -> a) -> Codec b -> VariantCodec a
variant name unpack pack codec =
  VariantCodec
    name
    codec.schema
    (fmap codec.write . unpack)
    (fmap codec.stream . unpack)
    (fmap pack codec.decode)

-- * Validation

isCorrect :: CodecCorrectness -> Bool
isCorrect =
  error "TODO"

-- |
-- Composite over the report on all the properties of a correct codec.
data CodecCorrectness = CodecCorrectness
  { -- | Whether encoding and decoding produces the same value.
    encodeDecode :: ~Bool,
    schemaMatch :: ~Bool
  }

-- |
-- Test a codec on a given value and produce a structured report about
-- the properties that are satisfied.
-- Codec is considered correct only when it satisfies all properties,
-- which can be checked via a combination of 'validate' and 'isCorrect' functions.
--
-- Can be seen as a universal interface that can be mapped into all property-testing
-- libraries.
-- The specific adapters are expected to be provided as separate libraries,
-- thus both not limiting the user to a specific set of libraries and
-- leaving the interface open for other libraries to be integrated via.
-- An open interface may also turn usable for tasks that have not been discovered yet.
-- This approach also lets the user control the dependencies.
validate :: Codec a -> a -> CodecCorrectness
validate =
  error "TODO"

-- * Errors

data DecodingError
  = SchemaMismatchDecodingError
      Schema.Schema
      -- ^ Expected.
      Schema.Schema
      -- ^ Actual.
