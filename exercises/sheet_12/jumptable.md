## `LUA_USE_JUMPTABLE`

The bulk of the main loop of the interpreter is taken up by a `switch`/`case`
construct, with one `case` label per opcode supported by the Lua Virtual Machine
(e.g. `case OP_MOVE:`).

When the macro `LUA_USE_JUMPTABLE` is defined, the `switch`/`case` construct is
replaced with a manually-defined jump table:

1. Instead of a `case` label, each Virtual Machine opcode is assigned a
   "regular" label (e.g. `L_OP_MOVE:`), and the addresses for each of these are
   stored in the table.

2. Immediately after an opcode has been processed, the next opcode is fetched
   and execution is transferred to its corresponding label using `goto` -- as
   opposed to `break`ing out of the `switch` block, then fetching and jumping to
   the next opcode on the next loop iteration.

While the `switch`/`case` construct is also a jump table, the idea of
constructing one manually is that, by avoiding a jump back to the top of the
interpreter loop before processing the next opcode, performance could be
improved.

However as Roberto (creator of Lua) [noted in
2018](https://narkive.com/nHwpbBsr.8), it may actually cause performance
_regressions_ on some systems.

My performance testing seems to reflect this -- across ten runs of `fib.lua` on
LCC3, the jump table seems to make performance ever so slightly worse. The
difference in runtime is roughly one standard deviation for the `iter` and
`tail` variants, and one fifth of a standard deviation for the `naive` variant.

| test              | wall (mean) | wall (stddev) |
| ----------------- | ----------- | ------------- |
| iter              | 10.8730     | 0.036         |
| iter (jumptable)  | 10.9105     | 0.036         |
| naive             | 12.5483     | 0.322         |
| naive (jumptable) | 12.6001     | 0.316         |
| tail              | 12.5980     | 0.046         |
| tail (jumptable)  | 12.6484     | 0.027         |
