<!-- vim: ft=markdown
-->


Yet another XML Parser
=====================

This parser was built with two main goals:

* binary parsing

* Namespace specific parsing

It uses the `parser_pt` _parse transform_ (aka [don't write these](http://www.erlang.org/doc/man/erl_id_trans.html#parse_transform-2)) for writing the actual parser.

Components
----------

* `src/parser_pt.erl`
  Will generate simple parsers from a specification embedded in the erlang code.

* `src/exemell.erl`
  The main XML Parser, the parser is strickly whitespace preserving.

* `src/exemellp.erl`
  Xml output, no pretty printing, and behaviour for xml serializable things.
  Defines `Module:xml(exemellp:state(),Module()) -> iolist()`, and provides 
  `xml(tag(),[{tag(),iolist()}],[child()],exemellp:state()) -> iolist()` as the preferred way of implementing the callback.

* `src/exemell_parser.erl`
  behaviour for parser callback modules (and default implementation)
* `src/exemell_namespace.erl`
  behaviour for namespace callback and implementation of the `none` namespace.
* `src/exemell_namespace_xml.erl`
  implementation of the `xml:` namespace.
* `src/exemell_block.erl` and `src/exemell_blob.erl` callbacks (and default implementations) for the block creation.

* `include/xml.hrl`
  Defines the record generated by the parser when reverting to pseudo DOM mode.

* `include/exemell.hrl`
  Exposes the internal state of full parser, useful if you wish to set your own entity handling, meta handling or p.i. handling (or even to rewire the namespace handling).

* `src/parser.hrl`
  The actual XML parser used by `exemell.erl`.
  The parser is not for the faint of heart but should make it obvious how to use `parser_pt.erl`.


Performance
-----------

It's not the fastest parser out there, but its reasonably fast a very rough test places the parser at about:
 * ~10% slower then erlsom
 * twice as fast as xmerl
As with any performance rating, take them with a lot of salt, and do your own measurements.

Caviats
-------
* No validation other then basic wellformedness is done (the parser will silently ignore missing close tags)
* The parser is hard coded to UTF8 encoding
* Other than sanity checking there's no testing done.
* Not all features are implemented yet (particularly skip and blob are not implemented).
* There is an unavoidable warning about an undefined behaviour `exemell` (erlc is not favourable to self referentiality).

Todos
-----
* Proper test cases, the modules are type annotated and dialyzer seems happy enough.
* Figure out how to make dialyzer like a polymorphic version of the module.

Benchmark
---------
A simple parsing benchmark is included, though its results are likely meaningless for practical purposes. Enter the path(s)s to your favourite example XML in to `test/exemell_bennchmar.erl` and then `make benchmark`.
To include `erlsom` in the benchmark uncomment the dependency in `rebar.config` and `make dependencies; make all`.



