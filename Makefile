REBAR=`which rebar || echo ./rebar`

all: compile

compile:
	@$(REBAR) compile

clean:
	@$(REBAR) clean

tests: eunit

eunit:
	@$(REBAR) skip_deps=true eunit

docs:
	@$(REBAR) doc
