DOCKER_HUB_API_ENDPOINT	:= https://hub.docker.com/v2

define docker_api_get_tags
curl -fsSL \
	"$(DOCKER_HUB_API_ENDPOINT)/namespaces/$(1)/repositories/$(2)/tags" \
	| jq -c
endef

define docker_check_version
repository="$(1)"
if [[ "$${repository}" =~ .*/.* ]]; then
	namespace="$${repository%/*}"
	repository="$${repository#*/}"
else
	namespace="library"
fi
cache="$$( mktemp )"
$(call docker_api_get_tags,$${namespace},$${repository}) > "$${cache}"
latestDigest="$$( jq -r '.results[] | select(.name == "latest") | .digest' < "$${cache}" )"
latestTag="$$( jq '.results[] | select(.digest == "'"$${latestDigest}"'")
	| select(.name != "latest")' < "$${cache}" | jq -rs 'first | .name' )"
if [[ "$${latestTag}" == "$(2)" ]]; then
	$(call message,✅,Image $(hl)$(1)$(rs) is up to date with tag $(hl)$(2)$(rs))
else
	$(call message,💡,Image $(hl)$(1)$(rs) new tag is $(hl)$${latestTag}$(rs))
	digest="$$( jq -r '.results[] | select(.name == "'"$${latestTag}"'")
		| .images[] | select(.architecture == "$(ARCH)") | .digest' < "$${cache}" )"
	$(call message,📦,Image tag $(hl)$${latestTag}$(rs) digest is $(hl)$${digest}$(rs))
fi
rm "$${cache}"
endef
