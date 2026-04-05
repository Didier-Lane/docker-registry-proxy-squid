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
$(call message,📥,Installing $(hl)$(1)$(rs) version $(hl)$(2)$(rs) to $(hl)$${binary}$(rs))
$(call download,$(3),$${binary})
$(call checksum,$(4),$${binary})
$(call executable,$${binary})
endef

define github_check_release_version
cache="$$( mktemp )"
result="$$( curl -sSL https://api.github.com/repos/$(1)/releases/latest > "$${cache}" )"
latest="$$( jq -r '.tag_name' < "$${cache}" )"
if [[ "$${latest}" == "$(2)" ]]; then
	$(call message,✅,Repository $(hl)$(1)$(rs) is up to date with latest version $(hl)$${latest}$(rs))
else
	$(call message,💡,Repository $(hl)$(1)$(rs) new version is $(hl)$${latest}$(rs))
	for asset in $(3); do
		digest="$$( jq -r '.assets[] | select(.name == "'"$${asset}"'") | .digest' < "$${cache}" )"
		$(call message,📦,Asset $(hl)$${asset}$(rs) digest is $(hl)$${digest}$(rs))
	done
fi
rm "$${cache}"
endef
