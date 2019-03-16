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
        $.name;
    }

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

    method color-name() {
        "<green>{$.name}</green>";
    }

    method ahead-behind-info() {
        $.ahead
            ?? " [{$.ahead}+]"
            !! "";
    }

    method child-indent() {
        "..";
    }
}
