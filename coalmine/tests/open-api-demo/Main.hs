module Main where

import Coalmine.JsonSchema
import Coalmine.OpenApi
import Coalmine.Prelude
import OpenApiDemo.Model qualified as M

-- * --

main :: IO ()
main =
  return ()

-- * --

api ::
  SecurityPolicy sess ->
  (M.QuizesPostRequestBody -> StateT sess IO M.QuizesPostResponse) ->
  (UUID -> StateT sess IO M.QuizesParamGetResponse) ->
  (UUID -> M.QuizesParamPutRequestBody -> StateT sess IO M.QuizesParamPutResponse) ->
  (M.UsersPostRequestBody -> IO M.UsersPostResponse) ->
  (M.TokensPostRequestBody -> IO M.TokensPostResponse) ->
  [Route]
api securityPolicy quizesPostHandler quizesParamGetHandler quizesParamPutHandler usersPostHandler tokensPostHandler =
  [ staticSegmentRoute "quizes" $
      [ securePostRoute
          securityPolicy
          [ fmap M.JsonQuizesPostRequestBody . jsonRequestBody $
              quizConfigSchema
          ]
          $ let responseAdapter = \case
                  M.Status201QuizesPostResponse a ->
                    response 201 "Created" $
                      [ jsonResponseContent
                          ( objectSchema $
                              M.QuizesPostResponseStatus201Json
                                <$> lmap
                                  (.id)
                                  (requiredSchemaField "id" uuidSchema)
                          )
                          a
                      ]
             in fmap responseAdapter . quizesPostHandler,
        dynamicSegmentRoute uuidSchema $ \quizId ->
          [ secureGetRoute securityPolicy $
              let responseAdapter = \case
                    M.Status200QuizesParamGetResponse a ->
                      response 200 "Quiz config" $
                        [ jsonResponseContent quizConfigSchema a
                        ]
                    M.Status403QuizesParamGetResponse ->
                      response 403 "Not published and not owned" []
                    M.Status404QuizesParamGetResponse ->
                      response 404 "Not found" []
               in fmap responseAdapter (quizesParamGetHandler quizId),
            securePutRoute securityPolicy [] $
              let responseAdapter = \case
                    M.Status204QuizesParamPutResponse ->
                      response 204 "Replaced" []
                    M.Status403QuizesParamPutResponse ->
                      response 403 "Not your quiz" []
                    M.Status404QuizesParamPutResponse ->
                      response 404 "Not found" []
               in fmap responseAdapter . quizesParamPutHandler quizId
          ]
      ],
    staticSegmentRoute "users" $
      [ insecurePostRoute
          [ fmap M.JsonUsersPostRequestBody . jsonRequestBody . objectSchema $
              M.UsersPostRequestBodyJson
                <$> lmap
                  (.email)
                  (requiredSchemaField "email" emailSchema)
                <*> lmap
                  (.password)
                  (requiredSchemaField "password" passwordSchema)
          ]
          $ let responseAdapter =
                  \case
                    M.Status204UsersPostResponse ->
                      response 204 "User registered" []
                    M.Status403UsersPostResponse ->
                      response 403 "Email already registered" []
             in fmap responseAdapter . usersPostHandler
      ],
    staticSegmentRoute "tokens" $
      [ insecurePostRoute
          [ fmap M.JsonTokensPostRequestBody . jsonRequestBody . objectSchema $
              M.TokensPostRequestBodyJson
                <$> lmap
                  (.email)
                  (requiredSchemaField "email" emailSchema)
                <*> lmap
                  (.password)
                  (requiredSchemaField "password" passwordSchema)
          ]
          $ let responseAdapter = \case
                  M.Status200TokensPostResponse token ->
                    response 200 "Authenticated" $
                      [ jsonResponseContent (stringSchema 1 100) token
                      ]
                  M.Status401TokensPostResponse ->
                    response 401 "Unauthorized" []
             in fmap responseAdapter . tokensPostHandler
      ]
  ]

-- * Schemas

quizConfigSchema :: Schema M.QuizConfig
quizConfigSchema =
  objectSchema $
    M.QuizConfig
      <$> lmap
        (.title)
        ( requiredSchemaField
            "title"
            (stringSchema 1 100)
        )
      <*> lmap
        (.questions)
        ( requiredSchemaField
            "questions"
            (arraySchema 1 10 questionConfigSchema)
        )

questionConfigSchema :: Schema M.QuestionConfig
questionConfigSchema =
  error "TODO"

emailSchema :: Schema Text
emailSchema =
  error "TODO"

passwordSchema :: Schema Text
passwordSchema =
  error "TODO"
