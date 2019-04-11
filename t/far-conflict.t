use Test;
use Test::Branches::FarConflict;
use Git::BTree::Infer;
use Git::Branch;

sub report-conflict($branch1, $branch2) {
    return (%conflicts{$branch1} // "") eq $branch2
            || (%conflicts{$branch2} // "") eq $branch1;
}

my $root = infer-tree("", %branches, &report-conflict);

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
    is $branch.conflict, False, "...and it's not conflicted";
    is $branch.conflict-against, Nil, "...and so asking conflicted against what doesn't make sense";
}

{
    my $branch = $root[0][0];
    isa-ok $branch, Git::Branch::Child;
    is $branch.name, "feature-a2", "the name of the child of 'feature-a1' is 'feature-a2'";
    is $branch.ahead, 3, "...and it's 3 commits ahead";
    is $branch.behind, 0, "...and it's 0 commits behind";
    is $branch.conflict, True, "...and it's conflicted, even though its parent isn't";
    is $branch.conflict-against, "master", "...against 'master'";
}

{
    is $root.monochrome-output(), q:to/EOF/, "correct monochrome output";
        . master
          * feature-a1 [+2, -1]
          ..! feature-a2 [+3, conflict against master]
        EOF
}

{
    is $root.color-output(), q:to/EOF/, "correct color output";
        . master
          <red>*</red> <green>feature-a1</green> [+2, -1]
          ..<red>!</red> <green>feature-a2</green> [+3, <red>conflict</red> against master]
        EOF
}

done-testing;
