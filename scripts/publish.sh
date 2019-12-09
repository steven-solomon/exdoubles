#!/usr/bin/env bash

set -euxo -pipefail

/Users/$(whoami)/.asdf/installs/elixir/1.8.2/.mix/escripts/ex_doc "ExDoubles" "0.2.0" _build/dev/lib/exdoubles/ebin -m "ExDoubles" -u https://github.com/steven-solomon/exdoubles
mix hex.publish
