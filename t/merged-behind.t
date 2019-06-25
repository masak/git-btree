use Test;
use Test::Branches::MergedBehind;
use Git::BTree::Infer;
use Git::Branch;

my $listing = infer-tree("", %branches);

{
    my $branch = $listing.active[0];
    isa-ok $branch, Git::Branch::Root;
    is $branch.name, "master", "the root branch is 'master'";
}

{
    my $branch = $listing.done[0];
    isa-ok $branch, Git::Branch::Child;
    is $branch.name, "feature-b", "the name of the first child of 'master' is 'feature-b'";
    is $branch.ahead, 0, "...and it's 0 commits ahead";
    is $branch.behind, 4, "...and it's 4 commits behind";
}

{
    is $listing.monochrome-output(), q:to/EOF/, "correct monochrome output";
        . master
        ---
        ~ feature-b [done]
        EOF
}

{
    is $listing.color-output(), q:to/EOF/, "correct color output";
        . master
        ---
        <gray>~</gray> <gray>feature-b</gray> [done]
        EOF
}

done-testing;
