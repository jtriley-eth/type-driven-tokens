# Type Driven Tokens

the defacto standard for code reuse, modularity, and abstraction in solidity is through object and
interface inheritance, the consequences of which range from hidden interfaces to inheritance hell

an alternate approach is to make types and function application the points of abstraction, which can
expose the entire interface in the final contract, remove the necessity for inheritance, enable more
idomatic api's, and make for significantly simplified in-langauge testing; allowing the testing of
data structures, their morphisms, and their invariants both in isolation and when integrated with
the broader contract.
