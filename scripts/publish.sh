#!/usr/bin/env bash

/Users/$(whoami)/.asdf/installs/elixir/1.8.2/.mix/escripts/ex_doc "ExDoubles" "0.2.0" _build/dev/lib/ex_doubles/ebin -m "ExDoubles" -u https://github.com/steven-solomon/elephant
