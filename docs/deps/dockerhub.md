## DockerHub

The `dockerhub` [dependency] provides a function called `docker_check_version` for checking for docker [immutable tags], it is controlled by the [make/deps/dockerhub.mk] Makefile.

To Enable it, add `dockerhub` to the `DEPENDENCIES` [environment variable] when invoking make to create the [`.env`] file.

```shell
make DEPENDENCIES=dockerhub
```

>[!TIP]
>The above example will also enable the `jq` and `host` [special dependencies] as it relies on it.

### Concept

The main concept is

- Retrieving the tags of a DockerHub repository through the DockerHub API
- Reducing the results by tags including the host processor architecture
- Retrieving the digest of the `latest` tag image for the host processor architecture
- Retrieving the [immutable tag][immutable tags] sharing the `latest` tag image digest
- Compare the [immutable tag][immutable tags] with the current tag

### Usage

#### Arguments

The `docker_check_version` method accepts the following arguments

| Description                                                   | Examples
|:--                                                            |:--
| dockerhub repository                                          | `alpine`, `rustfs/rustfs`
| current tag to check against                                  | `3.23.3`, `1.0.0-alpha.93`
| space delimited list of string to match against tags          | `edge`, `glibc`
| space delimited list of string to **not** match against tags  | `edge`, `glibc`

>[!NOTE]
>As per design the function `docker_check_version` excludes the `latest` tag to only check for Docker [immutable tags].

#### Example

This can be invoked with the [call function] from a Makefile as the bellow example.

```shell
.PHONY: test
test: jq
	$(call docker_check_version,alpine,3.23.3,,edge)
```

>[!TIP]
>The above example declares a [phony target] called `test` which checks if there is a newer tag than `3.23.3` for the `alpine` repository excluding tags matching `edge`.

>[!NOTE]
>It will also automatically install [JQ] when invoking `make test` because it has `jq` as [prerequisite].

Then when invoking `make test` this will output.

```shell
$ make test
💡 Image alpine new tag is 3.23.4 with digest sha256:4d889c14e7d5a73929ab00be2ef8ff22437e7cbc545931e52554a7b00e123d8b
```

[dependency]: ../deps.md
[make/deps/dockerhub.mk]: ../../make/deps/dockerhub.mk
[`.env`]: ../env.md#the-env-file
[environment variable]: ../env.md
[special dependencies]: ../deps.md#special-dependencies
[call function]: https://www.gnu.org/software/make/manual/make.html#The-call-Function
[phony target]: https://www.gnu.org/software/make/manual/make.html#Phony-Targets
[immutable tags]: https://docs.docker.com/docker-hub/repos/manage/hub-images/immutable-tags/#what-are-immutable-tags
[JQ]: https://github.com/jqlang/jq
[prerequisite]: https://www.gnu.org/software/make/manual/make.html#Rule-Syntax
