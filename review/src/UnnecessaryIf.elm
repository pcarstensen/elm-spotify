module UnnecessaryIf exposing (rule)

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range as Range exposing (Range)
import Review.Rule as Rule exposing (Error, Rule)


rule : Rule
rule =
    Rule.newModuleRuleSchema "UnnecessaryIf" ()
        |> Rule.withSimpleExpressionVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


expressionVisitor : Node Expression -> List (Error {})
expressionVisitor node =
    case Node.value node of
        Expression.IfBlock _ left right ->
            errorsForIfBlock node left right

        _ ->
            []


errorsForIfBlock : Node a -> Node Expression -> Node Expression -> List (Error {})
errorsForIfBlock ifnode left right =
    case Node.value left of
        Expression.FunctionOrValue [] leftValue ->
            case Node.value right of
                Expression.FunctionOrValue [] rightValue ->
                    if leftValue == "True" && rightValue == "False" then
                        [ Rule.error
                            { message = "Unnecessary if found"
                            , details = [ "An if expression with True and False can be simplified by just the condition." ]
                            }
                            (Node.range ifnode)
                        ]

                    else
                        []

                _ ->
                    []

        _ ->
            []
