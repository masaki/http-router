use inc::Module::Install;
name 'HTTP-Router';
all_from 'lib/HTTP/Router.pm';

requires 'Class::Accessor::Fast';
requires 'Hash::Merge';
requires 'List::MoreUtils';
requires 'Scalar::Util' => '1.14';
requires 'Lingua::EN::Inflect::Number';
requires 'String::CamelCase';
requires 'URI::Template::Restrict' => '0.03';
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
