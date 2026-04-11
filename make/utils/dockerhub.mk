DOCKER_HUB_API_ENDPOINT	:= https://hub.docker.com/v2

define docker_api_get_tags
curl -fsSL \
	"$(DOCKER_HUB_API_ENDPOINT)/namespaces/$(1)/repositories/$(2)/tags" \
	| jq -c '[.results[] | select(.images[].architecture == "$(ARCH)")]'
endef

define jq_get_docker_latest_image_digest
extra=""
if [ ! -z "$(2)" ]; then
	for tag in $(2); do
		extra+=' | select(.name | contains("'"$${tag}"'") | not)'
	done
fi
jq -r '.[] | select(.name | contains("latest") | not)'"$${extra}"'
	| .images[] | select(.architecture == "$(ARCH)")' \
	< "$(1)" | jq -rs 'first | .digest'
endef

define jq_get_docker_tag_by_image_digest
jq -r '.[] | select(.name != "latest")
	| select(.images[].digest == "'"$(1)"'")' \
	< "$(2)" | jq -rs 'first | .name'
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
latestDigest="$$( $(call jq_get_docker_latest_image_digest,$${cache},$(3)) )"
latestTag="$$( $(call jq_get_docker_tag_by_image_digest,$${latestDigest},$${cache}) )"
if [[ "$${latestTag}" == "null" ]]; then
	$(call message,⚠️ ,Failed to resolve $(hl)$(1)$(rs) latest tag)
elif [[ "$${latestTag}" == "$(2)" ]]; then
	$(call message,✅,Image $(hl)$(1)$(rs) is up to date with tag $(hl)$(2)$(rs))
else
	$(call message,💡,Image $(hl)$(1)$(rs) new tag is $(hl)$${latestTag}$(rs) with digest $(hl)$${latestDigest}$(rs))
fi
rm "$${cache}"
endef
