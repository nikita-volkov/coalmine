module Coalmine.Terse where

import Coalmine.InternalPrelude

-- * Execution

-- |
-- Compile routes into a server and run it.
serve ::
  -- | Port.
  Int ->
  [Route] ->
  IO ()
serve =
  error "TODO"

-- * --

data Authenticated request = Authenticated
  { authenticatedToken :: !ByteString,
    authenicatedRequest :: !request
  }
  deriving (Functor)

-- Something closely related to security policy.
data SecurityPolicy sess

sessionInHeaderApiKeySecurityPolicy :: SessionStore sess -> SecurityPolicy sess
sessionInHeaderApiKeySecurityPolicy =
  error "TODO"

data Authenticator cred sess

data SessionStore sess

authenticator :: (cred -> IO (Maybe sess)) -> Authenticator cred sess
authenticator =
  error "TODO"

data Validator a

minItemsArrayValidator :: Int -> Validator [a]
minItemsArrayValidator = error "TODO"

maxItemsArrayValidator :: Int -> Validator [a]
maxItemsArrayValidator = error "TODO"

data Schema value

validatedSchema :: [Validator a] -> Schema a -> Schema a
validatedSchema =
  error "TODO"

codecSchema :: (a -> Json) -> JsonDecoder a -> Schema a
codecSchema =
  error "TODO"

objectSchema :: ObjectSchema a a -> Schema a
objectSchema =
  error "TODO"

arraySchema :: Schema a -> Schema [a]
arraySchema =
  error "TODO"

uuidSchema :: Schema UUID
uuidSchema =
  error "TODO"

stringSchema :: Schema Text
stringSchema =
  error "TODO"

data ObjectSchema i o

instance Profunctor ObjectSchema

instance Functor (ObjectSchema i)

instance Applicative (ObjectSchema i)

requiredSchemaField :: Text -> Schema a -> ObjectSchema a a
requiredSchemaField =
  error "TODO"

unrequiredSchemaField :: Text -> Schema a -> ObjectSchema (Maybe a) (Maybe a)
unrequiredSchemaField =
  error "TODO"

data RequestBody i

instance Functor RequestBody

data JsonDecoder i

instance Functor JsonDecoder

schemaDecoder :: Schema i -> JsonDecoder i
schemaDecoder =
  error "TODO"

jsonRequestBody :: JsonDecoder i -> RequestBody i
jsonRequestBody =
  error "TODO"

data Route

insecurePostRoute :: [RequestBody req] -> (req -> IO Response) -> Route
insecurePostRoute =
  error "TODO"

securePostRoute :: SecurityPolicy sess -> [RequestBody req] -> (req -> StateT sess IO Response) -> Route
securePostRoute =
  error "TODO"

authPostRoute :: SecurityPolicy sess -> [RequestBody (IO (Maybe sess))] -> Route
authPostRoute =
  error "TODO"

specificSegmentRoute :: Text -> [Route] -> Route
specificSegmentRoute =
  error "TODO"

data Response

response :: Int -> Text -> [ResponseContent] -> Response
response =
  error "TODO"

data ResponseContent

jsonResponseContent :: Json -> ResponseContent
jsonResponseContent =
  error "TODO"

data Json

schemaJson :: Schema a -> a -> Json
schemaJson =
  error "TODO"

objectJson :: [JsonField] -> Json
objectJson =
  error "TODO"

data JsonField

requiredJsonField :: Text -> Json -> JsonField
requiredJsonField =
  error "TODO"

unrequiredJsonField :: Text -> Maybe Json -> JsonField
unrequiredJsonField =
  error "TODO"
