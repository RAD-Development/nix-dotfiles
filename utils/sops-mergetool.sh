#!/usr/bin/env bash
# Exit on first error and verify variables have been set/passed via CLI
set -eu

# Rename our variables to friendlier equivalents
# https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver
base="$1"; local_="$2"; remote="$3"; merged="$4"

# Resolve our default mergetool
# https://github.com/git/git/blob/v2.8.2/git-mergetool--lib.sh#L3
mergetool="$(git config --get merge.tool)"
GIT_DIR="$(git --exec-path)"
if test "$mergetool" = ""; then
  echo "No default \`merge.tool\` was set for \`git\`. Please set one via \`git config --set merge.tool <tool>\`" 1>&2
  exit 1
fi

# Create file names for our decrypted contents
#   example_LOCAL_2823.yaml -> example_LOCAL_2823.decrypted.yaml
extension=".${base##*.}"
base_decrypted="${base/$extension/.decrypted$extension}"
local_decrypted="${local_/$extension/.decrypted$extension}"
remote_decrypted="${remote/$extension/.decrypted$extension}"
merged_decrypted="${base_decrypted/_BASE_/_MERGED_}"
backup_decrypted="${base_decrypted/_BASE_/_BACKUP_}"

# If anything goes wrong, then delete our decrypted files
handle_trap_exit () {
  rm $base_decrypted || true
  rm $local_decrypted || true
  rm $remote_decrypted || true
  rm $merged_decrypted || true
  rm $backup_decrypted || true
}
trap handle_trap_exit EXIT

# Decrypt our file contents
sops --decrypt --show-master-keys "$base" > "$base_decrypted"
sops --decrypt --show-master-keys "$local_" > "$local_decrypted"
sops --decrypt --show-master-keys "$remote" > "$remote_decrypted"

# Create a merge-diff to compare against
set +e
git merge-file -p "$local_decrypted" "$base_decrypted" "$remote_decrypted" > "$merged_decrypted"
set -e
cp "$merged_decrypted" "$backup_decrypted"

# Set up variables for our mergetool
# https://github.com/git/git/blob/v2.8.2/mergetools/meld
# https://github.com/git/git/blob/v2.8.2/git-mergetool--lib.sh#L95-L111
export LOCAL="$local_decrypted"
export BASE="$base_decrypted"
export REMOTE="$remote_decrypted"
export MERGED="$merged_decrypted"
export BACKUP="$backup_decrypted"

# Load our mergetool scripts
source "$GIT_DIR/git-mergetool--lib"
source "$GIT_DIR/mergetools/$mergetool"

# Override `check_unchanged` with a custom script
check_unchanged () {
  # If the contents haven't changed, then fail
  if test "$MERGED" -nt "$BACKUP"; then
    return 0
  else
    exit 1
  fi
}

# Run our mergetool
set +eu
export merge_tool_path="$(get_merge_tool_path "$mergetool")"
merge_cmd
set -eu

# Re-encrypt content
sops --encrypt "$merged_decrypted" > "$merged"

