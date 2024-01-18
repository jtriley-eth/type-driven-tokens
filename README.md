# Type Driven Tokens

the defacto standard for code reuse, modularity, and abstraction in solidity is through object and
interface inheritance, the consequences of which range from hidden interfaces to inheritance hell

an alternate approach is to make types and function application the points of abstraction, which can
expose the entire interface in the final contract, remove the necessity for inheritance, enable more
idomatic api's, and make for significantly simplified in-langauge testing; allowing the testing of
data structures, their function, and their invariants both in isolation and when integrated with
the broader contract.

## Testing

testing type-driven tokens enables tight granularity on test cases;

inheritance based solidity must be tested in one of two ways.

first of which is the mock pattern, where mock contracts inherit abstract contracts, creating public
methods to interface with internal methods directly or indirectly.

```mermaid
flowchart LR
    ERC20([ERC20]) --> ERC4626([ERC4626])
    Ownable([Ownable]) --> ERC4626
    Market([Market]) --> Final([Final])
    ERC4626 --> Final

    ERC20 --> MockERC20([MockERC20])
    Ownable --> MockOwnable([MockOwnable])
    ERC4626 --> MockERC4626([MockERC4626])
    Market --> MockMarket([MockMarket])

    MockERC20 --> test0ERC20
    MockERC20 --> test1ERC20
    MockOwnable --> test0Ownable
    MockOwnable --> test1Ownable
    MockERC4626 --> test0ERC4626
    MockERC4626 --> test1ERC4626
    MockMarket --> test0Market
    MockMarket --> test1Market
    Final --> test0Final
    Final --> test1Final
```

second of which is the singleton pattern, where only the final contract is tested, but tests must
account for each parent contract and their interactions. this is uncommon, as the granularity of
tests is far too coarse.

```mermaid
flowchart LR
    ERC20([ERC20]) --> ERC4626([ERC4626])
    Ownable([Ownable]) --> ERC4626
    Market([Market]) --> Final([Final])
    ERC4626 --> Final

    Final --> test0ERC20
    Final --> test1ERC20
    Final --> test0Ownable
    Final --> test1Ownable
    Final --> test0ERC4626
    Final --> test1ERC4626
    Final --> test0Market
    Final --> test1Market
    Final --> test0Final
    Final --> test1Final
```

in type-driven solidity, core data types may be defined to encapsulate and constrain storage slots.
by minimizing the storage that each type has access to and by minimizing the functionality of each
morphism, each component is testable without additional interface logic. also, compositions of
types and functions may be tested. finally, the `Final` contract may be interfaced with to
ensure the complete composition and interconnectedness of its inner types may be tested.

```mermaid
flowchart LR
    OwnerType([OwnerType])
    MarketType([MarketType])
    SharesType([SharesType])
    BalanceType([BalanceType])
    AllowanceType([AllowanceType])

    test0OwnerType --> OwnerType
    test1OwnerType --> OwnerType
    test0BalanceType --> BalanceType
    test1BalanceType --> BalanceType
    test0AllowanceType --> AllowanceType
    test1AllowanceType --> AllowanceType
    test0SharesType --> SharesType
    test1SharesType --> SharesType
    test0MarketType --> MarketType
    test1MarketType --> MarketType

    BalanceType ==> TokenType([TokenType])
    test0TokenType --> TokenType
    test1TokenType --> TokenType
    AllowanceType ==> TokenType

    TokenType ==> YieldTokenType
    test0YieldTokenType --> YieldTokenType
    test1YieldTokenType --> YieldTokenType
    SharesType ==> YieldTokenType

    YieldTokenType ==> Final
    OwnerType ==> Final
    MarketType ==> Final
```

## Modularization

modularization with inheritance creates complex inheritance trees with storage layouts and method
overriding that is often unclear and difficult to debug

```solidity
contract A {
    mapping(address => uint256) internal map;

    function readMap(address acct) external view returns (uint256) {
        return map[acct];
    }
}

contract B {
    uint256 public getItem;

    function setItem(uint256 newItem) external {
        getItem = newItem;
    }
}

contract C is B, A {
    function setItem(uint256 newItem) external override {
        getItem = newItem * 2;
    }
}
```

modularization through composition of types and functions enables the same level of modularity
without the inheritance tree, with a more clear trace for each function, and the entire external
interface contained in the final contract explicitly

```solidity
struct Map {
    mapping(address => uint256) inner;
}

using {entry} for Map global;

function entry(Map storage self, address acct) view returns (uint256) {
    return self.inner[acct];
}

struct Item {
    uint256 inner;
}

using {get, set} for Item global;

function set(Item storage self, uint256 item) returns (Item storage) {
    self.inner = item;
    return self;
}

function get(Item storage self) returns (uint256) {
    return self.inner;
}

struct CSTore {
    Map map;
    Item item;
}

contract C {
    CSTore self;

    function readMap(address acct) external view returns (uint256) {
        return self.map.entry(acct);
    }

    function getItem() external view returns (uint256) {
        return self.item.get();
    }

    function setItem(uint256 newItem) external {
        self.item.set(newItem * 2);
    }
}
```
