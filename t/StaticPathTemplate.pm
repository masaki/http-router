package t::StaticPathTemplate;

sub new {
    my ($class, $path) = @_;
    return bless { path => $path }, $class;
}

sub variables         { () }
sub extract           { () }
sub process_to_string { shift->{path} }

1;
