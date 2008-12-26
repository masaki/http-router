use inc::Module::Install;
name 'HTTP-Router';
all_from 'lib/HTTP/Router.pm';

requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'namespace::clean';

requires 'URI::Template::Restrict';
requires 'Hash::Merge';
requires 'List::MoreUtils';
requires 'Set::Array';
requires 'Lingua::EN::Inflect::Number';
requires 'String::CamelCase';

requires 'Text::SimpleTable';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'ok';
test_requires 'Test::MockObject';
test_requires 'Test::Deep';
author_tests 'xt';
use_test_base;

auto_include_deps;
WriteAll;
