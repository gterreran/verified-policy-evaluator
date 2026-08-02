import VerifiedPolicyEvaluator.Model

namespace VerifiedPolicyEvaluator

/--
A Boolean expression evaluated against an authorization request.

Expressions deliberately form a small, closed language rather than storing
arbitrary Lean functions. This will let us define their semantics precisely
and reason about every possible expression.
-/
inductive Expr where
  /-- An expression that matches every request. -/
  | always

  /-- An expression that matches no request. -/
  | never

  /-- Match a specific principal. -/
  | principalEq (principal : Principal)

  /-- Match a specific action. -/
  | actionEq (action : Action)

  /-- Match a specific resource. -/
  | resourceEq (resource : Resource)

  /-- Match an attribute with a specific value. -/
  | attributeEq
      (name : AttributeName)
      (value : AttributeValue)

  /-- Both subexpressions must match. -/
  | allOf (left right : Expr)

  /-- At least one subexpression must match. -/
  | anyOf (left right : Expr)

  /-- Reverse the result of a subexpression. -/
  | negate (expression : Expr)

  deriving Repr, DecidableEq, BEq

/--
Return the first value associated with an attribute name.

Request attributes currently use a list to keep the initial model small and
dependency-free. If duplicate attribute names are present, the first value
takes precedence.
-/
private def lookupAttribute
    (target : AttributeName) :
    List (AttributeName × AttributeValue) → Option AttributeValue
  | [] => none
  | (name, value) :: rest =>
      if name == target then
        some value
      else
        lookupAttribute target rest

/-- Retrieve an attribute value from a request context. -/
def Request.attribute?
    (request : Request)
    (name : AttributeName) :
    Option AttributeValue :=
  lookupAttribute name request.attributes

namespace Expr

/-- Evaluate a Boolean policy expression against an authorization request. -/
def evaluate : Expr → Request → Bool
  | .always, _ =>
      true

  | .never, _ =>
      false

  | .principalEq expected, request =>
      request.principal == expected

  | .actionEq expected, request =>
      request.action == expected

  | .resourceEq expected, request =>
      request.resource == expected

  | .attributeEq name expected, request =>
      match request.attribute? name with
      | some actual => actual == expected
      | none => false

  | .allOf left right, request =>
      evaluate left request && evaluate right request

  | .anyOf left right, request =>
      evaluate left request || evaluate right request

  | .negate expression, request =>
      !(evaluate expression request)

end Expr

end VerifiedPolicyEvaluator
