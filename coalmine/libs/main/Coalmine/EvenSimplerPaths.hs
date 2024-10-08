module Coalmine.EvenSimplerPaths
  ( -- * --
    Path,

    -- * --
    toString,
    parent,
    components,
    name,
    extensions,

    -- * Actions
    createDirs,
    createDirsTo,
    removeForcibly,
    listDirectory,
    setCurrentDirectory,

    -- * --
    addExtension,
  )
where

import AesonValueParser qualified
import Algorithms.NaturalSort qualified as NaturalSort
import Coalmine.BaseExtras.MonadPlus
import Coalmine.CerealExtras.Compact qualified as CerealExtrasCompact
import Coalmine.EvenSimplerPaths.AttoparsecHelpers qualified as AttoparsecHelpers
import Coalmine.EvenSimplerPaths.QuickCheckGens qualified as QuickCheckGens
import Coalmine.InternalPrelude
import Coalmine.NameConversion
import Coalmine.Printing
import Coalmine.Special
import Coalmine.SyntaxModelling qualified as Syntax
import Data.Attoparsec.Text qualified as Attoparsec
import Data.Serialize qualified as Cereal
import Data.Text qualified as Text
import System.Directory qualified as Directory
import Test.QuickCheck qualified as QuickCheck
import TextBuilderDev qualified as TextBuilderDev

-- * --

-- |
-- Structured name of a single component of a path.
data Component = Component
  { -- | Name.
    name :: !Text,
    -- | Extensions in reverse order.
    extensions :: ![Text]
  }
  deriving (Eq)

instance QuickCheck.Arbitrary Component where
  arbitrary = QuickCheck.suchThat gen predicate
    where
      gen = do
        name <- QuickCheckGens.fileName
        fileExtensions <- QuickCheckGens.fileExtensions
        return $ Component name fileExtensions
      predicate = not . componentNull
  shrink (Component name extensions) =
    QuickCheck.shrink (name, extensions) <&> \(name, extensions) ->
      Component name extensions

instance Cereal.Serialize Component where
  put (Component name extensions) = do
    Cereal.put $ CerealExtrasCompact.Compact name
    Cereal.put $ CerealExtrasCompact.Compact $ fmap CerealExtrasCompact.Compact extensions
  get = do
    CerealExtrasCompact.Compact name <- Cereal.get
    CerealExtrasCompact.Compact extensions <- Cereal.get
    return $ Component name (fmap CerealExtrasCompact.unwrap extensions)

instance Ord Component where
  compare l r =
    if la == ra
      then
        if lb < rb
          then LT
          else
            if lb == rb
              then EQ
              else GT
      else
        if la < ra
          then LT
          else GT
    where
      la = componentNameSortKey l
      lb = componentExtensionsSortKey l
      ra = componentNameSortKey r
      rb = componentExtensionsSortKey r
      componentNameSortKey = NaturalSort.sortKey . (.name)
      componentExtensionsSortKey = reverse . fmap NaturalSort.sortKey . (.extensions)

componentNull :: Component -> Bool
componentNull (Component name extensions) =
  Text.null name && null extensions

-- * --

data Path
  = Path
      -- | Is it absolute?
      !Bool
      -- | Components in reverse order.
      ![Component]
  deriving (Eq)

instance QuickCheck.Arbitrary Path where
  arbitrary = Path <$> QuickCheck.arbitrary <*> components
    where
      components = do
        size <- QuickCheck.chooseInt (0, 20)
        QuickCheck.vectorOf size QuickCheck.arbitrary
  shrink (Path absolute components) =
    Path absolute <$> QuickCheck.shrink components

instance Cereal.Serialize Path where
  put (Path abs components) = do
    Cereal.put abs
    Cereal.put $ CerealExtrasCompact.Compact components
  get = do
    abs <- Cereal.get
    CerealExtrasCompact.Compact components <- Cereal.get
    return $ Path abs components

instance Ord Path where
  compare (Path la lb) (Path ra rb) =
    if la == ra
      then
        if lb < rb
          then LT
          else
            if lb == rb
              then EQ
              else GT
      else
        if la < ra
          then LT
          else GT

instance Semigroup Path where
  Path _lAbs _lNames <> Path _rAbs _rNames =
    if _rAbs
      then Path _rAbs _rNames
      else Path _lAbs $ _rNames <> _lNames

instance Monoid Path where
  mempty =
    Path False []

instance CompactPrinting Path where
  toCompactBuilder = Syntax.toTextBuilder

instance BroadPrinting Path where
  toBroadBuilder = to . Syntax.toTextBuilder

