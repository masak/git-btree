use Test;
use Git::BTree::Infer;
use Git::Branch;

my %branches =
    "master" => q:to/./,
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:23 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:22 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:18 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:15 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:12 +0100
        .
    "feature-a1" => q:to/./,
        Carl Masak cmasak@gmail.com 2019-03-15 23:30:12 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:30:11 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:23 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:22 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:18 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:15 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:12 +0100
        .
    "feature-a2" => q:to/./,
        Carl Masak cmasak@gmail.com 2019-03-15 23:30:33 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:30:32 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:30:31 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:30:12 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:30:11 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:23 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:22 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:18 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:15 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:12 +0100
        .
    "feature-b" => q:to/./,
        Carl Masak cmasak@gmail.com 2019-03-15 23:32:03 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:23 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:22 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:18 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:15 +0100
        Carl Masak cmasak@gmail.com 2019-03-15 23:29:12 +0100
        .
;

my $root = infer-tree(%branches);

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
    is $branch.behind, 0, "...and it's 0 commits behind";
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
    is $branch.behind, 0, "...and it's 0 commits behind";
}

{
    is $root.monochrome-output(), q:to/EOF/, "correct monochrome output";
        . master
          . feature-a1 [2+]
          ... feature-a2 [3+]
          . feature-b [1+]
        EOF
}

{
    is $root.color-output(), q:to/EOF/, "correct color output";
        . master
          . <green>feature-a1</green> [2+]
          ... <green>feature-a2</green> [3+]
          . <green>feature-b</green> [1+]
        EOF
}

done-testing;
