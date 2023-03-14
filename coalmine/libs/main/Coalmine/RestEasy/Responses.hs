{-# OPTIONS_GHC -Wno-missing-signatures #-}

module Coalmine.RestEasy.Responses where

import Coalmine.Prelude
import Data.Text.Encoding qualified as Text
import Network.HTTP.Types qualified as HttpTypes
import Network.Wai qualified as Wai

ok contentType content = Wai.responseBuilder HttpTypes.status200 headers content
  where
    headers =
      [ ("content-type", contentType)
      ]

notFound = Wai.responseBuilder HttpTypes.status404 [] mempty

unsupportedMediaType = Wai.responseBuilder HttpTypes.status415 [] mempty

plainBadRequest err = Wai.responseBuilder HttpTypes.status400 headers content
  where
    headers =
      [ ("content-type", "text/plain")
      ]
    content = Text.encodeUtf8Builder err

methodNotAllowed = Wai.responseBuilder HttpTypes.status405 [] mempty

notAcceptable = Wai.responseBuilder HttpTypes.status406 [] mempty

internalServerError = Wai.responseBuilder HttpTypes.status500 [] mempty

accepted = Wai.responseBuilder HttpTypes.status202 [] mempty

temporaryRedirect timeout uri = Wai.responseBuilder HttpTypes.status307 headers mempty
  where
    headers = [cacheControl, location]
      where
        cacheControl = ("cache-control", fromString ("max-age=" <> show timeout))
        location = ("location", Text.encodeUtf8 uri)

unauthorized realm = Wai.responseBuilder HttpTypes.status401 headers mempty
  where
    headers =
      [ ("WWW-Authenticate", "Basic realm=\"" <> realm <> "\"")
      ]

status :: HttpTypes.Status -> Wai.Response
status status = Wai.responseBuilder status [] mempty

file :: ByteString -> String -> Wai.Response
file contentType path = Wai.responseFile HttpTypes.status200 headers path Nothing
  where
    headers =
      [ ("content-type", contentType)
      ]

alternate :: Wai.Response -> Wai.Response -> Wai.Response
alternate response1 response2 =
  let statusCode1 = HttpTypes.statusCode (Wai.responseStatus response1)
   in if statusCode1 >= 400 && statusCode1 < 500
        then response2
        else response1
