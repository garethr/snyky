package docker

deny[msg] {
	input[i].Cmd == "from"
	[image_name, "latest"] = split_image(input[i].Value[0])
	msg = sprintf("Using latest tag on base image %s", [image_name])
}

split_image(image) = [image_name, tag] {
	[image_name, tag] = split(image, ":")
}
