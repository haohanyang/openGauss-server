/* -------------------------------------------------------------------------
 *
 * linux.c
 *	  Dynamic Loader for Postgres for Linux, generated from those for
 *	  Ultrix.
 *
 *	  You need to install the dld library on your Linux system!
 *
 * Portions Copyright (c) 1996-2012, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *
 * IDENTIFICATION
 *	  src/backend/port/dynloader/linux.c
 *
 * -------------------------------------------------------------------------
 */

#include "postgres.h"
#include "knl/knl_variable.h"

#ifdef HAVE_DLD_H
#include <dld.h>
#endif

#include "dynloader.h"
#include "miscadmin.h"

#ifndef HAVE_DLOPEN

void* pg_dlopen(char* filename)
{
#ifndef HAVE_DLD_H
    ereport(ERROR, (errcode(ERRCODE_FEATURE_NOT_SUPPORTED), errmsg("dynamic load not supported")));
    return NULL;
#else
    static int dl_initialized = 0;
    char* local_ptr = NULL;

    /*
     * initializes the dynamic loader with the executable's pathname. (only
     * needs to do this the first time pg_dlopen is called.)
     */
    if (!dl_initialized) {
        if (dld_init(dld_find_executable(my_exec_path)))
            return NULL;

        /*
         * if there are undefined symbols, we want dl to search from the
         * following libraries also.
         */
        dl_initialized = 1;
    }

    /*
     * link the file, then check for undefined symbols!
     */
    if (dld_link(filename))
        return NULL;

    /*
     * If undefined symbols: try to link with the C and math libraries! This
     * could be smarter, if the dynamic linker was able to handle shared libs!
     */
    if (dld_undefined_sym_count > 0) {
        if (dld_link("/usr/lib/libc.a")) {
            ereport(WARNING, (errmsg("could not link C library")));
            return NULL;
        }
        if (dld_undefined_sym_count > 0) {
            if (dld_link("/usr/lib/libm.a")) {
                ereport(WARNING, (errmsg("could not link math library")));
                return NULL;
            }
            if (dld_undefined_sym_count > 0) {
                int count = dld_undefined_sym_count;
                char** list = dld_list_undefined_sym();

                /* list the undefined symbols, if any */
                do {
                    ereport(WARNING, (errmsg("\"%s\" is undefined", *list)));
                    list++;
                    count--;
                } while (count > 0);

                dld_unlink_by_file(filename, 1);
                return NULL;
            }
        }
    }

    local_ptr = MemoryContextStrdup(SESS_GET_MEM_CXT_GROUP(MEMORY_CONTEXT_CBB), filename);
    return (void*)local_ptr;
#endif
}

PGFunction pg_dlsym(void* handle, char* funcname)
{
#ifndef HAVE_DLD_H
    return NULL;
#else
    return (PGFunction)dld_get_func((funcname));
#endif
}

void pg_dlclose(void* handle)
{
#ifndef HAVE_DLD_H
#else
    dld_unlink_by_file(handle, 1);
    pfree(handle);
#endif
}

char* pg_dlerror(void)
{
#ifndef HAVE_DLD_H
    return "dynaloader unspported";
#else
    return dld_strerror(dld_errno);
#endif
}

#endif /* !HAVE_DLOPEN */
