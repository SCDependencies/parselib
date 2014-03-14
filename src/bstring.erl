-module(bstring).

%% API
-export([split/2]).
-export([trim/1, ltrim/1, rtrim/1]).
-export([to_lower/1, to_upper/1]).

-define(IS_BLANK(Blank), 
    Blank == $\s;
    Blank == $\t;
    Blank == $\n;
    Blank == $\r
).

%% API
split(BinString, Pattern) ->
    case binary:match(BinString, Pattern) of
        {A,B} ->
            <<Before:A/binary, _:B/binary, After/binary>> = BinString,
            {Before, After};
        nomatch ->
            {BinString, <<>>}
    end.

trim(Binary) ->
    rtrim(ltrim(Binary)).

ltrim(<<Blank, BinString/binary>>) when ?IS_BLANK(Blank) ->
    ltrim(BinString);
ltrim(BinString) -> 
    BinString.

rtrim(<<>>) ->
    <<>>;
rtrim(BinString) ->
    case binary:last(BinString) of
        Blank when ?IS_BLANK(Blank) ->
            Size = size(BinString) - 1,
            <<Part:Size/binary, _/binary>> = BinString,
            rtrim(Part);
        _ ->
            BinString
    end.

to_lower(BinString) ->
    << <<(to_lower_char(C))>> || <<C:8>> <= BinString>>.

to_upper(BinString) ->
    << <<(to_upper_char(C))>> || <<C:8>> <= BinString>>.

%% internal
to_lower_char(C) when is_integer(C), $A =< C, C =< $Z ->
    C+32;
to_lower_char(C) when is_integer(C), 16#C0 =< C, C =< 16#D6 ->
    C+32;
to_lower_char(C) when is_integer(C), 16#D8 =< C, C =< 16#DE ->
    C+32;
to_lower_char(C) ->
    C.

to_upper_char(C) when is_integer(C), $a =< C, C =< $z ->
    C-32;
to_upper_char(C) when is_integer(C), 16#E0 =< C, C =< 16#F6 ->
    C-32;
to_upper_char(C) when is_integer(C), 16#F8 =< C, C =< 16#FE ->
    C-32;
to_upper_char(C) ->
    C.

%% Tests
-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").

split_test_() -> 
[
    ?_assertEqual({<<"Before">>, <<"After">>}, 
        split(<<"Before After">>, <<" ">>))
].

trim_test_() -> 
[
    ?_assertEqual(<<"test  ">>, ltrim(<<"  test  ">>)),
    ?_assertEqual(<<"  test">>, rtrim(<<"  test  ">>)),
    ?_assertEqual(<<"test">>,    trim(<<"  test  ">>))
].

to_lower_test_() -> 
[
    ?_assertEqual(<<"  test  ">>, to_lower(<<"  TEST  ">>))
].

to_upper_test_() -> 
[
    ?_assertEqual(<<"  TEST  ">>, to_upper(<<"  test  ">>))
].


-endif.
