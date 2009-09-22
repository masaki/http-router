use inc::Module::Install;
name 'HTTP-Router';
all_from 'lib/HTTP/Router.pm';

requires 'Any::Moose' => '0.10';
requires_any_moose                        prefer => 'Mouse', mouse => '0.21';
requires_any_moose 'X::AttributeHelpers', prefer => 'Mouse', mouse => '0.03';

# Core
requires 'Hash::AsObject';
requires 'List::MoreUtils';
requires 'URI::Template::Restrict' => '0.03';
requires 'Scalar::Util' => '1.14';
# Declare
requires 'Carp';
requires 'Storable';
requires 'Devel::Caller::Perl';
requires 'String::CamelCase';
requires 'Lingua::EN::Inflect::Number';
# Debug
requires 'Text::SimpleTable';

tests 't/*.t t/*/*.t';
test_requires 'Test::More';
test_requires 'Test::UseAllModules';
test_requires 'Test::MockObject';
test_requires 'Test::Deep';
author_tests 'xt';
use_test_base;

auto_set_repository;
auto_include_deps;
WriteAll;
