module ReviewConfig exposing (config)

{-| This file configures elm-review

Please do not change anything here

-}

import NoDebug.Log
import NoDebug.TodoOrToString
import NoExposingEverything
import NoImportingEverything
import NoMissingTypeAnnotation
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule exposing (Rule)
import UnnecessaryIf
import UseCamelCase


config : List Rule
config =
    [ NoExposingEverything.rule
    , NoImportingEverything.rule []
    , NoMissingTypeAnnotation.rule
    , NoUnused.CustomTypeConstructors.rule []
    , NoUnused.Dependencies.rule
    , NoUnused.Exports.rule
    , NoUnused.Modules.rule
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    , NoUnused.Variables.rule
    , NoDebug.Log.rule
    , NoDebug.TodoOrToString.rule
    , UseCamelCase.rule UseCamelCase.default
    , UnnecessaryIf.rule
    ]
