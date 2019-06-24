The basic idea of `git-btree` is that the human intuition of a commit "being on a branch" is not reflected by Git
out-of-the-box.

* **Git's model of branches**: A branch is a ref that moves forwards with new commits. Commits are not technically "on"
  a branch; instead, commits can _reachable_ from a certain branch. The set of branches is "flat" in the sense that they
  are just names in a list somewhere; however, branches are sometimes reachable from each other in the sense that one
  branch ref is upstream of another. This is not reflected so clearly in tool output, however; _especially_ not when
  branches go stale with respect to one another. (See below.)

* **Human intuition of branches**: If I make a commit while on a branch, that commit is _on_ that branch. If I start
  a new branch `feature-a2` while already on an old branch `feature-a1`, the commits I make to `feature-a2` will be _on_
  `feature-a2` but not on `feature-a1`. Vice versa, the old commits I made while working on `feature-a1` are _on_
  `feature-a1` but not on `feature-a2`. I think of `feature-a2` as being a "child branch" of `feature-a1`, because the
  start of the former is based on the latest commit of the latter. If interesting things happen to `feature-a1` (more
  commits, say, or it gets rebased), I still consider `feature-a2` to be a child branch, but it's now "behind", or
  "stale".

The tool gives output such as this:

```
$ git btree
. master
  . feature-a1 [+2]
  ... feature-a2 [+3]
  . feature-b [+1]
```

The branches are ordered hierarchically according to their commit-ancestor relationships. We'll define _parent branch_
and _child branch_ as meaning the obvious things. (But also see later about stale branches.) In this case, the commit
history would look like this:

```
...--o master
     |
     +--o--o feature-a1 (two commits ahead of master)
     |     |
     |     +--o--o--o feature-a2 (three commits ahead of feature-a1, five ahead of master)
     |
     +--o feature-b (one commit ahead of master)
```

Why do we care about hierarchical branches? Generally these should be avoided, but they do happen sometimes, for example
when building two pull requests, whose work naturally divides into two consecutive parts. The `git wip` mechanism (a
replacement for `git stash`, see below) also builds on hierarchical branches.

I don't expect there to be more than one nesting level under `master` most of the time, and _occasionally_ a second
nesting level. The point of the `git-btree` tool is to present the branches as a list when they are a list, and to give
good support for the hierarchical-branches case when it occurs.

