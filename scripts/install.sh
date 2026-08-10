# ==============================================================================
# Terminal Colors & Logging Helpers
# ==============================================================================
# We use standard 16-color ANSI integers (0-15) so it seamlessly inherits the terminal's theme!
log_title()   { gum style --border double --margin "1" --padding "1 2" --border-foreground 5 --foreground 5 "$@"; }
log_success() { gum style --foreground 2 "$@"; }
log_info()    { gum style --foreground 4 "$@"; }
log_step()    { gum style --foreground 5 "$@"; }
log_warn()    { gum style --foreground 3 "$@"; }
log_error()   { gum style --foreground 1 "$@"; }
log_dim()     { gum style --foreground 8 "$@"; }

# ==============================================================================
# Global Variables & Trap Cleanup
# ==============================================================================
TARGET_DIR="${TARGET_DIR:-$HOME/systems}"
REPO_URL="${REPO_URL:-https://github.com/verzyo/systems}"
FLAKE_DIR="path:$TARGET_DIR"
INSTALL_SUCCESS=false
SELECTED_HOST=""
MAIN_USER=""

cleanup() {
    set +e # Don't exit on errors during cleanup
    unset SOPS_AGE_KEY

    # If the installation succeeded, these will be wiped.
    # Otherwise, they remain in memory so we can retry quickly.
    if [ "$INSTALL_SUCCESS" == "true" ]; then
        log_dim "Installation successful. Securely cleaning up sensitive data from RAM..."

        if [ -f ~/.ssh/id_ed25519 ]; then
            shred -u ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub 2>/dev/null || rm -f ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub
        fi

        if command -v rbw &>/dev/null; then
            rbw stop-agent 2>/dev/null || true
            rbw purge 2>/dev/null || true
        fi
    fi
}

trap cleanup EXIT

# ==============================================================================
# Nix Evaluation Helper
# ==============================================================================
nix_eval() {
    # Takes a flake attribute path and optional args, evaluates it as JSON (or raw).
    # Usage: nix_eval ".config.modules.sops.enable" [--raw|--json]
    # NOTE: stderr is NOT suppressed — callers must redirect explicitly when needed.
    local attr="$1"
    shift
    nix eval --extra-experimental-features "nix-command flakes" "$@" "${FLAKE_DIR}#nixosConfigurations.${SELECTED_HOST}${attr}"
}

# ==============================================================================
# Functions
# ==============================================================================

check_network() {
    log_dim "Checking network connectivity..."

    if ! ping -c 1 -W 5 github.com &>/dev/null; then
        log_error "Error: No internet connection detected!"
        log_warn "Please connect to the internet and try again."

        exit 1
    fi
}

setup_repo() {
    if [ ! -d "$TARGET_DIR" ]; then
        log_dim "Cloning configuration to $TARGET_DIR..."
        git clone "$REPO_URL" "$TARGET_DIR"
    else
        log_dim "Configuration repository already exists at $TARGET_DIR."
    fi
}

select_host() {
    local hosts
    hosts=$(gum spin --spinner dot --title "Detecting available hosts..." -- \
        nix eval --extra-experimental-features "nix-command flakes" --json \
            "${FLAKE_DIR}#nixosConfigurations" --apply builtins.attrNames \
        | jq -r '.[]') || true

    if [ -z "$hosts" ]; then
        log_error "Error: No hosts found in ${FLAKE_DIR}#nixosConfigurations!"
        exit 1
    fi

    log_step "Select the host to be installed:"
    SELECTED_HOST=$(echo "$hosts" | gum choose) || {
        log_dim "No host selected. Exiting."
        exit 1
    }

    if [ -z "$SELECTED_HOST" ]; then
        log_dim "No host selected. Exiting."
        exit 1
    fi

    log_success "You have selected to install: $SELECTED_HOST"
}

