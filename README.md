Catmandu::Sisis - Catmandu modules for working with Sisis data.

# Installation

Install the latest distribution from CPAN:

    cpanm Catmandu::Sisis

Install the latest developer version from GitHub:

    cpanm git://github.com/jorol/Catmandu-Sisis.git@devel

# Contribution

For bug reports and feature requests use <https://github.com/jorol/Catmandu-Sisis/issues>.

For contributions to the source code create a fork or use the `devel` branch. The master
branch should only contain merged and stashed changes to appear in Changelog.

Dist::Zilla and build requirements can be installed this way:

    cpan Dist::Zilla
    dzil authordeps | cpanm

Build and test your current state this way:

    dzil build
    dzil test 
    dzil smoke --release --author # test more

# Status

Build and test coverage of the `devel` branch at <https://github.com/jorol/Catmandu-Sisis/>:

[![Build Status](https://travis-ci.org/jorol/Catmandu-Sisis.png)](https://travis-ci.org/jorol/Catmandu-Sisis)
[![Coverage Status](https://coveralls.io/repos/jorol/Catmandu-Sisis/badge.png?branch=devel)](https://coveralls.io/r/jorol/Catmandu-Sisis?branch=devel)
[![Kwalitee Score](http://cpants.cpanauthors.org/dist/Catmandu-Sisis.png)](http://cpants.cpanauthors.org/dist/Catmandu-Sisis)
[![CPAN version](https://badge.fury.io/pl/Catmandu-Sisis.png)](http://badge.fury.io/pl/Catmandu-Sisis)
