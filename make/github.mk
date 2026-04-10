define github_check_release_version
cache="$$( mktemp )"
result="$$( curl -sSL https://api.github.com/repos/$(1)/releases/latest > "$${cache}" )"
latest="$$( jq -r '.tag_name' < "$${cache}" )"
if [[ "$${latest}" == "$(2)" ]]; then
	$(call message,✅,Repository $(hl)$(1)$(rs) is up to date with latest version $(hl)$${latest}$(rs))
else
	$(call message,💡,Repository $(hl)$(1)$(rs) new version is $(hl)$${latest}$(rs))
	if [ ! -z "$(3)" ]; then
		for asset in $(3); do
			digest="$$( jq -r '.assets[] | select(.name == "'"$${asset}"'") | .digest' < "$${cache}" )"
			$(call message,📦,Asset $(hl)$${asset}$(rs) digest is $(hl)$${digest}$(rs))
		done
	fi
fi
rm "$${cache}"
endef
