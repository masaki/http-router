package HTTP::Router::PluginLoader;
use Moose;
use Module::Pluggable::Object;
use UNIVERSAL::require;

no Moose;

sub load_plugin {
    my ( $self, $plugin ) = @_;
    $plugin->require;
    $plugin->new->setup;
}

sub load_all_plugins {
    my $self    = shift;
    my $locator = Module::Pluggable::Object->new(
        search_path => ['HTTP::Router::Plugin'], );
    foreach my $plugin ( $locator->plugins ) {
        $self->load_plugin($plugin);
    }
}

__PACKAGE__->meta->make_immutable;

1;
