class Git::Branch::Child { ... }

role Git::Branch {
    has $.name is required;
    has Bool $.is-current-branch;
    has Git::Branch::Child @.children;
    has Str $!conflict-against = "";

    method add-child(Git::Branch::Child $child-branch) {
        @.children.push($child-branch);
        @.children.=sort(*.name);
        $child-branch.parent = self;
    }

    method AT-POS($pos) {
        @.children[$pos];
    }

    method color-output() {
        my $branch-description = "{self.action-symbol()} {self.color-name()}{self.info()}\n";

        my @active-branches = @.children.grep(!*.done);
        my $active-branches = @active-branches».color-output()\
            .join()\
            .indent(2)\
            .subst(/^^ "  "/, self.child-indent(), :g);

        my @done-branches = @.children.grep(*.done);
        my $done-branches = @done-branches
            ?? "---\n" ~ @done-branches».color-output()\
                .join()
            !! "";

        return $branch-description ~ $active-branches ~ $done-branches;
    }

    method monochrome-output() {
        self.color-output()
            .subst(/"<" "/"? [\w+] +% "-" ">"/, "", :g);
    }

    method conflict() {
        return $!conflict-against ne "";
    }

    method conflict-against() {
        return $!conflict-against || Nil;
    }

    method mark-conflicted-against(Git::Branch $branch) {
        $!conflict-against = $branch.name;
    }

    method action-symbol() { ... }

    method color-name() { ... }

    method info() { ... }

    method child-indent() { ... }

    method done { ... }
}

class Git::Branch::Root does Git::Branch {
    method action-symbol() {
        ".";
    }

    method color-name() {
        $.is-current-branch
            ?? "<inverted-white>{$.name}</inverted-white>"
            !! $.name;
    }

    method info() {
        "";
    }

    method child-indent() {
        "  ";
    }

    method done() {
        False;
    }
}

class Git::Branch::Child does Git::Branch {
    has $.ahead is rw = 0;
    has $.behind is rw = 0;
    has Git::Branch $.parent is rw;

    method action-symbol() {
        when $.conflict { "<red>!</red>" }
        when ?$.ahead && ?$.behind { "<red>*</red>" }
        when $.done { "<gray>~</gray>" }
        default { "." }
    }

    method color-name() {
        $.is-current-branch
            ?? "<inverted-green>{$.name}</inverted-green>"
            !! self.done()
                ?? "<gray>{$.name}</gray>"
                !! "<green>{$.name}</green>";
    }

    method info() {
        my $ahead = $.ahead ?? "+{$.ahead}" !! "";
        my $behind = $.behind ?? "-{$.behind}" !! "";
        return " [done]"
            if !$ahead && $behind;

        my $against = $.conflict && $.conflict-against ne $.parent.name
                ?? " against {$.conflict-against}"
                !! "";
        my $conflict = $.conflict
                ?? "<red>conflict</red>$against"
                !! "";
        my @terms = [$ahead, $behind, $conflict]\
            .grep(* ne "");
        return ""
            unless @terms;

        return " [{ @terms.join(", ") }]";
    }

    method child-indent() {
        "..";
    }

    method done() {
        $.behind && !$.ahead;
    }
}
