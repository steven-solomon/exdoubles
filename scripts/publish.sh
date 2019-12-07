#!/usr/bin/env bash

/Users/$(whoami)/.asdf/installs/elixir/1.8.2/.mix/escripts/ex_doc "Elephant" "0.1.0" _build/dev/lib/elephant/ebin -m "Elephant" -u https://github.com/steven-solomon/elephant
