# Get your GitHub username
$USERNAME = gh api user --jq '.login'

Write-Host "Fetching repos for $USERNAME..."

# Loop through all repos owned by you (adjust --limit if you have more than 200)
$repos = gh repo list $USERNAME --limit 200 --json name --jq '.[].name'

foreach ($REPO in $repos) {
    Write-Host "Checking $USERNAME/$REPO..."

    # Find open PRs from imgbot
    $prNumbers = gh pr list --repo "$USERNAME/$REPO" --author "imgbot[bot]" --state open --json number --jq '.[].number'

    if (-not $prNumbers) {
        continue
    }

    foreach ($PR in $prNumbers) {
        Write-Host "Merging PR #$PR in $REPO..."
        gh pr merge $PR --repo "$USERNAME/$REPO" --merge --admin
        # Use --squash or --rebase instead of --merge if you prefer that strategy
        # --admin bypasses branch protection review requirements if you have admin rights
    }
}

Write-Host "Done."
