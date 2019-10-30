# -*- mode: Python -*-

settings = read_json("tilt_option.json", default={})
default_registry(settings.get("default_registry", "docker.io/garethr"))

docker_build("garethr/snyky", ".",
  live_update=[
    fall_back_on("Pipfile"),
    fall_back_on("Pipfile.lock"),
    sync('./src', '/app'),
    restart_container(),
  ]
)

k8s_yaml(helm('snyky'))

k8s_resource("snyky", port_forwards=8100)
