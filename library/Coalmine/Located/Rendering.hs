-- |
-- Rendering in the following style:
--
-- > 5:1:
-- > 5 | create type "language" as enum ('c', 'c#', 'c++');
-- >   | ^
-- > unexpected 'c'
-- > expecting "--", "/*", end of input, or white space
module Coalmine.Located.Rendering where

import qualified Coalmine.BaseExtras.Integer as Integer
import Coalmine.Inter
import Coalmine.Prelude hiding (select)
import qualified Coalmine.TextAppender as TextAppender
import qualified Data.Text as Text

render :: Int -> Int -> Text -> Text
render startOffset endOffset input =
  Text.foldr step finish input [] 0 0 0 Nothing False 0 0 0
  where
    step
      char
      next
      !collectedLines
      !currentOffset
      !currentLineStart
      !currentLineNum
      !earlyEnd
      startReached
      startLineNum
      startCol
      endCol =
        if startReached
          then
            if currentOffset < endOffset
              then case char of
                '\r' ->
                  next
                    collectedLines
                    (succ currentOffset)
                    currentLineStart
                    currentLineNum
                    (Just currentOffset)
                    True
                    startLineNum
                    startCol
                    endCol
                '\n' ->
                  next
                    (line : collectedLines)
                    (succ currentOffset)
                    (succ currentOffset)
                    (succ currentLineNum)
                    Nothing
                    True
                    startLineNum
                    startCol
                    endCol
                _ ->
                  next
                    collectedLines
                    (succ currentOffset)
                    currentLineStart
                    currentLineNum
                    earlyEnd
                    True
                    startLineNum
                    startCol
                    endCol
              else
                let endCol' =
                      if currentOffset == endOffset
                        then currentOffset - currentLineStart
                        else endCol
                 in if char == '\r' || char == '\n'
                      then
                        finish
                          collectedLines
                          currentOffset
                          currentLineStart
                          currentLineNum
                          Nothing
                          True
                          startLineNum
                          startCol
                          endCol'
                      else
                        next
                          collectedLines
                          (succ currentOffset)
                          currentLineStart
                          currentLineNum
                          Nothing
                          True
                          startLineNum
                          startCol
                          endCol'
          else
            if currentOffset >= startOffset
              then
                step
                  char
                  next
                  collectedLines
                  currentOffset
                  currentLineStart
                  currentLineNum
                  earlyEnd
                  True
                  startLineNum
                  (currentOffset - currentLineStart)
                  endCol
              else case char of
                '\n' ->
                  next
                    []
                    (succ currentOffset)
                    (succ currentOffset)
                    (succ currentLineNum)
                    Nothing
                    False
                    startLineNum
                    startCol
                    endCol
                _ ->
                  next
                    []
                    (succ currentOffset)
                    currentLineStart
                    currentLineNum
                    earlyEnd
                    startReached
                    startLineNum
                    startCol
                    endCol
        where
          line =
            input
              & Text.drop currentLineStart
              & Text.take (fromMaybe currentOffset earlyEnd - currentLineStart)

    finish collectedLines currentOffset currentLineStart currentLineNum earlyEnd startReached startLineNum startCol endCol =
      select (succ startLineNum) startCol endCol (reverse (line : collectedLines))
        & Text.intercalate "\n"
      where
        line =
          input
            & Text.drop currentLineStart
            & Text.take (fromMaybe currentOffset earlyEnd - currentLineStart)

megaparsecErrorMessageLayout startLine startColumn quote explanation =
  [i|
    $startLine:$startColumn:
    $quote
    $explanation
  |]

select :: Int -> Int -> Int -> [Text] -> [Text]
select firstLineNum startCol endCol inputLines =
  case inputLines of
    linesHead : linesTail ->
      contentLine : firstLineCarets : buildTail (succ firstLineNum) linesTail
      where
        contentLine =
          contentLinePrefix firstLineNum <> linesHead
        firstLineCarets =
          -- Last line?
          if null linesTail
            then
              caretLinePrefix <> Text.replicate startCol " "
                <> Text.replicate (endCol - startCol) "^"
            else
              caretLinePrefix <> Text.replicate startCol " "
                <> Text.replicate (Text.length linesHead - startCol) "^"
        buildTail lineNum = \case
          linesHead : linesTail ->
            -- Last line?
            if null linesTail
              then contentLine : lastLineCarets : []
              else contentLine : intermediateLineCarets : buildTail (succ lineNum) linesTail
            where
              contentLine =
                contentLinePrefix lineNum <> linesHead
              lastLineCarets =
                caretLinePrefix <> Text.replicate endCol "^"
              intermediateLineCarets =
                caretLinePrefix <> Text.replicate (Text.length linesHead) "^"
          [] -> []
    [] -> []
  where
    linesTotal = length inputLines
    lastLineNum = firstLineNum + pred linesTotal
    barOffset = Integer.countDigits lastLineNum + 1
    caretLinePrefix = Text.replicate barOffset " " <> "| "
    contentLinePrefix n = (fromString . show) n <> Text.replicate (barOffset - Integer.countDigits n) " " <> "| "
