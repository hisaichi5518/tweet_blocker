requires 'perl', '5.010001';

requires "Config::Pit";
requires "Mouse";
requires "Net::Twitter::Lite";
requires "Net::OAuth";

on 'test' => sub {
    requires 'Test::More', '0.98';
};

