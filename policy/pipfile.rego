package pipfile

deny[msg] {
	version := to_number(input.requires.python_version)
	version < 3
	msg := sprintf("Should be using Python 3, currently Using Python %v", [version])
}

deny[msg] {
	not input.source[i].verify_ssl = true
	name := input.source[i].name
	msg := sprintf("You must verify SSL for %v", [name])
}
