use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok 'Catmandu::Importer::Sisis';
    use_ok 'Catmandu::Fix::sisis_map';
    use_ok 'Sisis::Parser';

}

require_ok 'Catmandu::Importer::Sisis';
require_ok 'Catmandu::Fix::sisis_map';
require_ok 'Sisis::Parser';

done_testing;