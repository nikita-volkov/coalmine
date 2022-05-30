module Main where

import Coalmine.Prelude
import Coalmine.Terse
import qualified TerseDemo.Model as M

-- * --

main =
  error "TODO"

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
          [ fmap M.JsonQuizesPostRequestBody . jsonRequestBody . schemaDecoder $
              quizConfigSchema
          ]
          $ let responseAdapter = \case
                  M.Status201QuizesPostResponse a ->
                    response 201 "Created" $
                      [ jsonResponseContent $
                          objectJson
                            [ requiredJsonField
                                "id"
                                (schemaJson uuidSchema (M.quizesPostResponseStatus201JsonId a))
                            ]
                      ]
             in fmap responseAdapter . quizesPostHandler,
        dynamicSegmentRoute uuidSchema $ \quizId ->
          [ secureGetRoute securityPolicy $
              let responseAdapter = \case
                    M.Status200QuizesParamGetResponse a ->
                      response 200 "Quiz config" $
                        [ jsonResponseContent $ schemaJson quizConfigSchema a
                        ]
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
          [ fmap M.JsonUsersPostRequestBody . jsonRequestBody . schemaDecoder . objectSchema $
              M.UsersPostRequestBodyJson
                <$> lmap
                  M.usersPostRequestBodyJsonEmail
                  (requiredSchemaField "email" emailSchema)
                <*> lmap
                  M.usersPostRequestBodyJsonPassword
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
          [ fmap M.JsonTokensPostRequestBody . jsonRequestBody . schemaDecoder . objectSchema $
              M.TokensPostRequestBodyJson
                <$> lmap
                  M.tokensPostRequestBodyJsonEmail
                  (requiredSchemaField "email" emailSchema)
                <*> lmap
                  M.tokensPostRequestBodyJsonPassword
                  (requiredSchemaField "password" passwordSchema)
          ]
          $ let responseAdapter = \case
                  M.Status200TokensPostResponse token ->
                    response 200 "Authenticated" $
                      [ jsonResponseContent $
                          schemaJson stringSchema token
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
        M.quizConfigTitle
        ( requiredSchemaField "title" stringSchema
        )
      <*> lmap
        M.quizConfigQuestions
        ( requiredSchemaField
            "questions"
            ( validatedSchema
                [ minItemsArrayValidator 1,
                  maxItemsArrayValidator 10
                ]
                (arraySchema questionConfigSchema)
            )
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
