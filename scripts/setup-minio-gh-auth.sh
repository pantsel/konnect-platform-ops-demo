set -e

GH_MINIO_URL="http://localhost:9000"
GH_MINIO_OIDC_APP_CLIENT_ID=$1
GH_MINIO_OIDC_APP_CLIENT_SECRET=$2

mc alias set myminio $GH_MINIO_URL minio-root-user minio-root-password

mc admin config set myminio identity_openid \
    provider="https://token.actions.githubusercontent.com" \
    config_url="https://token.actions.githubusercontent.com/.well-known/openid-configuration" \
    client_id="$GH_MINIO_OIDC_APP_CLIENT_ID" \
    client_secret="$GH_MINIO_OIDC_APP_CLIENT_SECRET" \
    claim_name="sub" \
    scopes="openid,profile,email" \
    redirect_uri="$GH_MINIO_URL/oauth_callback"

mc admin service restart myminio