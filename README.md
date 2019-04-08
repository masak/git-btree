The basic idea of `git-btree` is that humans have an intuition of what it means for a commit to "be on a branch" that's not at all captured by vanilla Git, but we can capture it with a custom tool.

The tool works like this:

```
$ git btree
. master
  . feature-a1 [+2]
  ... feature-a2 [+3]
  . feature-b [+1]
```

The branches are ordered hierarchically according to their commit-ancestor relationships. We'll define _parent branch_ and _child branch_ as meaning the obvious things. (But also see later about stale branches.) In this case, the commit history would look like this:

```
...--o master
     |
     +--o--o feature-a1 (two commits ahead of master)
     |     |
     |     +--o--o--o feature-a2 (three commits ahead of feature-a1, five ahead of master)
     |
     +--o feature-b (one commit ahead of master)
```

On the #git channel once when I mentioned it, someone said when I mentioned hierarchical branches that they generally try to avoid that sort of thing. I actually agree with that; it's not an end in itself &mdash; but it does happen occasionally, for example when a task naturally divides into two consecutive PRs.

In other words, I don't expect there to be more than one nesting level under `master` most of the time, and _occasionally_ a second nesting level. I'm even fine with nesting level 3 and above not being rendered any more nested than the second level. (To avoid a "pyramid of doom" situation where the nesting turns from a benefit to a burden.)

## Ahead, behind, diverged

`master` is considered the root branch in the hierarchy. (Some configuration in `.git/config` allows the root to be something else; it defaults to `master`. If that branch does not exist, the tool fails with an error message explaining all this.)

In the first example, all the three `feature-*` branches were ahead of their ancestor. In the case of PRs merging and making other branches "old" (as in, not basing off of latest `master` anymore), branches can also be behind. Notice that a branch can be _both_ ahead and behind. I've come to increasingly see this as the beauty of Git.

Here's an example. If the commit structure actually looks like this:

```
...--o--o--o--o master
     |     |
     |     +--o--o feature-a1 (two commits ahead, one commit behind master)
     |           |
     |           +--o--o--o feature-a2 (three commits ahead of feature-a1)
     |
     +--o feature-b (one commit ahead, three commits behind master)
```

Then the output of the command would be this:

```
$ git btree
. master
  * feature-a1 [+2, -1]
  ... feature-a2 [+3]
  * feature-b [+1, -3]
```

Whereas the dot (`.`) means "everything's peachy here", the asterisk (`*`) means "commits in this branch (ahead), but also commits in the parent branch (behind)". But everything's otherwise fine.

Note that `feature-a2` does not "inherit" the behindness of `feature-a1`. That is, `feature-a1` is behind `master`, and while `feature-a2` is _also_ behind `master`, it is _not_ behind `feature-a1`. The behindness all belongs to `feature-a1` in this case.

A branch that's both ahead and behind is called _diverged_.  Diverging in your Git history is quite normal and sometimes even fine. But see "Conflicts" below for when it gets interesting.

A branch which is neither ahead nor behind is called _empty_.

## Done

Ok, so let's assume `feature-b` gets merged. A new merge commit will show up on `master`, and `feature-b` will be a parent of that commit, which means it's now strictly behind `master`. In terms of a commit diagram, we can visualize it like this:

```
...--o--o--o--o--o master
     |     |     |
     +--o--|-----+
        ^  |
        :  +--o--o feature-a1 (two commits ahead, two commits behind master)
        :        |
        :        +--o--o--o feature-a2 (three commits ahead of feature-a1)
        :
        feature-b (one commit behind master)
```

Branches which are behind but not ahead are defined as _done_, because the typical case by far is that these were recently merged into `master`. The tool will assume that this is the case, and show these branches separately at the bottom after a divider.

```
$ git btree
. master
  * feature-a1 [+2, -2]
  ... feature-a2 [+3]
---
~ feature-b [done]
```

The `~` symbol here signifies that you can now `git purge` the `feature-b` branch. (`git-purge` is another tool I have. It just removes locally all the branches that are strictly behind. Its entire implementation is `git branch --merged | egrep -v "(\*|master)" | xargs -r git branch -D`.) Of course, if you do `git pullge`, it will `git pull` and then automatically purge those branches.

## Conflicts

A _dry-run merge_ is a merge operation that doesn't put a commit on a branch; it just checks if the merge would succeed or have conflicts. A diverged (ahead/behind) branch is _conflicted_ if a dry-run merge into its parent branch leads to a conflict.

Having merged and purged `feature-b`, let's assume `feature-a1` actually got conflicted from that merge. The commit history now actually looks simpler:

```
...--o--o--o master
     |
     +--o--o feature-a1 (two commits ahead, two commits behind master)
           |
           +--o--o--o feature-a2 (three commits ahead of feature-a1)
```

From the commit history alone, we can't tell whether `feature-a1` is conflicted or not. That information resides inside of the commits, more precisely in the interplay between the two commits "on" `feature-a1` and the two commits "on" `master`. (The square quotes are a signal that this is `btree`'s view of what it means to be on a branch, not Git's.)

In this case, we assume it's conflicted. Then the output is this:

```
$ git btree
. master
  ! feature-a1 [+2, -2, conflict]
  ... feature-a2 [+3]
```

The `!` symbol means "this diverged branch is conflicted". Since merging is the "happy ending" of a branch, this conflict will need to be handled somehow with either a `git merge` or a `git rebase`. In either case, conflicts need to be resolved.

Note, again, that `feature-a2` is not marked as conflicted. That's because the conflict exists between `feature-a1` and `master`, and we can't really tell until that's been resolved whether `feature-a2` is in conflict with `feature-a1`.

