use Test;
use Test::Branches::Conflict;
use Git::BTree::Infer;
use Git::Branch;

sub report-conflict($branch1, $branch2) {
    return (%conflicts{$branch1} // "") eq $branch2
            || (%conflicts{$branch2} // "") eq $branch1;
}

my $listing = infer-tree("", %branches, &report-conflict);
my $root = $listing.active[0];

{
    my $branch = $root;
    isa-ok $branch, Git::Branch::Root;
    is $branch.name, "master", "the root branch is 'master'";
}

{
    my $branch = $root[0];
    isa-ok $branch, Git::Branch::Child;
    is $branch.name, "feature-a1", "the name of the first child of 'master' is 'feature-a1'";
    is $branch.ahead, 2, "...and it's 2 commits ahead";
    is $branch.behind, 1, "...and it's 0 commits behind";
    is $branch.conflict, True, "...and it's conflicted";
    is $branch.conflict-against, "master", "...against 'master'";
}

{
    my $branch = $root[0][0];
    isa-ok $branch, Git::Branch::Child;
    is $branch.name, "feature-a2", "the name of the child of 'feature-a1' is 'feature-a2'";
    is $branch.ahead, 3, "...and it's 3 commits ahead";
    is $branch.behind, 0, "...and it's 0 commits behind";
    is $branch.conflict, False, "...and it's not conflicted, even though its parent is";
    is $branch.conflict-against, Nil, "...and so asking conflicted against what doesn't make sense";
}

{
    is $listing.monochrome-output(), q:to/EOF/, "correct monochrome output";
        . master
          ! feature-a1 [+2, -1, conflict]
          ... feature-a2 [+3]
        EOF
}

{
    is $listing.color-output(), q:to/EOF/, "correct color output";
        . master
          <red>!</red> <green>feature-a1</green> [+2, -1, <red>conflict</red>]
          ... <green>feature-a2</green> [+3]
        EOF
}

done-testing;
