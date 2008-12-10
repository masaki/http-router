use inc::Module::Install;
name 'HTTP-Router';
all_from 'lib/HTTP/Router.pm';

requires 'Moose';
requires 'Moose::Util::TypeConstraints';
requires 'MooseX::AttributeHelpers';
requires 'List::MoreUtils';
requires 'Storable';
requires 'URI::Template' => 0.13;
requires 'Text::SimpleTable';
requires 'Sub::Install';
requires 'Module::Pluggable::Object';
requires 'String::CamelCase';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::use::ok';
author_tests 'xt';
use_test_base;

auto_include_deps;
WriteAll;
