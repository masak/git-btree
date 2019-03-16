class Git::Branch {
    has $.name is required;
    has $.ahead is required;
    has $.behind is required;

    has Git::Branch @.children;

    method add-child(Git::Branch $child-branch) {
        @.children.push($child-branch);
        @.children.=sort(*.name);
    }

    method AT-POS($pos) {
        @.children[$pos];
    }
}
