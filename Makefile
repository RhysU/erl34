# Building generates Listing 4.1 on page 122 as file ebin/erl34.app
PROJECT             = erl34
PROJECT_DESCRIPTION = Erlang and OTP in Action Chapters 3--4
PROJECT_VERSION     = 0.1.0

# Building uses https://erlang.mk/ configured for spaces not tabs
SP = 4
include erlang.mk

# Targets documenting commands of interest
SHELL = /bin/bash
.PHONY: run-interpreter run-server run-application run-telnet

# Run Erlang interpreter with compiled output in search path.
REPL = erl -pa ebin
run-interpreter: ; $(REPL)

# Run RPC server per Section 3.3 on page 116
run-server: all; cat <(echo 'erl34_server:start_link(1055).') - | $(REPL)

# Run application per Section 4.3 on page 129
run-application: all; cat <(echo 'application:start(erl34).') - | $(REPL)

# Connect to a running erl34_server on the default port
run-telnet: ; rlwrap telnet localhost 1055

# Build any writeups if possible
include writeups.mk
handout.pdf: src/*.erl
