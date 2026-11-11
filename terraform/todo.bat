
$PROJECT_ID="clgcporg10-157"
$PROJECT_NUMBER="957162898991" 
$GITHUB_ORG_REPO = "lucafeudi/wiz"
$REGION = "europe-west1"

gcloud iam workload-identity-pools providers create-oidc "github-provider" `
    --project=$PROJECT_ID `
    --location="global" `
    --workload-identity-pool="github-actions-pool" `
    --display-name="GitHub Provider" `
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.ref=assertion.ref" `
    --attribute-condition="attribute.repository==lucafeudi/wiz" `
    --issuer-uri="https://token.actions.githubusercontent.com"