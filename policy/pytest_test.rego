package pytest

empty(value) {
  count(value) == 0
}

test_require_black {
  deny with input as {"pytest": {"addopts": "--isort"}}
}

test_require_isort {
  deny with input as {"pytest": {"addopts": "--black"}}
}

test_require_isort_and_black {
  deny with input as {"pytest": {"addopts": ""}}
}

test_recommend_coverage {
  warn with input as {"pytest": {"addopts": "--black --isort --mypy"}}
}

test_recommend_type_checker {
  warn with input as {"pytest": {"addopts": "--black --isort --cov"}}
}

test_valid_with_required_options {
  empty(deny) with input as {"pytest": {"addopts": "--black --isort"}}
}

test_no_warnings_with_recommended_options {
  empty(warn) with input as {"pytest": {"addopts": "--black --isort --mypy --cov"}}
}
