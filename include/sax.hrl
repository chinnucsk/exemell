% vim: ft=erlang

% a simplified sax parser implemented in a header.

-compile([{parse_transform,parser_transform}]).


%% Define lots of nice macros so we can use cryptic horrid names the functions
-ifndef(entrypoint).
-define(entrypoint,parser).
-endif.

-define(exemell_sax_parser,'#exemell#sax#logic#parser').
-define(exemell_sax_open_tag1,'#exemell#sax#logic#open_tag1').
-define(exemell_sax_cdata,'#exemell#sax#logic#cdata').
-define(exemell_sax_open,'#exemell#sax#logic#open').
-define(exemell_sax_processinginstruction,'#exemell#sax#logic#pi').
-define(exemell_sax_meta,'#exemell#sax#logic#meta').
-define(exemell_sax_section,'#exemell#sax#logic#sec').
-define(exemell_sax_comment,'#exemell#sax#logic#comment').
-define(exemell_sax_attrs,'#exemell#sax#logic#attrs').
-define(exemell_sax_entity,'#exemell#sax#logic#entity').
-define(exemell_sax_close,'#exemell#sax#logic#close').
-define(exemell_sax_attrval,'#exemell#sax#logic#attrval').
-define(exemell_sax_attrval_,'#exemell#sax#logic#attrval_').
-define(exemell_sax_attrval_quote,'#exemell#sax#logic#attrval_quote').
-define(exemell_sax_attrval_quote_entity,'#exemell#sax#logic#attrval_quote_entity').

-type tag() -> binary() | atom().

-define(exemell_tag(TAG),
  try binary_to_existing_atom(TAG,utf8)
  catch error:badarg -> TAG end).

-define(sax_element_start,'#sax#event#element#start#').
-spec ?sax_element_start(tag(),[{tag(),iolist()}],state()) -> state().
-define(sax_element_end,'#sax#event#element#end#').
-spec ?sax_element_end(tag(),state()) -> state().
-define(sax_text,'#sax#event#text#').
-spec ?sax_text(iolist(),state()) -> state().
-define(sax_entity,'#sax#event#entity#').
-spec ?sax_tsax_entityext(iolist(),state()) -> state().
-define(sax_processinginstruction,'#sax#event#processinginstruction#').
-spec ?sax_processinginstruction(iolist(),state()) -> state().
-define(sax_comment,'#sax#event#comment#').
-spec ?sax_comment(iolist(),state()) -> state().
-define(sax_meta,'#sax#event#meta#').
-spec ?sax_meta(tag(),state()) -> state().
-define(sax_cdata,'#sax#event#cdata#').
-spec ?sax_cdata(iolist(),state()) -> state().


-define(exemell_WS,[" ","\t","\r","\n"]).


?entrypoint(Input,State) ->
  ?exemell_sax_parser(Input,State).

?exemell_sax_parser(Tag,Input,State) -> parser:input(Input);
?exemell_sax_parser(Tag,<<Text,"<",Input>>,State) ->
  ?exemell_sax_open_tag(Input,?sax_text(Text,State));
?exemell_sax_parser(Tag,<<Text,"&",Input>>,State) ->
  ?exemell_sax_entity(Input,?sax_text(Text,State));
?exemell_sax_parser(Tag,<<Text,"</",Input>>,State) ->
  ?exemell_sax_close_tag(Input,?sax_text(Text,State));
?exemell_sax_parser(Tag,<<Text,"<!--",Input>>,State) ->
  ?exemell_sax_comment(Input,?sax_text(Text,State));
?exemell_sax_parser(Tag,<<Text,"<![CDATA[",Input>>,State) -> 
  ?exemell_sax_cdata(Input,?sax_text(Text,State));
?exemell_sax_parser(Tag,<<Text,"<!",Input>>,State) -> 
  ?exemell_sax_meta(Tag,Input,?sax_text(Text,State));
?exemell_sax_parser(Tag,<<Text,"<?",Input>>,State) -> 
  ?exemell_sax_processinginstruction(Input,?sax_text(Text,State));
?exemell_sax_parser(Tag,<<>>,State) -> ?exemell_sax_end(Tag,State);
?exemell_sax_parser(Tag,Text,State) -> ?exemell_sax_end(Tag,?sax_text(Text,State)).

?exemell_sax_end([],State) -> {ok,State};
?exemell_sax_end([Tag|Tags],State) -> ?exemell_sax_end(Tags,?sax_close(Tag,State)).

?exemell_sax_cdata(Tags,Input,State) -> parser:input(Input);
?exemell_sax_cdata(Tags,<<Chars,"]]>",Input>>,State) ->
  ?exemell_sax_parser(Tags,Input,?sax_cdata(Chars,State)).

?exemell_sax_processinginstruction(Tags,Input,State) -> parser:input(Input);
?exemell_sax_processinginstruction(Tags,<<Instruction,"?>",Input>>,State) ->
  ?exemell_sax_parser(Tags,Input,?sax_processinginstruction(Instruction,State)).

?exemell_sax_meta(Tags,Input,State) -> parser:input(Input);
?exemell_sax_meta(Tags,<<Instruction,">",Input>>,State) ->
  ?exemell_sax_parser(Tags,Input,?sax_meta(Instruction,State)).

?exemell_sax_comment(Tags,Input,State) -> parser:input(Input);
?exemell_sax_comment(Tags,<<Comment,"-->",Input>>,State) ->
  ?exemell_sax_parser(Tags,Input,?sax_comment(Comment,State)).

?exemell_sax_open(Tags,Input,State) -> parser:input(Input);
?exemell_sax_open(Tags,<<Tag,?exemell_WS,Input>>,State) ->
  ?exemell_sax_attrs(Tags,Input,?sax_open_tag(Tag,State));
