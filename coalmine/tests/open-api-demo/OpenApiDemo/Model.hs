module OpenApiDemo.Model where

import Coalmine.Prelude

-- * --

data QuizConfig = QuizConfig
  { title :: !Text,
    questions :: !(BVec QuestionConfig)
  }

data QuestionConfig

-- * --

data QuizesParamGetResponse
  = Status200QuizesParamGetResponse QuizConfig
  | Status403QuizesParamGetResponse
  | Status404QuizesParamGetResponse

-- * --

data QuizesParamPutRequestBody
  = JsonQuizesParamPutRequestBody !QuizConfig

data QuizesParamPutResponse
  = Status204QuizesParamPutResponse
  | Status403QuizesParamPutResponse
  | Status404QuizesParamPutResponse

-- * --

data QuizesPostRequestBody
  = JsonQuizesPostRequestBody !QuizConfig

data QuizesPostResponse
  = Status201QuizesPostResponse QuizesPostResponseStatus201Json

data QuizesPostResponseStatus201Json = QuizesPostResponseStatus201Json
  { id :: !UUID
  }

-- * --

data QuizesQuizIdGetResponse
  = -- | Quiz config.
    Status200QuizesQuizIdGetResponse
      QuizConfig
      -- ^ JSON content.
  | -- | Not published and not owned.
    Status403QuizesQuizIdGetResponse
  | -- | Not found.
    Status404QuizesQuizIdGetResponse

-- * --

data UsersPostRequestBody
  = JsonUsersPostRequestBody !UsersPostRequestBodyJson

data UsersPostRequestBodyJson = UsersPostRequestBodyJson
  { email :: !Text,
    password :: !Text
  }

data UsersPostResponse
  = -- | User registered.
    Status204UsersPostResponse
  | -- | Email already registered.
    Status403UsersPostResponse

-- * --

data TokensPostRequestBody
  = JsonTokensPostRequestBody !TokensPostRequestBodyJson

data TokensPostRequestBodyJson = TokensPostRequestBodyJson
  { email :: !Text,
    password :: !Text
  }

data TokensPostResponse
  = -- | Authenticated.
    Status200TokensPostResponse
      Text
      -- ^ JSON content.
  | -- | Unauthorized.
    Status401TokensPostResponse
