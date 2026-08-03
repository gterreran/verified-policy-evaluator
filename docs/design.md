# Design and Proof Guide

## 1. Overview

Verified Policy Evaluator is organized into four conceptual layers:

```text
Domain model
     ↓
Expression and policy evaluation
     ↓
Declarative authorization semantics
     ↓
Implementation and correctness proofs
```

The separation between these layers is intentional. It prevents the specification from merely repeating the implementation and makes the relationship between executable code and logical claims explicit.

## 2. Domain model

The domain model defines distinct wrapper types for:

* `Principal`;
* `Action`;
* `Resource`;
* `AttributeName`.

Although each wrapper currently contains a `String`, separate types prevent accidental interchange. An action cannot be passed where a principal is expected without an explicit conversion.

Attribute values support Boolean and textual data:

```lean
inductive AttributeValue where
  | bool (value : Bool)
  | text (value : String)
```

A request contains the subject, operation, object, and contextual attributes involved in an authorization decision.

## 3. Expression semantics

Policy conditions use the inductive `Expr` datatype.

The evaluator:

```lean
Expr.evaluate : Expr → Request → Bool
```

is structurally recursive over an expression.

The expression language is closed: every expression is constructed from one of the known constructors. This makes structural induction possible and prevents policy conditions from containing arbitrary opaque Lean functions.

Attribute lookup uses the first matching attribute name. Duplicate attribute names are therefore permitted by the data model but interpreted using first-match precedence.

A production design would likely reject duplicates during validation or use a map with an explicit uniqueness invariant.

## 4. Policies and decisions

A policy combines:

```lean
structure Policy where
  name : String
  effect : Effect
  condition : Expr
```

The name is metadata and does not influence authorization.

A policy applies when:

```lean
policy.condition.evaluate request = true
```

The final decision has two possible values:

```lean
inductive Decision where
  | allow
  | deny
```

The evaluator cannot return an indeterminate or error result. Missing attributes cause the corresponding equality expression to evaluate to `false`.

## 5. Reference evaluator

The reference evaluator searches the full list independently for matching forbid and permit policies.

Conceptually:

```text
matching forbid?
    yes → deny
    no
     ↓
matching permit?
    yes → allow
    no  → deny
```

This structure encodes two intentional security properties:

* deny by default;
* forbid overrides permit.

The implementation favors simplicity over performance because it serves as the reference behavior for future transformations.

## 6. Declarative specification

The logical predicate:

```lean
HasMatchingPolicy effect policies request
```

states that there exists a policy in the list with the requested effect that applies to the request.

Authorization is defined as:

```lean
matching permit exists
AND
matching forbid does not exist
```

This is a proposition rather than an executable decision procedure.

The distinction is central to the project:

```text
Specification: what authorization means
Implementation: how authorization is computed
```

### Scope of the current specification

The declarative authorization specification is independent of the evaluator's
list traversal and permit/forbid decision control flow. However,
`HasMatchingPolicy` currently defines policy applicability using:

```lean
policy.appliesTo request = true
```

and `Policy.appliesTo` delegates to the executable Boolean interpreter
`Expr.evaluate`.

Consequently, this version proves the correctness of policy search, decision
combination, policy-order independence, and compilation relative to the current
executable expression semantics. It does not yet define a separate
propositional semantics for `Expr` and prove that `Expr.evaluate` implements
that semantics correctly.

Adding that additional semantic layer would be a natural future extension. It
would strengthen the separation between the policy-condition specification and
its executable interpreter without changing the authorization theorems already
established here.

## 7. Reference correctness proof

The bridge between Boolean search and propositional existence is:

```lean
hasMatchingEffect_eq_true_iff
```

It proves that the executable list search returns `true` exactly when the logical matching-policy predicate holds.

The main theorem:

```lean
authorizeReference_correct
```

then analyzes the possible existence of matching permit and forbid policies.

It proves both directions:

```text
evaluator allows → specification authorizes
specification authorizes → evaluator allows
```

These correspond to soundness and completeness.

## 8. Derived security properties

The security properties are derived from the correctness theorem and matching-search lemmas.

### Empty policy set denial

No permit exists in an empty policy list, so every request is denied.

### Permit justification

Every approval implies the existence of a matching permit.

### Forbid exclusion

Every approval implies that no forbid matches.

### General default denial

If no permit matches, the evaluator denies the request.

### Forbid precedence

If any forbid matches, the evaluator denies the request.

These theorems expose a more convenient public proof API than repeatedly unfolding the evaluator implementation.

## 9. Policy-order independence

Policy-order independence is expressed using `List.Perm`.

The proof proceeds in stages:

1. A permutation preserves list membership.
2. Therefore, it preserves the existence of a matching policy.
3. Therefore, it preserves declarative authorization.
4. Reference evaluator correctness transfers that fact to executable decisions.

The theorem applies to lists containing the same policies with the same multiplicities.

It does not yet prove that duplicate policies can be freely added or removed. Duplicate insensitivity would be a separate theorem.

## 10. Compiler

The compiler partitions policies by effect:

```lean
compilePolicies : List Policy → CompiledPolicySet
```

The result contains separate permit and forbid lists.

The transformation preserves the order of policies within each effect category, although authorization itself does not depend on that order.

This compiler is intentionally simple. It demonstrates semantic preservation without introducing complex indexes or additional data structures.

## 11. Compiler-correctness proof

The key helper theorem proves:

```text
search filtered policies for applicability
=
search original policies for matching effect and applicability
```

This gives separate equivalences for compiled permit and forbid searches.

The evaluator equivalence theorem then follows by rewriting both searches:

```lean
compilation_preserves_authorization
```

Because the compiled evaluator equals the reference evaluator, and the reference evaluator satisfies the declarative specification, the compiled evaluator also satisfies that specification.

This is a small refinement proof:

```text
Declarative specification
          ↑
Reference evaluator
          =
Compiled evaluator
```

## 12. Testing strategy

Formal proofs and executable tests serve different purposes.

The theorems establish universal statements for every value represented by the model.

Scenario tests verify that:

* the code is convenient to use;
* representative policies are encoded correctly;
* examples produce the intended decisions;
* theorem APIs can be applied by downstream modules.

Exhaustive finite-domain tests exercise combinations of:

* principals;
* actions;
* resources;
* attributes;
* policy subsets.

These tests are redundant with the universal theorems at the semantic level, but useful for detecting errors in examples, test setup, or future unverified interfaces.

## 13. Trusted boundary

The project proves properties of the Lean definitions contained in the repository.

The machine-checked theorem claims depend on:

* Lean’s kernel and foundational logic;
* the imported Lean standard library and pinned Lean toolchain;
* the definitions accurately representing the intended authorization requirements.

Executing the generated native program additionally relies on:

* the Lean compiler and runtime;
* the operating system and machine environment.

The project does not prove:

* correctness of the Lean compiler or operating system;
* correctness of future parsers or serialization code;
* that human-authored policies reflect the desired business requirements;
* that names and attributes correspond to real authenticated identities;
* resistance to side channels or denial-of-service attacks;
* compatibility with another policy language.

Formal verification proves that an implementation satisfies a specification. It does not prove that the specification captures every real-world requirement.

## 14. Possible extensions

Natural future extensions include:

* unique request-attribute maps;
* richer attribute types;
* action- or resource-based policy indexes;
* entity hierarchies;
* policy validation;
* decision explanations;
* parser and serialization layers;
* duplicate-policy invariance;
* compiler composition;
* performance benchmarks;
* counterexample-oriented examples for intentionally false properties.

Each extension should preserve the current separation between specification, implementation, and proof.
