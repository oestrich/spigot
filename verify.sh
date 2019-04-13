set -e

mix compile --force --warnings-as-errors
mix test
mix credo
