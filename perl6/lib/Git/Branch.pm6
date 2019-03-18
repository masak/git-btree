class Git::Branch::Child { ... }

role Git::Branch {
    has $.name is required;
    has Bool $.is-current-branch;
    has Git::Branch::Child @.children;

    method add-child(Git::Branch::Child $child-branch) {
        @.children.push($child-branch);
        @.children.=sort(*.name);
    }

    method AT-POS($pos) {
        @.children[$pos];
    }

    method color-output() {
        my $branch-description = "{self.action-symbol()} {self.color-name()}{self.ahead-behind-info()}\n";

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

    method action-symbol() { ... }

    method color-name() { ... }

    method ahead-behind-info() { ... }

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

    method ahead-behind-info() {
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

    method action-symbol() {
        $.ahead && $.behind
            ?? "<red>*</red>"
            !! self.done()
                ?? "<gray>~</gray>"
                !! ".";
    }

    method color-name() {
        $.is-current-branch
            ?? "<inverted-green>{$.name}</inverted-green>"
            !! self.done()
                ?? "<gray>{$.name}</gray>"
                !! "<green>{$.name}</green>";
    }

    method ahead-behind-info() {
        $.ahead && $.behind
            ?? " [+{$.ahead}, -{$.behind}]"
            !! $.ahead
                ?? " [+{$.ahead}]"
                !! $.behind
                    ?? " [done]"
                    !! "";
    }

    method child-indent() {
        "..";
    }

    method done() {
        $.behind && !$.ahead;
    }
}