?exemell_sax_open(Tags,<<Tag,">",Input>>,State) -> 
  ?exemell_sax_parser(Tags,Input,?sax_close_tag_begin_block(Input,?sax_open_tag(Tag,State)));
?exemell_sax_open(Tags,<<Tag,"/>",Input>>,State) ->
  ?exemell_sax_parser(Tags,Input,?sax_close_tag(Input,?sax_open_tag(Tag,State))).

?exemell_sax_attrs(Tags,Input,State) -> parser:input(Input);
?exemell_sax_attrs(Tags,<<?nil,?WS,Input>>,State) ->
  ?exemell_sax_attrs(Tags,Input,State);
?exemell_sax_attrs(Tags,<<Name,?WS,Input>>,State) ->
  ?exemell_sax_attrval(Tags,Input,?sax_attribute_name(Name,State));
?exemell_sax_attrs(Tags,<<?nil,">",Input>>,State) ->
  ?exemell_sax_parser(Tags,Input,?sax_close_tag_begin_block(State));
?exemell_sax_attrs(Tags,<<Name,">",Input>>,State) ->
  ?exemell_sax_parser(Tags,Input,?sax_close_tag_begin_block(Input,?sax_attribute_value(none,?sax_attribute_name(Name,State))));
?exemell_sax_attrs(Tags,<<?nil,"/>",Input>>,State) ->
  ?exemell_sax_parser(Tags,Input,?sax_close_tag(State));
?exemell_sax_attrs(Tags,<<Name,"/>",Input>>,State) ->
  ?exemell_sax_parser(Tags,Input,?sax_close_tag(Input,?sax_attribute_value(none,?sax_attribute_name(Name,State))));
?exemell_sax_attrs(Tags,<<Name,"=",Input>>,State) ->
  ?exemell_sax_attrval_(Tags,Input,?sax_attribute_name(Name,State)).

?exemell_sax_attrval(Input,State) -> parser:input(Input);
?exemell_sax_attrval(<<?nil,?WS,Input>>,State) ->
  ?exemell_sax_attrval(Input,State);
?exemell_sax_attrval(<<Name,?WS,Input>>,State) ->
  ?exemell_sax_attrval(Input,?sax_attribute_name(Name,?sax_attribute_value(none,State)));
?exemell_sax_attrval(<<?nil,"=",Input>>,State) ->
  ?exemell_sax_attrval_(Input,State);
?exemell_sax_attrval(<<Name,"=",Input>>,State) ->
  ?exemell_sax_attrval_(Input,?sax_attribute_name(Name,?sax_attribute_value(none,State)));
?exemell_sax_attrval(<<?nil,">",Input>>,State) ->
  ?exemell_sax_parser(Input,?sax_close_tag_begin_block(Input,?sax_attribute_value(none,State)));
?exemell_sax_attrval(<<Name,">",Input>>,State) ->
  ?exemell_sax_parser(Input,?sax_close_tag_begin_block(Input,?sax_attribute_value(none,?sax_attribute_name(Name,?sax_attribute_value(none,State)))));
?exemell_sax_attrval(<<?nil,"/>",Input>>,State) ->
  ?exemell_sax_parser(Input,?sax_close_tag(Input,?sax_attribute_value(none,State)));
?exemell_sax_attrval(<<Name,"/>",Input>>,State) ->
  ?exemell_sax_parser(Input,?sax_close_tag(Input,?sax_attribute_value(none,?sax_attribute_name(Name,?sax_attribute_value(none,State))))).

?exemell_sax_attrval_(Input,State) -> parser:input(Input);
?exemell_sax_attrval_(<<?nil,?WS,Input>>,State) -> 
  ?exemell_sax_attrval_(Input,State);
?exemell_sax_attrval_(<<Val,?WS,Input>>,State) ->
  ?exemell_sax_attrs(Input,?sax_attribute_value(Val,State));
?exemell_sax_attrval_(<<?nil,"\"",Input>>,State) ->
  ?exemell_sax_attrval_quote(Input,?sax_attribute_begin_value(State));
?exemell_sax_attrval_(<<Val,">",Input>>,State) ->
  ?exemell_sax_parser(Input,?sax_close_tag_begin_block(Input,?sax_attribute_value(Val,State)));
?exemell_sax_attrval_(<<Val,"/>",Input>>,State) ->
  ?exemell_sax_parser(Input,?sax_close_tag(Input,?sax_attribute_value(Val,State))).

?exemell_sax_attrval_quote(Input,State) -> parser:input(Input);
?exemell_sax_attrval_quote(<<Text,"\"",Input>>,State) ->
  ?exemell_sax_attrs(Input,?sax_attribute_end_value(Input,?sax_attribute_value_text(Text,State)));
?exemell_sax_attrval_quote(<<Text,"&",Input>>,State) ->
  ?exemell_sax_attrval_quote_entity(Input,?sax_attribute_value_text(Text,State)).

?exemell_sax_attrval_quote_entity(Input,State) -> parser:input(Input);
?exemell_sax_attrval_quote_entity(<<Name,";",Input>>,State) ->
  ?exemell_sax_attrval_quote(Input,?sax_attribute_value_entity(Name,State)).

?exemell_sax_close(Input,State) -> parser:input(Input);
?exemell_sax_close(<<Tag,">",Input>>,State) ->
  ?exemell_sax_parser(Input,?sax_end_block(Tag,State)).

?exemell_sax_entity(Input,State) -> parser:input(Input);
?exemell_sax_entity(<<Name,";",Input>>,State) ->
  ?exemell_sax_parser(Input,?sax_entity(Name,State)).











