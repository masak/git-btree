use Git::Branch;

sub infer-tree(%branches) is export {
    # if we traverse the branches by increasing commit log length, we can be sure to always
    # know about a branch's parent when visiting the branch
    my @sorted-branches = %branches.sort({ +lines(.value) });

    # this value will be overridable by confic in the fullness of time
    my $root-branch = "master";

    die "No master branch -- TODO"
        unless my $log-of-root = %branches{$root-branch};
    die "No commits for the root branch -- TODO"
        unless my @lines-of-root = lines($log-of-root);
    my $root-head-auth = @lines-of-root[0];
    my %branch-of-auth =
        $root-head-auth => Git::Branch::Root.new(:name($root-branch)),
    ;

    for @sorted-branches -> Pair ( :key($name), :value($log) ) {
        my @lines = lines($log);

        next if $name eq $root-branch;

        die "No log, not even for the commit under the branch -- possible if the branch is orphaned and new? -- TODO"
            unless @lines;
        my $head-auth = @lines[0];

        my $this-branch;
        for @lines.kv -> $index, $auth {
            next if $auth eq $head-auth;

            if %branch-of-auth{$auth} -> $parent-branch {
                $this-branch = Git::Branch::Child.new(
                    :$name,
                    :ahead($index),
                    :behind(0),
                );
                %branch-of-auth{$head-auth} = $this-branch;

                $parent-branch.add-child($this-branch);
                last;
            }
        }

        if !$this-branch {
            die "Guess this case happens for orphaned branches -- TODO";
        }
    }

    return %branch-of-auth{$root-head-auth};
}
