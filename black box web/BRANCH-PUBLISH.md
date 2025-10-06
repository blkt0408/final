Publish to a branch (gh-pages)

Run the script to create or update a branch with the full contents of the current folder and push it to the remote.

Example (PowerShell):

```powershell
cd "d:\black box web"
# create/update the gh-pages branch and push
.\create-branch-and-push.ps1 -Branch gh-pages -Remote origin

# If you need to force the update (careful):
.\create-branch-and-push.ps1 -Branch gh-pages -Remote origin -ForcePush
```

Then go to GitHub repo Settings → Pages and select branch `gh-pages` as the source.

This publishes the repository contents at:
https://<username>.github.io/<repo>/  (or https://<username>.github.io/ if repo is named username.github.io)
