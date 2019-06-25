use Test;
use Test::Branches::AheadBehind;
use Git::BTree::Infer;
use Git::Branch;

my $listing = infer-tree("", %branches);
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
}

{
    my $branch = $root[0][0];
    isa-ok $branch, Git::Branch::Child;
    is $branch.name, "feature-a2", "the name of the child of 'feature-a1' is 'feature-a2'";
    is $branch.ahead, 3, "...and it's 3 commits ahead";
    is $branch.behind, 0, "...and it's 0 commits behind";
}

{
    my $branch = $root[1];
    isa-ok $branch, Git::Branch::Child;
    is $branch.name, "feature-b", "the name of the second child of 'master' is 'feature-b'";
    is $branch.ahead, 1, "...and it's 1 commit ahead";
    is $branch.behind, 3, "...and it's 0 commits behind";
}

{
    is $listing.monochrome-output(), q:to/EOF/, "correct monochrome output";
        . master
          * feature-a1 [+2, -1]
          ... feature-a2 [+3]
          * feature-b [+1, -3]
        EOF
}

{
    is $listing.color-output(), q:to/EOF/, "correct color output";
        . master
          <red>*</red> <green>feature-a1</green> [+2, -1]
          ... <green>feature-a2</green> [+3]
          <red>*</red> <green>feature-b</green> [+1, -3]
        EOF
}

done-testing;
