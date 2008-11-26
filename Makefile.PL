use inc::Module::Install;
name 'HTTP-Router';
all_from 'lib/HTTP/Router.pm';

requires 'Moose';
requires 'MooseX::AttributeHelpers';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::use::ok';
test_requires 'YAML';
test_requires 'HTTP::Request';
test_requires 'URI';
test_requires 'Test::MockObject';
author_tests 'xt';
use_test_base;

auto_include_deps;
WriteAll;
