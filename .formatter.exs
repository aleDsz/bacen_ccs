# Used by "mix format"
[
  import_deps: [:ecto],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [field: 3, assert_valid_changeset: 1, refute_valid_changeset: 1]
]
