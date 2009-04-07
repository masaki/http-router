package HTTP::Router::Debug;

use strict;
use warnings;
use Text::SimpleTable;

our @EXPORT = qw(routing_table draw_routing_table);

sub import {
    # TODO: into package
    my $into = 'HTTP::Router';
    eval "require $into; 1" or die $@;

    no strict 'refs';
    no warnings 'redefine';
    for my $keyword (@EXPORT) {
        *{ $into . '::' . $keyword } = \&{ __PACKAGE__ . '::' . $keyword };
    }
}

sub draw_routing_table {
    my $table = shift->routing_table->draw;
    print "$table\n";
}

sub routing_table {
    my $self = shift;

    my $table = Text::SimpleTable->new(
        [qw(35 path)      ],
        [qw(10 method)    ],
        [qw(10 controller)],
        [qw(10 action)    ],
    );

    for my $route ($self->routes) {
        my $method = $route->conditions->{method};
        $method = [ $method ] unless ref $method;

        $table->row(
            $route->path,
            join(',', @$method),
            $route->params->{controller},
            $route->params->{action}
        );
    }

    return $table;
}

1;

=head1 NAME

HTTP::Router::Debug

=head1 SYNOPSIS

    use HTTP::Router;
    use HTTP::Router::Debug;

    my $router = HTTP::Router->define(...);

    print $router->routing_table->draw;
    # or
    $router->draw_routing_table;

=head1 METHODS

=head2 routing_table

=head2 draw_routing_table

=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>, L<Text::SimpleTable>

=cut