A nesting level of 3 and above does not need to be rendered any more nested than the second level. (To avoid a "pyramid
of doom" situation where the nesting turns from a benefit to a burden by consuming arbitrary levels of indentation.)

## Ahead, behind, diverged, empty

`master` is considered the root branch in the hierarchy. (Some configuration in `.git/config` allows the root to be
something else; it defaults to `master`.) As we will see, "root branch" does not always mean "oldest commit" or
"most ancestral commit"; it just means that it's the top of the branch hierarchy by definition.

In the first example, all the three `feature-*` branches were ahead of their ancestor. In the case of PRs merging and
making other branches "old" (as in, not basing off of latest `master` anymore), branches can also be behind. Notice that
a branch can be _both_ ahead and behind. I've come to increasingly see this as the beauty of Git.

Here's an example. If the commit structure looks like this:

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

Whereas the dot (`.`) means "everything's peachy here", the asterisk (`*`) means "commits in this branch (ahead), but
also commits in the parent branch (behind)". But everything's otherwise fine.

Note that `feature-a2` does not "inherit" the behindness of `feature-a1`. That is, `feature-a1` is behind `master`, and
while `feature-a2` is _also_ behind `master`, it is _not_ behind `feature-a1`. The behindness all belongs to
`feature-a1` in this case. In general in `git-btree`, branches do not inherit properties.

A branch that's both ahead and behind is called _diverged_.  Diverging in your Git history is quite normal and sometimes
even fine. But see "Conflicts" below for when it gets interesting.

A branch which is neither ahead nor behind is called _empty_. Work on this branch likely hasn't started yet.

Here's a table summarizing the different states a child branch can be in:

|                      | no parent commits | parent commits |
| -------------------- | ----------------- | -------------- |
| **no child commits** | empty             | behind (done)  |
| **child commits**    | ahead             | diverged       |

## Done

Let's now assume `feature-b` gets merged. A new merge commit will show up on `master`, and `feature-b` will be a parent
of that commit, which means it's now strictly behind `master`. In terms of a commit diagram, we can visualize it
like this:

```
...--o--o--o--o--o master
     |     |     |
     +--o--------+
        ^  |
        :  +--o--o feature-a1 (two commits ahead, three commits behind master)
        :        |
        :        +--o--o--o feature-a2 (three commits ahead of feature-a1)
        :
        feature-b (four commits behind master; the original three + the new merge)
```

Branches which are behind but not ahead are defined as _done_, because the typical case by far is that these were
recently merged into `master`. The tool will assume that this is the case, and show these branches separately at the
bottom after a divider.

```
$ git btree
. master
  * feature-a1 [+2, -3]
  ... feature-a2 [+3]
---
~ feature-b [done]
```

The `~` symbol here signifies that you can now `git purge` the `feature-b` branch. (`git-purge` is another tool I have.
It just removes locally all the branches that are strictly behind. Its entire implementation is
`git branch --merged | egrep -v "(\*|master)" | xargs -r git branch -D | sed -e's/^Deleted/Purged/'`.)
Since purging often happens if you pull in a fresh `master` with merged PRs, if you do `git pullge`, it will `git pull`
and then automatically purge those branches.

## Conflicts

A _dry-run merge_ is a merge operation that doesn't update Git history; it non-destructively checks if the merge would
succeed or lead to a conflict. Any diverged (ahead/behind) branch can be _conflicted_, if a dry-run merge into its
parent branch conflicts.

Having merged and purged `feature-b`, let's assume `feature-a1` became conflicted from that merge. The commit history
now looks a bit smaller without `feature-b`:

```
...--o--o--o master
     |
     +--o--o feature-a1 (two commits ahead, three commits behind master)
           |
           +--o--o--o feature-a2 (three commits ahead of feature-a1)
```

From the commit history alone, we can't tell whether `feature-a1` is conflicted or not. That information resides inside
of the commits, more precisely in the composed result of the two commits on `feature-a1` and the three commits on
`master`.

In this case, we assume it's conflicted. Then the output is this:

```
$ git btree
. master
  ! feature-a1 [+2, -3, conflict]
  ... feature-a2 [+3]
```

The `!` symbol means "this diverged branch is conflicted". Since merging is the successful outcome of a branch/pull
request workflow, such a conflict will need to be handled somehow with either a `git merge` or a `git rebase`, either
action containing manual conflict resolution steps.

The `feature-a2` branch is not marked as conflicted. The known conflict exists between `feature-a1` and `master`;
resolving that conflict in `feature-a1` will surely affect the exact relationship between `feature-a1` and `feature-a2`
&mdash; if we were merging out from `master` to `feature-a1`, `feature-a2` will now be more behind; if we were rebasing
`feature-a1`, `feature-a2` will now be stale; see below &mdash; in either case, `feature-a2` might now be conflicted due
to the conflict resolutions in `feature-a1`.

There's another tool called `git-cascade-rebase` that I haven't written yet. Similar to this `git-btree` tool, it
would take branch hierarchies into consideration, and when you asked it to rebase a branch, it would first rebase that
branch and then rebase all its descendant branches in
[breadth-first](https://en.wikipedia.org/wiki/Breadth-first_search) order. The reason this is not a trivial command to
write is that `git-rebase` is already a long-running command (what with `--continue` and `--abort` and all that), so
`git-cascade-rebase` needs to be, too. Conceptually, it should carry out a number of rebases sequentially, but in a
transactional way, so that for example `git cascade-rebase --abort` would reset all of the already rebased branches.

## Stale

Absent `git-cascade-rebase`, descendant branches of a rebased branch are going to have the parent branch's _old_ commit
as the ancestor. So, assuming we've rebased the `feature-a1` branch:

```
...--o--o--o--o-------------------o master
     |                            |
     +--o--o _old_ feature-a1     +--o--o feature-a1
           |
           +--o--o--o feature-a2 (three commits ahead of old feature-a1)
```

The commit marked `_old_ feature-a1` doesn't even have a ref anymore, but it's significant _because_ its a rebased-away
version of the _current_ holder of the ref `feature-a1`. It's weird that no Git tools seem to acknowledge this type of
relationship. Usually the user needs to cross-correlate things in the commit history and in the `git reflog`.

A child branch is defined as _stale_ when its parent branch has been rebased away from the child branch, like
`feature-a1` has from `feature-a2` above.

Usually it's a level-2 branch or deeper that gets stale. But this could also theoretically happen to a level-1 branch,
if some work on a local `master` gets rebased away from a branch that had work in it from before the rebase.

In the case of the commit history above, the tool would output this:

```
$ git btree
. master
  . feature-a1 [+2, -3]
  ..? feature-a2 [+3, stale]
```

Here, the symbol `?` indicates that this branch has become stale and in a sense is forgotten and needs to be cared
about. The solution in this case is to rebase this branch. The somewhat intricate rebase command in this case would be
`git rebase --onto feature-a1 old-feature-a1 feature-a2`, which means we also have to locate `old-feature-a1` which
typically doesn't have a ref at this point. (This is exactly why that `git-cascade-rebase` tool should exist, to
pre-empt this situation by rebasing descendant branches immediately. It just now strikes me that `git-cascade-rebase`
should also work _retroactively_; that is, it should handle `feature-a2` in this case even after `feature-a1` was
rebased normally. It should figure out the staleness of `feature-a2` in the same way `git-btree` does.)

In rare cases, a branch may be conflicted (`!`) and stale (`?`) at the same time. It then gets the symbol `‽`.

How do we recognize a commit as being the lesser/rebased-away version of another commit? The one thing a "fresh" commit
and its corresponding "stale" commit will have in common is `author` information (name+email+datetime). If that's
exactly the same between two commits, then those commits are either rebased or cherry-picked or something similar.
Borrowing some terminology from Gerrit, we refer to a set of commits all with the same `author` information as a
_change_. A branch is stale if, when we compare it to its parent branch, the parent branch contains the same changes
but from fresher commits.

It's icing on the cake, but it'd be nice at some point if the tool could mark up conflicts even past a staleness
barrier. That is, in this sitauation:

```
. master
  . feature-a1 [+2, -3]
  ..? feature-a2 [+3, stale]
  ..... feature-a3 [+2]
```

`feature-a3` might actually be conflicted against the _rebased_ result of `feature-a2`; we strictly don't know yet,
because we haven't done that rebase yet. But what we can do instead of just dry-run-merging `feature-a3` against
`feature-a2` and then stopping, is going up the chain; in this case dry-run-merging `feature-a3` against first
`feature-a2`, then `feature-a1`, then `master`. Dry-run-merging is presumably cheap, since it happens behind the scenes
and has no visible side effects.

Again, this is conjectural, but maybe in such a case the output should note as much:

```
. master
  . feature-a1 [+2, -3]
  ..? feature-a2 [+3, stale]
  ....! feature-a3 [+2, conflict against master]
```

## Remote

In Git, a "remote branch" is (confusingly) not a branch over at the remote repo, but a local (non-branch) ref that
_mirrors_ a branch over at the remote repo. As such, it can get out-of-date, just like any other such information in a
distributed system. (Git might tell you that you are up-to-date with `origin/master`, for example, and it will be right.
But `origin/master` is not the actual `master` branch at the remote `origin`; it's just a cache, and it might be old.)

However, it's more important for this tool to be fast (and incur no delays/unstability from network traffic by default)
than to be up-to-date with a remote. At most, the tool could carry a `--fetch` flag that'd fetch from all remotes before
showing the information. (Or, more impressively, show the information first, then fetch, then update the information
using ncurses.)

Here's a quick example of remote-branch information that could be shown.

```
. master {push}
  . feature-a1 [+2, -3] {force-push}
  ..? feature-a2 [+3, stale]
  ..... feature-a3 [+2]
```

A `{push}` corresponds to the remote branch being strictly behind the local branch. A `{force-push}` corresponds to the
remote branch being diverged with the local branch.

Note how, in this example, `feature-a2` and `feature-a3` will probably need to be force-pushed eventually, but that
information is suppressed right now, since they are stale currently and need to be cascade-rebased first.

Conceivably there should be a tool for pushing all the branches in the listing that can be pushed without force. I'd
like it to be something reasonable that doesn't mess up the tab completion of `git push`. Maybe `git pa` (as in "push
all"). That command could also take a `--force` flag to push the `{force-push}` branches, too.

Guess we could sometimes show `{force-push, conflict}`, but that's not so informative, because that conflict has already
been resolved locally, and will anyway be force-pushed away, so... better just display it as `{force-push}`.

Since many branches can be ongoing/pushed at the same time, there might be conflicts hiding _between_ those branches,
that won't show up before one of them has been pushed. It would be very nice to be able to dry-run-merge _all the pushed
branches against each other_, and get information about possible future conflicts. Questions arise both about how slow
this will be in practice, and how best to visualize a conflict between two disparate branches in the tree. (Possibly a
system of "footnotes", marking the pair of branches that are conflicting, and showing a longer message below the
divider, could work quite well.) It's just a hunch, but we might choose to only show this information about branches
that have a remote branch &mdash; the rationale being that before that, they are not "ready" enough, and showing the
information about conflicts is not so important.

## Branching

Branches are not "primary" in Git; the commit graph is. Branches just float on top of the commit graph, like very
movable browser bookmarks to commits.

I just had a real-world situation where I was working on some branch `feature-f`, and had made three commits on it
already:

```
. master
  . feature-f [+3]
```

Then I discovered a bug, and I made a commit of what I found on a separate branch `bug`:

```
. master
  . feature-f [+3]
  ... bug [+1]
```

But then I went back and continued working on the `feature-f` branch, making 5 more commits on it:

```
. master
  . (cedfa99) [+3]
  ... bug [+1]
  ... feature-f [+5]
```

The point is that the common commit that one or more branches share as a parent doesn't necessarily have a branch ref
associated with it. This is somewhat rare, but from Git's perspective it's the general case, since _branches do not
matter_.

The above case happened because two branches diverged from a common ancestor that didn't have a branch ref attached.
We call a commit "anonymous" if `git-btree` needs to use it as an ancestor but it doesn't have a branch ref. It can
happen for a number of reasons &mdash; for example, maybe someone rebased *parts* of a parent branch.

In summary, Git doesn't really care about branches. Branches are not primary &mdash; the commit graph is. Usually we'll
have a branch label to show for a particular ancestor commit; when we don't, `git-btree` falls back to using commit
SHA-1s, analogously to how many Git commands show the "current branch" when working with a detached `HEAD`.

## Colors

The `git-bb` tool has pioneered the use of colors a bit. The branch names should be colored as follows:

* Strictly ahead branches: bright green
* Strictly behind branches: bright black (dark grey)
* Mixed ahead/behind branches: bright cyan
* Empty (neither ahead nor behind): bright white

As for the one-character symbols (`. * ~ ? ! ‽`), the ones that don't require any direct action (`. * ~`) are colored
the usual grey, whereas the ones that do (`? ! ‽`) are colored bright red.

The `{push}` and `{force-push}` should probably also be colored, maybe... bright yellow?

It's a small thing, but `git-btree` (just like `git-bb`) also shows the currently checked-out branch by inverting its
colors. (I think this should be made to work even when we're in detached `HEAD` mode.)