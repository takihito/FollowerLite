use inc::Module::Install;
name 'FollowerLite';
all_from 'lib/FollowerLite.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
