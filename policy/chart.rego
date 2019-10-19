package main

import data.kubernetes

deny[msg] {
	kubernetes.containers[container]
	[image_name, "latest"] = kubernetes.split_image(container.image)
	msg = sprintf("%s in the %s %s has an image, %s, using the latest tag", [container.name, kubernetes.kind, image_name, kubernetes.name])
}

# https://kubesec.io/basics/containers-resources-limits-memory
deny[msg] {
	kubernetes.containers[container]
	not container.resources.limits.memory
	msg = sprintf("%s in the %s %s does not have a memory limit set", [container.name, kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/containers-resources-limits-cpu/
deny[msg] {
	kubernetes.containers[container]
	not container.resources.limits.cpu
	msg = sprintf("%s in the %s %s does not have a CPU limit set", [container.name, kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/containers-securitycontext-capabilities-add-index-sys-admin/
deny[msg] {
	kubernetes.containers[container]
	kubernetes.added_capability(container, "CAP_SYS_ADMIN")
	msg = sprintf("%s in the %s %s has SYS_ADMIN capabilties", [container.name, kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/containers-securitycontext-capabilities-drop-index-all/
deny[msg] {
	kubernetes.containers[container]
	not kubernetes.dropped_capability(container, "all")
	msg = sprintf("%s in the %s %s doesn't drop all capabilities", [container.name, kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/containers-securitycontext-privileged-true/
deny[msg] {
	kubernetes.containers[container]
	container.securityContext.privileged
	msg = sprintf("%s in the %s %s is privileged", [container.name, kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/containers-securitycontext-readonlyrootfilesystem-true/
deny[msg] {
	kubernetes.containers[container]
	not container.securityContext.readOnlyRootFilesystem = true
	msg = sprintf("%s in the %s %s is not using a read only root filesystem", [container.name, kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/containers-securitycontext-runasnonroot-true/
deny[msg] {
	kubernetes.containers[container]
	not container.securityContext.runAsNonRoot = true
	msg = sprintf("%s in the %s %s is running as root", [container.name, kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/containers-securitycontext-runasuser/
deny[msg] {
	kubernetes.containers[container]
	container.securityContext.runAsUser < 10000
	msg = sprintf("%s in the %s %s has a UID of less than 10000", [container.name, kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/spec-hostaliases/
deny[msg] {
	kubernetes.pods[pod]
	pod.spec.hostAliases
	msg = sprintf("The %s %s is managing host aliases", [kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/spec-hostipc/
deny[msg] {
	kubernetes.pods[pod]
	pod.spec.hostIPC
	msg = sprintf("%s %s is sharing the host IPC namespace", [kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/spec-hostnetwork/
deny[msg] {
	kubernetes.pods[pod]
	pod.spec.hostNetwork
	msg = sprintf("The %s %s is connected to the host network", [kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/spec-hostpid/
deny[msg] {
	kubernetes.pods[pod]
	pod.spec.hostPID
	msg = sprintf("The %s %s is sharing the host PID", [kubernetes.kind, kubernetes.name])
}

# https://kubesec.io/basics/spec-volumes-hostpath-path-var-run-docker-sock/
deny[msg] {
	kubernetes.volumes[volume]
	volume.hostpath.path = "/var/run/docker.sock"
	msg = sprintf("The %s %s is mounting the Docker socket", [kubernetes.kind, kubernetes.name])
}
