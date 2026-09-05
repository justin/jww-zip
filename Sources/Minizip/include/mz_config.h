#ifndef MZ_CONFIG_H
#define MZ_CONFIG_H

/* Static configuration for the SPM build of minizip-ng.

   minizip-ng normally generates this header with CMake. This package builds
   the C sources directly with SwiftPM's Clang, so the feature-test values are
   fixed here for the supported POSIX platforms (Darwin and Linux). Every
   target this package supports provides these headers and functions. */

/* Define to 1 if you have the <dirent.h> header file. */
#define HAVE_DIRENT_H 1

/* Define to 1 if you have the <sys/dirent.h> header file. */
#define HAVE_SYS_DIRENT_H 0

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if DIR* is defined. */
#define HAVE_PDIR 1

/* Define to 1 if fseeko() is defined. */
#define HAVE_FSEEKO 1

/* Define to 1 if symlink() is defined. */
#define HAVE_SYMLINK 1

/* Define to 1 if readlink() is defined. */
#define HAVE_READLINK 1

#endif
