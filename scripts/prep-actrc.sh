# Determine the kubeconfig file path
# If the KUBECONFIG environment variable is not set, use the default kubeconfig file located at ~/.kube/config on Linux or macOS, or %USERPROFILE%\.kube\config on Windows.

KUBECONFIG=${KUBECONFIG:-$HOME/.kube/config}

# Replace __KUBECONFIG_PATH__ in the file .actrc.tpl with the value of the KUBECONFIG environment variable.
# and write the output to a new file called .actrc

sed "s|__KUBECONFIG_PATH__|$KUBECONFIG|g" .actrc.tpl > .actrc