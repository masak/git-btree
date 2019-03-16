use Test;
use Git::BTree::Infer;

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

my $tree = infer-tree(%branches);

{
    my $branch = $tree;
    is $branch.name, "master", "the root branch is 'master'";
}

{
    my $branch = $tree[0];
    is $branch.name, "feature-a1", "the name of the first child of 'master' is 'feature-a1'";
    is $branch.ahead, 2, "...and it's 2 commits ahead";
    is $branch.behind, 0, "...and it's 0 commits behind";
}

{
    my $branch = $tree[0][0];
    is $branch.name, "feature-a2", "the name of the child of 'feature-a1' is 'feature-a2'";
    is $branch.ahead, 3, "...and it's 3 commits ahead";
    is $branch.behind, 0, "...and it's 0 commits behind";
}

{
    my $branch = $tree[1];
    is $branch.name, "feature-b", "the name of the second child of 'master' is 'feature-b'";
    is $branch.ahead, 1, "...and it's 1 commit ahead";
    is $branch.behind, 0, "...and it's 0 commits behind";
}

done-testing;
