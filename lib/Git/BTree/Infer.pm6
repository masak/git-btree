use Git::Branch;

sub never-conflict($, $) {
    return False;
}

sub infer-tree(Str $current-branch, %branches, &branches-conflict:($, $) = &never-conflict) is export {
    # if we traverse the branches by increasing commit log length, we can be sure to always
    # know about a branch's parent when visiting the branch
    my @sorted-branches = %branches.sort({ +lines(.value) });

    # this value will be overridable by config in the fullness of time
    my $root-name = "master";
    my %branch-of-auth;
    my %known-to-branch;

    sub traverse($branch, @commits) {
        my $next-sha = "";
        my $index = 0;
        my $ahead = -1;

        for @commits -> $commit {
            $commit ~~ /
                ^
                (<[ 0..9 a..f ]> ** 40)
                " ("
                ([<[ 0..9 a..f ]> ** 40] *% " ")
                ") "
                (.+)
                $
            / or die "Unexpected line format `$commit`";

            my $sha = ~$0;
            my $parents = ~$1;
            my $auth = ~$2;

            if $next-sha ne "" && $next-sha ne $sha {
                %known-to-branch{$auth} = $branch;
                next;
            }

            $next-sha = $parents
                ?? $parents.words[0]
                !! "";

            if %known-to-branch{$auth} {
                $ahead = $index;
            }

            if %branch-of-auth{$auth} -> [$behind, $parent-branch] {
                $branch.ahead = $ahead > -1
                    ?? $ahead
                    !! $index;
                $branch.behind = $behind;
                $parent-branch.add-child($branch);
                if branches-conflict($branch.name, $parent-branch.name) {
                    $branch.mark-conflicted-against($parent-branch);
                }
                last;
            }
            else {
                %branch-of-auth{$auth} = [$index, $branch];
            }

            $index++;
        }
    }

    die "No master branch -- TODO"
        unless my $log-of-root = %branches{$root-name};
    die "No commits for the root branch -- TODO"
        unless my @lines-of-root = lines($log-of-root);
    my $root-branch = Git::Branch::Root.new(
        :name($root-name),
        :is-current-branch($current-branch eq $root-name),
    );
    traverse($root-branch, @lines-of-root);

    for @sorted-branches -> Pair ( :key($branch), :value($log) ) {
        next if $branch eq $root-name;

        my @lines = lines($log);
        die "No log, not even for the commit under the branch -- possible if the branch is orphaned and new? -- TODO"
            unless @lines;

        my $this-branch = Git::Branch::Child.new(
            :name($branch),
            :is-current-branch($current-branch eq $branch),
        );

        traverse($this-branch, @lines);
    }

    return $root-branch;
}
