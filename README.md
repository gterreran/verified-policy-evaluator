# Verified Policy Evaluator

A small authorization engine implemented and formally verified in Lean 4.

This repository is a personal exploration of theorem proving, formal specification, and automated reasoning. It defines a miniature policy language, a reference authorization evaluator, and a compiled evaluator that separates permit and forbid policies.

The central goal is to prove that the executable implementations behave according to a declarative authorization specification.

## Project goals

This project was created to:

* learn Lean 4 through a concrete software-verification problem;
* model authorization rules as a small executable language;
* distinguish a mathematical specification from its implementation;
* prove security properties for every representable input;
* prove that a compiler transformation preserves authorization behavior;
* complement formal proofs with scenario tests and exhaustive finite-domain checks.

It is intentionally small enough to understand end to end.

## Documentation

- [Design and proof guide](docs/design.md)
- [Automated reasoning in practice](docs/automated-reasoning-in-practice.md)

## Authorization model

An authorization request contains:

* a principal;
* an action;
* a resource;
* contextual attributes.

Policies contain:

* a descriptive name;
* an effect: `permit` or `forbid`;
* a Boolean expression evaluated against the request.

The evaluator follows three rules:

1. A matching `forbid` policy causes denial.
2. Otherwise, a matching `permit` policy causes approval.
3. Otherwise, access is denied by default.

For example:

```text
Principal:  alice
Action:     read
Resource:   financial-report
Attributes: department = finance, mfa = true
```

A policy may permit members of the finance department to read the report, while another policy forbids requests that were not authenticated using MFA.

## Expression language

Policy conditions are represented as data using a small expression language:

```lean
inductive Expr where
  | always
  | never
  | principalEq (principal : Principal)
  | actionEq (action : Action)
  | resourceEq (resource : Resource)
  | attributeEq
      (name : AttributeName)
      (value : AttributeValue)
  | allOf (left right : Expr)
  | anyOf (left right : Expr)
  | negate (expression : Expr)
```

Representing expressions as an inductive datatype allows Lean to evaluate, inspect, transform, and reason about every possible expression.

## Implementations

The repository contains two authorization implementations.

### Reference evaluator

The reference evaluator scans the original policy list:

```lean
authorizeReference :
  List Policy → Request → Decision
```

It is designed to be simple and closely reflect the intended decision rules.

### Compiled evaluator

The compiler partitions policies into separate collections:

```lean
structure CompiledPolicySet where
  permits : List Policy
  forbids : List Policy
```

The compiled evaluator consumes this representation:

```lean
authorizeCompiled :
  CompiledPolicySet → Request → Decision
```

This is a deliberately modest optimization. Its purpose is to demonstrate how Lean can prove that a representation change preserves program behavior.

## Declarative specification

Authorization is also defined independently as a proposition:

```lean
def Authorized
    (policies : List Policy)
    (request : Request) :
    Prop :=
  HasMatchingPolicy .permit policies request ∧
  ¬ HasMatchingPolicy .forbid policies request
```

This specification states what authorization means without describing how an evaluator computes the answer.

## Main verified properties

### Reference evaluator correctness

```lean
theorem authorizeReference_correct :
  authorizeReference policies request = .allow ↔
    Authorized policies request
```

The theorem establishes:

* **soundness:** every approval returned by the evaluator is justified by the specification;
* **completeness:** every request authorized by the specification is approved by the evaluator.

### Default denial

```lean
theorem no_matching_permit_denies :
  ¬ HasMatchingPolicy .permit policies request →
  authorizeReference policies request = .deny
```

Approval requires an explicit matching permit.

### Forbid precedence

```lean
theorem matching_forbid_denies :
  HasMatchingPolicy .forbid policies request →
  authorizeReference policies request = .deny
```

A matching forbid causes denial regardless of matching permits.

### Policy-order independence

```lean
theorem authorizeReference_order_independent :
  policiesLeft.Perm policiesRight →
  authorizeReference policiesLeft request =
    authorizeReference policiesRight request
```

