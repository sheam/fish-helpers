# Use ksshaskpass (KWallet) for SSH passphrase prompts even in a terminal.
# Without this, OpenSSH prompts directly on stdin and bypasses ksshaskpass/KWallet.
set -gx SSH_ASKPASS_REQUIRE prefer
