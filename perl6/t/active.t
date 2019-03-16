use Test;
use Test::Branches::AllAhead;
use Git::BTree::Infer;
use Git::Branch;

{
    my $root = infer-tree("master", %branches);

    is $root.color-output(), q:to/EOF/, "correct color output";
        . <inverted-white>master</inverted-white>
          . <green>feature-a1</green> [+2]
          ... <green>feature-a2</green> [+3]
          . <green>feature-b</green> [+1]
        EOF
}

{
    my $root = infer-tree("feature-a2", %branches);

    is $root.color-output(), q:to/EOF/, "correct color output";
        . master
          . <green>feature-a1</green> [+2]
          ... <inverted-green>feature-a2</inverted-green> [+3]
          . <green>feature-b</green> [+1]
        EOF
}

{
    my $root = infer-tree("", %branches);

    is $root.color-output(), q:to/EOF/, "correct color output";
        . master
          . <green>feature-a1</green> [+2]
          ... <green>feature-a2</green> [+3]
          . <green>feature-b</green> [+1]
        EOF
}

done-testing;
