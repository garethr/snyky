package lib.kubernetes

name = input.review.object.metadata.name

kind = input.review.object.kind

is_service {
  kind = "Service"
}

is_deployment {
  kind = "Deployment"
}

is_pod {
  kind = "Pod"
}

split_image(image) = [image, "latest"] {
  not contains(image, ":")
}

split_image(image) = [image_name, tag] {
  [image_name, tag] = split(image, ":")
}

pod_containers(pod) = all_containers {
  keys = {"containers", "initContainers"}
  all_containers = [c | keys[k]; c = pod.spec[k][_]]
}

containers[container] {
  pods[pod]
  all_containers = pod_containers(pod)
  container = all_containers[_]
}

containers[container] {
  all_containers = pod_containers(input.review.object)
  container = all_containers[_]
}

pods[pod] {
  is_deployment
  pod = input.review.object.spec.template
}

pods[pod] {
  is_pod
  pod = input.review.object
}

volumes[volume] {
  pods[pod]
  volume = pod.spec.volumes[_]
}

dropped_capability(container, cap) {
  container.securityContext.capabilities.drop[_] == cap
}

added_capability(container, cap) {
  container.securityContext.capabilities.add[_] == cap
}
