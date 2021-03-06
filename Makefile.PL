use ExtUtils::MakeMaker;

my $pkg_cfg = "PKG_CONFIG_PATH=/usr/local/lib/pkgconfig";
my $lwes_libs = `$pkg_cfg pkg-config lwes-1 --libs`;
my $lwes_cflags = `$pkg_cfg pkg-config lwes-1 --cflags`;

WriteMakefile(
    'NAME'           => 'LWES',
    'VERSION'        => '0.4.3',
    'EXE_FILES'      => [ "lwes-perl-event-listener",
                          "lwes-perl-journal-listener" ],
    'PREREQ_PM'      => {
                          'IO::Socket::Multicast' => 0,
                        },
    'LIBS'           => $lwes_libs,
    'INC'            => $lwes_cflags,
    'OBJECT'         => 'lwes_wrap.o',
    'dynamic_lib'    => { 'OTHERLDFLAGS' => "-llwes -lm"},
);