instance FromJSON Path where
  parseJSON = AesonValueParser.runAsValueParser $ AesonValueParser.string $ AesonValueParser.attoparsedText lenientParser

instance ToJSON Path where
  toJSON = toJSON . printCompactAsText

instance ToJSONKey Path where
  toJSONKey = contramap printCompactAsText toJSONKey

instance Show Path where
  show = show . printCompactAsText

instance LenientParser Path where
  lenientParser = Syntax.attoparsecParser

instance IsString Path where
  fromString =
    either error id
      . Attoparsec.parseOnly (lenientParser <* Attoparsec.endOfInput)
      . fromString

instance FromName Path where
  fromNameIn casing name =
    Path False [Component (fromNameIn casing name) []]

instance Syntax.Syntax Path where
  attoparsecParser = do
    _abs <- Attoparsec.char '/' $> True <|> pure False
    _components <-
      catMaybes
        <$> reverseSepBy _componentOrDot (Attoparsec.char '/')
    optional $ Attoparsec.char '/'
    return $ Path _abs _components
    where
      _componentOrDot = do
        _baseName <- AttoparsecHelpers.fileName
        _extensions <- reverseMany AttoparsecHelpers.extension
        if Text.null _baseName && null _extensions
          then Nothing <$ Attoparsec.char '.' <|> pure Nothing
          else return $ Just $ Component _baseName _extensions
  toTextBuilder (Path _abs _components) =
    if _abs
      then "/" <> _relative
      else case _components of
        [] -> "."
        _ -> _relative
    where
      _relative =
        TextBuilderDev.intercalate "/" . fmap _fromComponent . reverse $ _components
      _fromComponent (Component _name _extensions) =
        foldr
          (\_extension _next -> _next <> "." <> to _extension)
          (to _name)
          _extensions

instance Special Path where
  type GeneralizationOf Path = FilePath
  type SpecializationErrorOf Path = Text
  specialize = Syntax.fromTextInEither . fromString
  generalize = toString

-- * --

-- | Helper for dealing with APIs for FilePath from base.
toString :: Path -> String
toString = to . toCompactBuilder

parent :: Path -> Maybe Path
parent (Path abs components) =
  case components of
    _ : t -> Just $ Path abs t
    _ -> Nothing

-- | Decompose into components.
components :: Path -> [Path]
components (Path abs components) =
  if abs
    then case revComponents of
      h : t -> Path True [h] : nonAbsFromComponents t
      _ -> [Path True []]
    else nonAbsFromComponents revComponents
  where
    revComponents = reverse components
    nonAbsFromComponents = \case
      h : t -> Path False [h] : nonAbsFromComponents t
      _ -> []

-- | File name sans extensions.
name :: Path -> Text
name (Path _ components) =
  case components of
    Component name _ : _ -> name
    [] -> ""

extensions :: Path -> [Text]
extensions (Path _ components) =
  case components of
    Component _ extensions : _ -> reverse extensions
    [] -> []

-- * Actions

createDirs :: Path -> IO ()
createDirs =
  Directory.createDirectoryIfMissing True . toString

createDirsTo :: Path -> IO ()
createDirsTo =
  traverse_ createDirs . parent

removeForcibly :: Path -> IO ()
removeForcibly =
  Directory.removePathForcibly . printCompactAs

listDirectory :: Path -> IO [Path]
listDirectory path =
  Directory.listDirectory (printCompactAs path)
    <&> fmap fromString

setCurrentDirectory :: Path -> IO ()
setCurrentDirectory path =
  Directory.setCurrentDirectory (printCompactAs path)

-- * Traversers (or Van Laarhoven lenses)

traverseLastComponent :: (Functor f) => (Component -> f Component) -> Path -> f Path
traverseLastComponent traverser (Path abs components) =
  case components of
    h : t -> traverser h <&> \h -> Path abs (h : t)
    _ -> traverser (Component "" []) <&> \h -> Path abs [h]

traverseExtensions :: (Functor f) => ([Text] -> f [Text]) -> Path -> f Path
traverseExtensions traverser =
  traverseLastComponent $ \(Component name extensions) ->
    traverser extensions <&> \extensions ->
      Component name extensions

-- * Mappers

mapExtensions :: ([Text] -> [Text]) -> Path -> Path
mapExtensions mapper =
  runIdentity . traverseExtensions (Identity . mapper)

-- * Editors

-- | Add file extension to the last component of the path.
addExtension :: Text -> Path -> Path
addExtension ext = mapExtensions (ext :)
