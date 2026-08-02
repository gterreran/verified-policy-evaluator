namespace VerifiedPolicyEvaluator

/-- An identity requesting access to a resource. -/
structure Principal where
  name : String
  deriving Repr, DecidableEq, BEq

/-- An operation that a principal wants to perform. -/
structure Action where
  name : String
  deriving Repr, DecidableEq, BEq

/-- An object on which an action may be performed. -/
structure Resource where
  name : String
  deriving Repr, DecidableEq, BEq

/-- The name of an attribute attached to an authorization request. -/
structure AttributeName where
  name : String
  deriving Repr, DecidableEq, BEq

/-- A value stored in the request context. -/
inductive AttributeValue where
  | bool (value : Bool)
  | text (value : String)
  deriving Repr, DecidableEq, BEq

/--
The information supplied to the authorization evaluator.

Attributes represent contextual information such as whether multi-factor
authentication was used or which department a principal belongs to.
-/
structure Request where
  principal : Principal
  action : Action
  resource : Resource
  attributes : List (AttributeName × AttributeValue) := []
  deriving Repr

/-- The effect produced when a policy matches a request. -/
inductive Effect where
  | permit
  | forbid
  deriving Repr, DecidableEq, BEq

/-- The final result returned by an authorization evaluator. -/
inductive Decision where
  | allow
  | deny
  deriving Repr, DecidableEq, BEq

end VerifiedPolicyEvaluator
