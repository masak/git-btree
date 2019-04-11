use Git::Branch;

sub infer-tree(Str $current-branch, %branches) is export {
    # if we traverse the branches by increasing commit log length, we can be sure to always
    # know about a branch's parent when visiting the branch
    my @sorted-branches = %branches.sort({ +lines(.value) });

    # this value will be overridable by config in the fullness of time
    my $root-name = "master";
    my %branch-of-auth;

    die "No master branch -- TODO"
        unless my $log-of-root = %branches{$root-name};
    die "No commits for the root branch -- TODO"
        unless my @lines-of-root = lines($log-of-root);
    my $root-branch = Git::Branch::Root.new(
        :name($root-name),
        :is-current-branch($current-branch eq $root-name),
    );
    for @lines-of-root.kv -> $behind, $line {
        $line ~~ /
            ^
            <[ 0..9 a..f ]> ** 40
            " ("
            [<[ 0..9 a..f ]> ** 40] *% " "
            ") "
            (.+)
            $
        / or die "Unexpected line format `$line`";
        my $auth = ~$0;
        %branch-of-auth{$auth} = [$behind, $root-branch];
    }

    for @sorted-branches -> Pair ( :key($branch), :value($log) ) {
        next if $branch eq $root-name;

        my @lines = lines($log);
        die "No log, not even for the commit under the branch -- possible if the branch is orphaned and new? -- TODO"
            unless @lines;

        my $this-branch = Git::Branch::Child.new(
            :name($branch),
            :is-current-branch($current-branch eq $branch),
        );

        for @lines.kv -> $index, $line {
            $line ~~ /
                ^
                <[ 0..9 a..f ]> ** 40
                " ("
                [<[ 0..9 a..f ]> ** 40] *% " "
                ") "
                (.+)
                $
            / or die "Unexpected line format `$line`";
            my $auth = ~$0;
            if %branch-of-auth{$auth} -> [$behind, $parent-branch] {
                $this-branch.ahead = $index;
                $this-branch.behind = $behind;
                $parent-branch.add-child($this-branch);
                last;
            }
            else {
                %branch-of-auth{$auth} = [$index, $this-branch];
            }
        }
    }

    return $root-branch;
}
