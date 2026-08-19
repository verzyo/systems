# ==============================================================================
# Terminal Colors & Logging Helpers
# ==============================================================================
log_title()   { gum style --border double --margin "1" --padding "1 2" --border-foreground 5 --foreground 5 "$@"; }
log_success() { gum style --foreground 2 "$@"; }
log_info()    { gum style --foreground 4 "$@"; }
log_step()    { gum style --foreground 5 "$@"; }
log_warn()    { gum style --foreground 3 "$@"; }
log_error()   { gum style --foreground 1 "$@"; }
log_dim()     { gum style --foreground 8 "$@"; }

# ==============================================================================
# Global Variables
# ==============================================================================
FLAKE_DIR="${FLAKE_DIR:-path:.}"
HOSTNAME=$(hostname)
PCRS="0+2+7+12"

# ==============================================================================
# Nix Evaluation Helper
# ==============================================================================
nix_eval() {
    local attr="$1"
    shift
    nix eval "$@" "${FLAKE_DIR}#nixosConfigurations.${HOSTNAME}${attr}"
}

# ==============================================================================
# Functions
# ==============================================================================

ensure_sudo() {
    if [ "$EUID" -ne 0 ]; then
        log_dim "Root privileges required."
        sudo -v
    fi
}

detect_luks_devices() {
    log_dim "Evaluating NixOS config for $HOSTNAME..."

    local devices
    devices=$(gum spin --spinner dot --title "Reading LUKS devices from config..." -- \
        nix eval --json "${FLAKE_DIR}#nixosConfigurations.${HOSTNAME}.config.boot.initrd.luks.devices" \
            --apply builtins.attrNames \
        | jq -r '.[]') || true

    if [ -z "$devices" ]; then
        log_error "No LUKS devices found in nixosConfigurations.$HOSTNAME.config.boot.initrd.luks.devices"
        exit 1
    fi

    local device_count
    device_count=$(echo "$devices" | wc -l)

    if [ "$device_count" -eq 1 ]; then
        LUKS_NAME="$devices"
        log_success "Found LUKS device: $LUKS_NAME"
    else
        log_step "Multiple LUKS devices found. Select one:"
        LUKS_NAME=$(echo "$devices" | gum choose) || {
            log_dim "No device selected. Exiting."
            exit 1
        }
    fi

    # Resolve the backing partition from the open LUKS volume
    if [ -e "/dev/mapper/$LUKS_NAME" ]; then
        LUKS_PARTITION=$(sudo cryptsetup status "$LUKS_NAME" 2>/dev/null | awk '/device:/ {print $2}')
        log_dim "Backing partition: $LUKS_PARTITION"
    else
        log_error "LUKS volume /dev/mapper/$LUKS_NAME is not open. Is this the right host?"
        exit 1
    fi
}

check_existing_enrollment() {
    log_dim "Checking for existing TPM2 enrollment on $LUKS_PARTITION..."

    local slots
    slots=$(sudo systemd-cryptenroll "$LUKS_PARTITION" 2>/dev/null) || true

    if echo "$slots" | grep -qi "tpm2"; then
        HAS_TPM=true
        log_warn "TPM2 is already enrolled on $LUKS_NAME ($LUKS_PARTITION)."
    else
        HAS_TPM=false
        log_dim "No existing TPM2 enrollment found."
    fi
}

enroll_tpm() {
    echo ""

    if [ "$HAS_TPM" == "true" ]; then
        log_step "Re-enrolling will wipe the existing TPM2 slot and create a new one."
        if ! gum confirm "Wipe existing TPM2 enrollment and re-enroll?"; then
            log_dim "Aborted."
            exit 0
        fi

        log_dim "Wiping existing TPM2 slot..."
        sudo systemd-cryptenroll "$LUKS_PARTITION" --wipe-slot=tpm2

        log_success "Existing TPM2 slot wiped."
    fi

    echo ""
    log_dim "Enrolling TPM2 with PCRs: $PCRS"
    log_dim "Device: $LUKS_PARTITION ($LUKS_NAME)"
    echo ""

    sudo systemd-cryptenroll "$LUKS_PARTITION" --tpm2-device=auto --tpm2-pcrs="$PCRS"

    echo ""
    log_success "TPM2 enrollment complete!"
    log_dim "Your $LUKS_NAME volume will now auto-unlock via TPM on boot."
}

# ==============================================================================
# Main Execution
# ==============================================================================
main() {
    log_title "TPM2 LUKS Enrollment"
    ensure_sudo
    detect_luks_devices
    check_existing_enrollment
    enroll_tpm

    echo ""
    gum style --border double --margin "1" --padding "1 2" --border-foreground 2 --foreground 2 \
        "TPM2 enrollment successful for $LUKS_NAME!"
}

main "$@"
