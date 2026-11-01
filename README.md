# CultPodcasts.PublicDatabase

This is a repository where a publicly-available set of files will be published weekly that contains meta-data about Cult Podcasts.

The objective is to grow this to include all historic episodes, and to include episodes from a wider range of Podcasts that have included guests talking about their experience, or experts describing the Cultic phenomena.

The data is presented as json files.

See [CultPodcasts.DatabasePublisher](https://github.com/cultpodcasts/RedditPodcastPoster/tree/main/Console-Apps/CultPodcasts.DatabasePublisher) for the source-code for that produces this data in this form.

## Weekly update script

`update.ps1` runs the weekly publish. Its source of truth is [`Console-Apps/CultPodcasts.DatabasePublisher/PublicDatabaseScripts/update.ps1`](https://github.com/cultpodcasts/RedditPodcastPoster/blob/main/Console-Apps/CultPodcasts.DatabasePublisher/PublicDatabaseScripts/update.ps1) in RedditPodcastPoster. Copy it here again after every change; it warns when this copy differs from that clone's HEAD. The script's own help (`Get-Help .\update.ps1 -Full`) has the details.

It works in three separate runs. The dry run changes nothing in this repo, `-Apply` commits only locally, and only `-Push` pushes:

```powershell
.\update.ps1            # dry run: publish into a working folder and report what would change
.\update.ps1 -Apply     # the same, then copy the result into this repo and commit LOCALLY (never pushes)
.\update.ps1 -Push      # after reviewing that commit: push it (does not run the publisher)
```

- The existing `*.json` files in this repo are **not** deleted first. The publisher uses the files it published last time as its baseline. The script copies them into a working folder outside the repo (default `PublicDatabase-publish` beside it, or `-WorkFolder`) and runs `CultPodcasts.DatabasePublisher` there with `--migrations-out`.
- The script refuses a publisher exe too old to know `--migrations-out` (from before RedditPodcastPoster #1039).
- It reports the files added, removed and changed, plus the moved files and whether git records them as renames.
- With `-Apply` it checks the repo is clean, copies the working folder's `*.json` in, stages only the top-level `*.json`, checks the renames against the manifest and commits `New episodes <date>`. It prints how to review the commit and how to undo it.
- Publisher exit codes stop the run, and the repo is not changed:
  - `1`: refused, because the data is inconsistent or an item would vanish unexplained. For a removal you have checked, rerun with `-AcceptRemoval <fileKey or id>`.
  - `2`: unusable arguments or folder.
  - `3`: unexpected failure. The working folder may be partly updated; it is rebuilt from the repo on the next run.
- `--initial` (a publish into an empty folder) is only for a genuine first publish. The weekly script never passes it.
- Use `-PublisherExe` and `-SourceRepo` when the RedditPodcastPoster clone or the publisher exe isn't in the default place.

To override the date in the commit message:

```powershell
.\update.ps1 -Apply -CommitDate (Get-Date '2026-04-19')
```
