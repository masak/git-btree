class Git::Branch::Child { ... }

role Git::Branch {
    has $.name is required;
    has Git::Branch::Child @.children;

    method add-child(Git::Branch::Child $child-branch) {
        @.children.push($child-branch);
        @.children.=sort(*.name);
    }

    method AT-POS($pos) {
        @.children[$pos];
    }

    method monochrome-output() {
        ". {$.name}{self.ahead-behind-info()}\n" ~
        @.children».monochrome-output
            .join()
            .indent(2)
            .subst(/^^ "  "/, self.child-indent(), :g);
    }

    method ahead-behind-info() { ... }

    method child-indent() { ... }
}

class Git::Branch::Root does Git::Branch {
    method ahead-behind-info() {
        "";
    }

    method child-indent() {
        "  ";
    }
}

class Git::Branch::Child does Git::Branch {
    has $.ahead is required;
    has $.behind is required;

    method ahead-behind-info() {
        $.ahead
            ?? " [{$.ahead}+]"
            !! "";
    }

    method child-indent() {
        "..";
    }
}
