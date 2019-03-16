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
        ". {self.color-name()}{self.ahead-behind-info()}\n" ~
        @.children».color-output
            .join()
            .indent(2)
            .subst(/^^ "  "/, self.child-indent(), :g);
    }

    method monochrome-output() {
        self.color-output()
            .subst(/"<" "/"? \w+ ">"/, "", :g);
    }

    method color-name { ... }

    method ahead-behind-info() { ... }

    method child-indent() { ... }
}

class Git::Branch::Root does Git::Branch {
    method color-name {
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
}

class Git::Branch::Child does Git::Branch {
    has $.ahead is rw = 0;
    has $.behind is rw = 0;

    method color-name() {
        $.is-current-branch
            ?? "<inverted-green>{$.name}</inverted-green>"
            !! "<green>{$.name}</green>";
    }

    method ahead-behind-info() {
        $.ahead && $.behind
            ?? " [{$.ahead}+, {$.behind}-]"
            !! $.ahead
                ?? " [{$.ahead}+]"
                !! "";
    }

    method child-indent() {
        "..";
    }
}
