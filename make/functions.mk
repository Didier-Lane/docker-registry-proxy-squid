define download
curl -fSLo "$(2)" "$(1)"
endef

define checksum
DIGEST="$(1)"
ALG="$${DIGEST%:*}"
HASH="$${DIGEST#*:}"
echo "$${HASH}" "$(2)" | "$${ALG}sum" --check -
endef

define executable
chmod +x "$(1)"
endef

define untilde
$(subst ~,$(HOME),$(1))
endef

define release_install
binary="$(call untilde,$(5))"
$(call message,📥,Installing $(1) version,$(2),to,$${binary})
$(call download,$(3),$${binary})
$(call checksum,$(4),$${binary})
$(call executable,$${binary})
endef

define github_check_release_version
cache="$$( mktemp )"
result="$$( curl -sSL https://api.github.com/repos/$(1)/releases/latest > "$${cache}" )"
latest="$$( jq -r '.tag_name' < "$${cache}" )"
if [[ "$${latest}" == "$(2)" ]]; then
	$(call message,✅,Repository,$(1),is up to date with latest version,$${latest})
else
	digest="$$( jq -r '.assets[] | select(.name == "$(3)") | .digest' < "$${cache}" )"
	$(call message,💡,New version is,$${latest},with digest,$${digest})
fi
rm "$${cache}"
endef
