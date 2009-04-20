use inc::Module::Install;
name 'HTTP-Router';
all_from 'lib/HTTP/Router.pm';

requires 'Any::Moose' => '0.07';
requires 'Carp';
requires 'Storable';
requires 'Devel::Caller::Perl';
requires 'String::CamelCase';
requires 'Lingua::EN::Inflect::Number';
requires 'Scalar::Util' => '1.14';
requires 'URI::Template::Restrict' => '0.03';
requires 'Text::SimpleTable';

recommends 'Mouse' => '0.21';
recommends 'MouseX::AttributeHelpers' => '0.03';

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
