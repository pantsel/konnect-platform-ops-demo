# Determine the kubeconfig file path
# If the KUBECONFIG environment variable is not set, use the default kubeconfig file located at ~/.kube/config on Linux or macOS, or %USERPROFILE%\.kube\config on Windows.

KUBECONFIG=${KUBECONFIG:-$HOME/.kube/config}

# Replace __KUBECONFIG_PATH__ in the file .actrc.tpl with the value of the KUBECONFIG environment variable.
# and write the output to a new file called .actrc
# Strip "/config" from KUBECONFIG if defined
KUBECONFIG=${KUBECONFIG%/config}

sed -e "s|__KUBECONFIG_PATH__|$KUBECONFIG|g" -e "s|__MINIOCLIENT_PATH__|$MINIOCLIENT_PATH|g" -e "s|__VAULTCLIENT_PATH__|$VAULTCLIENT_PATH|g"  .actrc.tpl > .actrc