handle_disko() {
    local disks="" skip_disko=false

    if gum spin --spinner dot --title "Checking disko configuration for $SELECTED_HOST..." -- \
        sh -c "nix eval --extra-experimental-features 'nix-command flakes' \
            '${FLAKE_DIR}#nixosConfigurations.${SELECTED_HOST}.config.disko.devices.disk' \
            --apply builtins.attrNames &>/dev/null"; then
        disks=$(nix_eval ".config.disko.devices.disk" --json --apply builtins.attrNames 2>/dev/null | jq -r '.[]') || true
    fi

    echo ""
    if [ -n "$disks" ]; then
        log_step "Disko configuration detected for $SELECTED_HOST."

        if mountpoint -q /mnt; then
            log_warn "Target partitions appear to be already mounted at /mnt."
            if gum confirm "Do you want to skip disk formatting and use the existing mounts?"; then
                skip_disko=true
            fi
        fi

        if [ "$skip_disko" != "true" ]; then
            log_error "WARNING: This will ERASE all data on the target disks!"
            if ! gum confirm "Are you certain the disko configuration is correct?"; then
                log_dim "Aborting."
                exit 1
            fi

            log_dim "Running disko..."
            sudo "$(command -v disko)" --mode destroy,format,mount --flake "${FLAKE_DIR}#${SELECTED_HOST}"
        else
            log_success "Skipping disko formatting..."
        fi
    else
        log_dim "No disko configuration detected for $SELECTED_HOST."
        lsblk
        echo ""

        if ! gum confirm "Have you properly formatted and mounted your partitions?"; then
            log_error "Please format and mount your partitions (usually to /mnt) first. Aborting."
            exit 1
        fi
    fi
}

handle_sops() {
    echo ""
    local is_sops_enabled
    is_sops_enabled=$(nix_eval ".config.modules.sops.enable" --json) || true

    if [ "$is_sops_enabled" != "true" ]; then
        log_dim "No SOPS configuration detected for $SELECTED_HOST. Skipping secrets sync."
        return 0
    fi

    log_success "SOPS configuration detected."

    local live_ssh_dir="/etc/ssh"
    local mnt_base="/mnt"
    local mnt_ssh_dir="$mnt_base/etc/ssh"

    sudo mkdir -p "$live_ssh_dir" "$mnt_ssh_dir"

    if [ ! -f "$live_ssh_dir/ssh_host_ed25519_key" ]; then
        log_dim "Generating host SSH key to $live_ssh_dir..."
        sudo "$(command -v ssh-keygen)" -t ed25519 -N "" -C "root@$SELECTED_HOST" -f "$live_ssh_dir/ssh_host_ed25519_key"
    else
        log_dim "SSH key already exists at $live_ssh_dir/ssh_host_ed25519_key"
    fi

    log_dim "Copying SSH keys to $mnt_ssh_dir..."
    sudo cp "$live_ssh_dir"/ssh_host_ed25519_key* "$mnt_ssh_dir/"

    log_dim "Checking Preservation configuration for $SELECTED_HOST..."
    local is_pres_enabled
    is_pres_enabled=$(nix_eval ".config.modules.preservation.enable" --json) || true

    if [ "$is_pres_enabled" == "true" ]; then
        local pres_subvol pres_ssh_dir
        pres_subvol=$(nix_eval ".config.modules.preservation.preservedSubvolume" --raw)
        log_success "Preservation is enabled. Preserved subvolume: $pres_subvol"

        pres_ssh_dir="$mnt_base/$pres_subvol/etc/ssh"
        log_dim "Copying SSH keys to $pres_ssh_dir..."
        sudo mkdir -p "$pres_ssh_dir"
        sudo cp "$live_ssh_dir"/ssh_host_ed25519_key* "$pres_ssh_dir/"
    else
        log_dim "Preservation is not enabled."
    fi

    echo ""
    log_dim "Converting SSH key to Age key..."
    local age_key sops_yaml current_key
    age_key=$(ssh-to-age -i "$live_ssh_dir/ssh_host_ed25519_key.pub")
    log_success "Host Age key: $age_key"

    sops_yaml="$TARGET_DIR/.sops.yaml"
    if [ -f "$sops_yaml" ]; then
        log_dim "Checking .sops.yaml for $SELECTED_HOST..."
        if yq eval ".keys[] | select(anchor == \"$SELECTED_HOST\")" "$sops_yaml" | grep -q "age1"; then
            current_key=$(yq eval ".keys[] | select(anchor == \"$SELECTED_HOST\")" "$sops_yaml")
            if [ "$current_key" != "$age_key" ]; then
                log_step "Key has changed. Updating .sops.yaml..."
                yq eval -i "(.keys[] | select(anchor == \"$SELECTED_HOST\")) = \"$age_key\"" "$sops_yaml"
                log_success ".sops.yaml updated successfully."
            else
                log_dim "Age key in .sops.yaml is already up-to-date."
            fi
        else
            log_warn "Warning: Anchor &$SELECTED_HOST not found in .sops.yaml!"
        fi
    fi

    echo ""
    handle_bitwarden_keys
}

