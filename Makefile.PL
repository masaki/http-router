use inc::Module::Install;
name 'HTTP-Router';
all_from 'lib/HTTP/Router.pm';

requires 'Any::Moose' => '0.07';
requires 'Clone';
requires 'Hash::Merge';
requires 'Lingua::EN::Inflect::Number';
requires 'String::CamelCase';
requires 'URI::Template::Restrict' => '0.03';
requires 'Text::SimpleTable';

recommends 'Mouse' => '0.20';
recommends 'MouseX::AttributeHelpers';

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
