# CultPodcasts.PublicDatabase

This is a repository where a publicly-available set of files will be published weekly that contains meta-data about Cult Podcasts.

The objective is to grow this to include all historic episodes, and to include episodes from a wider range of Podcasts that have included guests talking about their experience, or experts describing the Cultic phenomena.

The data is presented as json files.

See [CultPodcasts.DatabasePublisher](https://github.com/cultpodcasts/RedditPodcastPoster/tree/main/Console-Apps/CultPodcasts.DatabasePublisher) for the source-code for that produces this data in this form.

## Weekly update script

Run the weekly publish flow with:

```powershell
.\update.ps1
```

That script:

- deletes the existing `*.json` files in this repo
- runs `CultPodcasts.DatabasePublisher --use-v2`
- stages everything with `git add -A`
- creates a commit like `New episodes 19 April 2026`
- pushes the commit

If you ever need to override the date in the commit message, run:

```powershell
.\update.ps1 -CommitDate (Get-Date '2026-04-19')
```