handle_bitwarden_keys() {
    local have_ssh_key=false

    if [ -f ~/.ssh/id_ed25519 ]; then
        log_success "Personal SSH key already exists in memory."
        if gum confirm "Do you want to reuse it and skip fetching from Bitwarden?"; then
            have_ssh_key=true
        fi
    fi

    if [ "$have_ssh_key" != "true" ]; then
        log_step "We need your personal SSH key from Bitwarden to decrypt and re-encrypt secrets."

        local bw_email="" saved_email=""
        if [ -f "$HOME/.config/rbw/config.json" ]; then
            saved_email=$(jq -r '.email // empty' "$HOME/.config/rbw/config.json" 2>/dev/null) || true
            if [ -n "$saved_email" ] && gum confirm "Is this your Bitwarden email? ($saved_email)"; then
                bw_email="$saved_email"
            fi
        fi

        if [ -z "$bw_email" ]; then
            log_step "Please enter your Bitwarden email:"
            bw_email=$(gum input --placeholder "Bitwarden Email") || {
                log_dim "Email input cancelled. Skipping Bitwarden sync."
                return 0
            }
            if [ -n "$bw_email" ]; then
                log_dim "Configuring rbw email..."
                rbw config set email "$bw_email"
            fi
        fi

        if [ -n "$bw_email" ]; then
            rbw config set pinentry pinentry-tty
            log_dim "Logging into Bitwarden (this will prompt for your Master Password)..."
            rbw login

            local ssh_keys="" selected_id=""
            ssh_keys=$(gum spin --spinner dot --title "Fetching SSH keys from Bitwarden..." -- rbw list --raw | jq -r '
              [
                .[] | select(.type == "SSH Key") |
                "Name: \(.name)\(if .folder != null then "\n  Folder: \(.folder)" else "" end)~~~\(.id)"
              ] | join("@@")
            ') || true

            if [ -n "$ssh_keys" ]; then
                log_step "Select your personal SSH key to import:"
                selected_id=$(printf "%s" "$ssh_keys" | gum choose --input-delimiter="@@" --label-delimiter="~~~") || {
                    log_dim "No key selected."
                    return 0
                }

                if [ -n "$selected_id" ]; then
                    log_dim "Fetching SSH key (ID: $selected_id)..."
                    mkdir -p ~/.ssh
                    rbw get "$selected_id" --field public_key > ~/.ssh/id_ed25519.pub
                    rbw get "$selected_id" --field private_key > ~/.ssh/id_ed25519
                    chmod 600 ~/.ssh/id_ed25519
                    chmod 644 ~/.ssh/id_ed25519.pub

                    log_success "Personal SSH key imported successfully!"
                    have_ssh_key=true
                else
                    log_dim "No key selected."
                fi
            else
                log_warn "No SSH keys found in your Bitwarden vault."
            fi
        else
            log_dim "Email not provided. Skipping Bitwarden sync."
        fi
    fi

    if [ "$have_ssh_key" == "true" ]; then
        export SOPS_AGE_KEY
        SOPS_AGE_KEY=$(ssh-to-age -private-key -i ~/.ssh/id_ed25519)

        local secret_files
        mapfile -t secret_files < <(find "$TARGET_DIR" -type f -name "secrets.json")

        if [ ${#secret_files[@]} -gt 0 ]; then
            log_dim "Running sops updatekeys on ${#secret_files[@]} file(s) in $TARGET_DIR..."
            (
                cd "$TARGET_DIR"
                for secret_file in "${secret_files[@]}"; do
                    rel_path="${secret_file#"$TARGET_DIR/"}"
                    log_dim "Updating keys for $rel_path..."
                    sops updatekeys -y "$rel_path"
                done
            )
            log_success "Secrets re-encrypted successfully!"
        fi
    fi
}

run_nixos_install() {
    echo ""
    log_dim "Preparing to run nixos-install..."

    local install_args=("--no-channel-copy")
    local needs_no_root_pass=false
    local is_pres_enabled hashed_pass pass

    is_pres_enabled=$(nix_eval ".config.modules.preservation.enable" --json) || true

    if [ "$is_pres_enabled" == "true" ]; then
        needs_no_root_pass=true
    else
        hashed_pass=$(nix_eval ".config.users.users.root.hashedPasswordFile" --json 2>/dev/null || echo "null")
        pass=$(nix_eval ".config.users.users.root.passwordFile" --json 2>/dev/null || echo "null")

        if [ "$hashed_pass" != "null" ] || [ "$pass" != "null" ]; then
            needs_no_root_pass=true
        fi
    fi

    if [ "$needs_no_root_pass" == "true" ]; then
        log_warn "Detected preservation or root secrets. Adding --no-root-password to installation arguments."
        install_args+=("--no-root-password")
    fi

    echo ""
    log_step "Ready to install NixOS for $SELECTED_HOST!"

    if gum confirm "Would you like to update the flake.lock before installing?"; then
        log_dim "Updating flake lock..."
        nix flake update --flake "$TARGET_DIR"
    fi

    log_dim "Command: sudo nixos-install ${install_args[*]} --flake \"$FLAKE_DIR#$SELECTED_HOST\""

    if gum confirm "Do you want to proceed with the installation?"; then
        log_step "Installing NixOS..."
        sudo nixos-install "${install_args[@]}" --flake "$FLAKE_DIR#$SELECTED_HOST"
        log_success "Installation complete!"
    else
        log_error "Installation aborted."
        exit 1
    fi
}

copy_repo_and_keys() {
    log_dim "Copying configuration to the new system..."

    local normal_users dest_dir
    normal_users=$(nix_eval ".config.users.users" --json | jq -r 'to_entries | map(select(.value.isNormalUser == true)) | .[].key') || true

    if [ -n "$normal_users" ]; then
        log_step "Which user should own the systems repository?"
        MAIN_USER=$(echo "$normal_users" | gum choose) || {
            log_dim "No user selected. Skipping repository copy."
            return 0
        }

        if [ -n "$MAIN_USER" ]; then
            dest_dir="/mnt/home/$MAIN_USER/systems"
            log_dim "Copying systems repository to $dest_dir..."
            sudo mkdir -p "/mnt/home/$MAIN_USER"
            sudo cp -r "$TARGET_DIR" "$dest_dir"

            if [ -f ~/.ssh/id_ed25519 ]; then
                log_dim "Copying personal SSH key to $MAIN_USER..."
                sudo mkdir -p "/mnt/home/$MAIN_USER/.ssh"
                sudo cp ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub "/mnt/home/$MAIN_USER/.ssh/"

                sudo nixos-enter -c "\
                    chown -R $MAIN_USER:users /home/$MAIN_USER/systems /home/$MAIN_USER/.ssh && \
                    chmod 700 /home/$MAIN_USER/.ssh && \
                    chmod 600 /home/$MAIN_USER/.ssh/id_ed25519 && \
                    chmod 644 /home/$MAIN_USER/.ssh/id_ed25519.pub"
                log_success "Successfully copied SSH keys!"
            else
                sudo nixos-enter -c "chown -R $MAIN_USER:users /home/$MAIN_USER/systems"
            fi

            log_success "Successfully copied and transferred ownership to $MAIN_USER!"
        else
            log_dim "No user selected. Skipping repository copy."
        fi
    else
        log_dim "No normal users found in the configuration. Skipping repository copy."
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================
main() {
    log_title "Welcome to the NixOS interactive installer!"
    check_network
    setup_repo
    select_host
    handle_disko
    handle_sops
    run_nixos_install
    copy_repo_and_keys

    echo ""
    gum style --border double --margin "1" --padding "1 2" --border-foreground 2 --foreground 2 "You can now reboot into your new system!"
    INSTALL_SUCCESS=true
}

main "$@"