Reordering the same policies cannot alter the result.

### Compiler semantic preservation

```lean
theorem compilation_preserves_authorization :
  authorizeCompiled (compilePolicies policies) request =
    authorizeReference policies request
```

The compiler changes the representation of the policy set but never changes an authorization decision.

### Compiled evaluator correctness

```lean
theorem authorizeCompiled_correct :
  authorizeCompiled
      (compilePolicies policies)
      request = .allow ↔
    Authorized policies request
```

The compiled implementation therefore satisfies the same declarative specification as the reference implementation.

## Verification and testing

The project uses several complementary verification layers.

### Machine-checked proofs

Lean checks every theorem during compilation. The source contains no `sorry`, `admit`, or project-defined axioms.

### Scenario tests

Concrete examples cover:

* empty policy sets;
* matching and nonmatching permits;
* matching and nonmatching forbids;
* default denial;
* conflicting permit and forbid policies;
* policy reordering;
* reference and compiled evaluator agreement.

### Exhaustive finite-domain checks

The exhaustive test module evaluates:

* 64 policy subsets;
* 32 authorization requests;
* 2,048 comparisons between the reference and compiled evaluators;
* 2,048 comparisons between original and reversed policy lists.

The general theorems cover every representable input. The finite checks provide a separate executable validation layer and exercise the examples and test infrastructure.

### Continuous integration

GitHub Actions runs:

```bash
lake build --wfail
lake test --wfail
lake test
```

Warnings are treated as failures. CI also uses an independent Lean environment checker and rejects proofs that rely on `sorry`.

## Build the project

The repository pins its Lean version through `lean-toolchain`.

Install Lean using Elan, clone the repository, and run:

```bash
lake build
lake test
lake exe verified_policy_evaluator
```

No Python environment, Conda environment, Mathlib dependency, database, or external service is required.

## Repository structure

```text
.
├── .github/
│   └── workflows/
│       └── ci.yml
├── LICENSE
├── lake-manifest.json
├── Main.lean
├── Tests.lean
├── Tests/
│   ├── Expression.lean
│   ├── ReferenceEvaluator.lean
│   ├── Semantics.lean
│   ├── SecurityProperties.lean
│   ├── OrderIndependence.lean
│   ├── CompiledEvaluator.lean
│   ├── CompilerCorrectness.lean
│   └── Exhaustive.lean
├── VerifiedPolicyEvaluator.lean
├── VerifiedPolicyEvaluator/
│   ├── Model.lean
│   ├── Expression.lean
│   ├── Policy.lean
│   ├── ReferenceEvaluator.lean
│   ├── Semantics.lean
│   ├── Compiler.lean
│   ├── CompiledEvaluator.lean
│   └── Proofs/
│       ├── SecurityProperties.lean
│       ├── OrderIndependence.lean
│       └── CompilerCorrectness.lean
├── docs/
│   ├── design.md
│   └── automated-reasoning-in-practice.md
├── lakefile.toml
└── lean-toolchain
```

## Scope and limitations

This is an educational verification project, not a production authorization system.

It does not currently include:

* a policy parser;
* JSON input;
* entity hierarchies;
* resource ownership;
* action-based indexes;
* policy validation or diagnostics;
* a network service or user interface;
* compatibility with Cedar, IAM, or another existing policy language.

These exclusions keep the trusted and verified core small enough to study carefully.

## Inspiration

The project is inspired by public examples of automated reasoning being used in production software, including work surrounding the Cedar authorization language.

It is not a Cedar implementation, an AWS project, or a reproduction of AWS verification infrastructure. The relationship is inspirational: Cedar provides a useful example of formal semantics, executable implementations, security properties, and testing being developed together.

See [From a Learning Project to Automated Reasoning in Practice](docs/automated-reasoning-in-practice.md) for the longer reflection.

## License

This project is released under the [MIT License](LICENSE).
