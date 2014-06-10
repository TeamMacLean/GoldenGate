use Test::More;

subtest 'instance is returned' => sub {
    new_ok('Foo');
};

subtest 'default value is correct' => sub {
    my $foo = Foo->new;

    is($foo->bar, '123');
};

done_testing;