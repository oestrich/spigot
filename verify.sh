set -e

mix format --check-formatted
mix compile --force --warnings-as-errors
mix test
mix credo
