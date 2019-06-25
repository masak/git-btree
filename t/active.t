use Test;
use Test::Branches::AllAhead;
use Git::BTree::Infer;
use Git::Branch;

{
    my $listing = infer-tree("master", %branches);

    is $listing.color-output(), q:to/EOF/, "correct color output (master branch)";
        . <inverted-white>master</inverted-white>
          . <green>feature-a1</green> [+2]
          ... <green>feature-a2</green> [+3]
          . <green>feature-b</green> [+1]
        EOF
}

{
    my $listing = infer-tree("feature-a2", %branches);

    is $listing.color-output(), q:to/EOF/, "correct color output (feature-a2 branch)";
        . master
          . <green>feature-a1</green> [+2]
          ... <inverted-green>feature-a2</inverted-green> [+3]
          . <green>feature-b</green> [+1]
        EOF
}

{
    my $listing = infer-tree("", %branches);

    is $listing.color-output(), q:to/EOF/, "correct color output (no branch)";
        . master
          . <green>feature-a1</green> [+2]
          ... <green>feature-a2</green> [+3]
          . <green>feature-b</green> [+1]
        EOF
}

done-testing;
