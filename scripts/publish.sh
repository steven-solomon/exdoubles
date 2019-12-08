#!/usr/bin/env bash

/Users/$(whoami)/.asdf/installs/elixir/1.8.2/.mix/escripts/ex_doc "ExDoubles" "0.1.1" _build/dev/lib/exdoubles/ebin -m "ExDoubles" -u https://github.com/steven-solomon/elephant