I have this other tool called `git-cascade-rebase` that I haven't written yet. Similar to this `git-btree` tool, it would take branch hierarchies into consideration, and when you asked it to rebase a branch, it would first rebase that branch and then rebase all its descendant branches in [breadth-first](https://en.wikipedia.org/wiki/Breadth-first_search) order. The reason this is a tall order is that `git-rebase` is already a long-running command (what with `--continue` and `--abort` and all that), so `git-cascade-rebase` needs to be, too.

## Stale branches

Absent `git-recursive-rebase`, child branches are going to have the parent branch's _old_ commit as the ancestor. So, assuming we've rebased the `feature-a1` branch:

```
...--o--o--o----------------------o master
     |                            |
     +--o--o _old_ feature-a1     +--o--o feature-a1
           |
           +--o--o--o feature-a2 (three commits ahead of old feature-a1)
```

The commit marked `_old_ feature-a1` doesn't even have a ref anymore, but it's significant _because_ its a rebased-away version of the _current_ holder of the ref `feature-a1`. It's super-weird that no Git tools seem to acknowledge this type of relationship.

A child branch is defined as _stale_ when its parent branch has been rebased away from the child branch.

Note in passing that only branches on level 2 and deeper can be stale, because `master` cannot be rebased against anything. (_Update_: This is not quite correct; in a workflow that allows committing directly to master, _and_ a (rare) circumstance where you've (1) committed to `master` without pushing, (2) branched from `master` and committed to that branch, (3) rebased the local parts of master, your branch is now stale. Rare as it is, this is something we should absolutely support.)

In the case of the commit history above, the tool would output this:

```
$ git btree
. master
  . feature-a1 [+2, -2]
  ..? feature-a2 [+3, stale]
```

Here, the symbol `?` indicates that this branch has become stale and in a sense is forgotten and needs to be cared about. The solution in this case is to rebase this branch. The rebase command in this case would be `git rebase --onto feature-a1 old-feature-a1 feature-a2`, which means we also have to locate `old-feature-a1`, which (again) doesn't have a ref. (This is exactly why that `git-recursive-rebase` tool should exist. It just now strikes me that it should also work _retroactively_; that is, it should handle `feature-a2` in this case even when `feature-a1` was rebased normally.)

In rare cases, a branch may be conflicted (`!`) and stale (`?`) at the same time. It then gets the symbol `‽`.

How do we recognize a commit as being the lesser/rebased-away version of another commit? I'm still not 100% sure about this, but it seems to me that the one common denominator is the `author` information (name+email+datetime). If that's exactly the same between two commits, then those commits are either rebased or cherry-picked or something similar. That is, by assuming that commits with exactly the same `author` information are actually "the same" commit, this tool can deduce a lot more things. Notably, it can detect staleness.

It's icing on the cake, but it'd be nice at some point if the tool could mark up conflicts even past a staleness barrier. That is, in this sitauation:

```
. master
  . feature-a1 [+2, -2]
  ..? feature-a2 [+3, stale]
  ..... feature-a3 [+2]
```

`feature-a3` might actually be conflicted against the _rebased_ result of `feature-a2`; we strictly don't know yet, because we haven't done that rebase yet. But what we can do instead of just dry-run-merging `feature-a3` against `feature-a2` and then stopping, is going up the chain; in this case dry-run-merging `feature-a3` against first `feature-a2`, then `feature-a1`, then `master`. Dry-run-merging is presumably cheap, since it happens behind the scenes and has no visible side effects.

Again, this is conjectural, but maybe in such a case the output should note as much:

```
. master
  . feature-a1 [+2, -2]
  ..? feature-a2 [+3, stale]
  ....! feature-a3 [+2, conflict against master]
```

## Remote branches

In Git, a "remote branch" is paradoxically not a branch over at the remote repo, but a local ref that _mirrors_ a branch over at the remote repo. As such, it can easily get out-of-date.

However, it's more important for this tool to be fast (and incur no delays from network traffic by default) than to be up-to-date with a remote. At most, the tool could carry a `--fetch` flag that'd fetch from all remotes before showing the information. (Or, more impressively, show the information first, then fetch, then update the information using ncurses.)

Here's a quick example of remote-branch information that could be shown.

```
. master {push}
  . feature-a1 [+2, -2] {force-push}
  ..? feature-a2 [+3, stale]
  ..... feature-a3 [+2]
```

A `{push}` corresponds to the remote branch being strictly behind the local branch. A `{force-push}` corresponds to the remote branch being diverged with the local branch.

Note how, in this example, `feature-a2` and `feature-a3` will probably need to be force-pushed eventually, but that information is suppressed right now, since they are stale currently and need to be recursive-rebased first.

Conceivably there should be a tool for pushing all the branches in the listing that can be non-force pushed. I'd like it to be something reasonable that doesn't mess up the tab completion of `git push`. Maybe `git pa` (as in "push all"). That command could also take a `--force` flag to push the `{force-push}` branches, too.

Guess we could sometimes show `{force-push, conflict}`, but that's not so informative, because that conflict has already been resolved locally, and will anyway be force-pushed away, so... better just display it as `{force-push}`.

## Colors

The `git-bb` tool has pioneered the use of colors a bit. The branch names should be colored as follows:

* Strictly ahead branches: bright green
* Strictly behind branches: bright black (dark grey)
* Mixed ahead/behind branches: bright cyan
* Empty (neither ahead nor behind): bright white

As for the one-character symbols (`. * ~ ? ! ‽`), the ones that don't require any direct action (`. * ~`) are colored the usual grey, whereas the ones that do (`? ! ‽`) are colored bright red.

The `{push}` and `{force-push}` should probably also be colored, maybe... bright yellow?
