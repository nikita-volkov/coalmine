module Coalmine.TerminalMarkup
  ( TerminalMarkup,

    -- ** Execution
    outputToStdout,
    outputToStderr,
    outputAndTerminate,

    -- ** Construction
    plainText,
    bold,
  )
where

import Coalmine.InternalPrelude

-- * Types

newtype TerminalMarkup
  = TerminalMarkup (Seq TerminalMarkupNode)
  deriving (Semigroup, Monoid)

instance IsString TerminalMarkup where
  fromString =
    error "TODO"

data TerminalMarkupNode
  = PlainTextTerminalMarkupNode Text
  | BoldTerminalMarkupNode (Seq TerminalMarkupNode)

-- * Execution

outputToStdout :: TerminalMarkup -> IO ()
outputToStdout =
  error "TODO"

outputToStderr :: TerminalMarkup -> IO ()
outputToStderr =
  error "TODO"

outputAndTerminate :: TerminalMarkup -> IO ()
outputAndTerminate =
  error "TODO"

-- * Basic constructors

plainText :: Text -> TerminalMarkup
plainText content =
  TerminalMarkup $ pure $ PlainTextTerminalMarkupNode content

bold :: TerminalMarkup -> TerminalMarkup
bold (TerminalMarkup nodes) =
  TerminalMarkup $ pure $ BoldTerminalMarkupNode nodes

-- * Batteries (Integrations)

data Markdown

markdown :: Markdown -> TerminalMarkup
markdown =
  error "TODO"
