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
}

class Git::Branch::Root does Git::Branch {
}

class Git::Branch::Child does Git::Branch {
    has $.ahead is required;
    has $.behind is required;
}
