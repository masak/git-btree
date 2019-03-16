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

{
    my $root = infer-tree("master", %branches);

    is $root.color-output(), q:to/EOF/, "correct color output";
        . <inverted-white>master</inverted-white>
          . <green>feature-a1</green> [2+]
          ... <green>feature-a2</green> [3+]
          . <green>feature-b</green> [1+]
        EOF
}

{
    my $root = infer-tree("feature-a2", %branches);

    is $root.color-output(), q:to/EOF/, "correct color output";
        . master
          . <green>feature-a1</green> [2+]
          ... <inverted-green>feature-a2</inverted-green> [3+]
          . <green>feature-b</green> [1+]
        EOF
}

{
    my $root = infer-tree("", %branches);

    is $root.color-output(), q:to/EOF/, "correct color output";
        . master
          . <green>feature-a1</green> [2+]
          ... <green>feature-a2</green> [3+]
          . <green>feature-b</green> [1+]
        EOF
}

done-testing;
