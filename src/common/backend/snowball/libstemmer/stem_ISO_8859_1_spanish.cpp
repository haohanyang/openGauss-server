
/* This file was generated automatically by the Snowball to ANSI C compiler */

#include "header.h"

#ifdef __cplusplus
extern "C" {
#endif
extern int spanish_ISO_8859_1_stem(struct SN_env* z);
extern struct SN_env* spanish_ISO_8859_1_create_env(void);
extern void spanish_ISO_8859_1_close_env(struct SN_env* z);
#ifdef __cplusplus
}
#endif

extern int spanish_ISO_8859_1_stem(struct SN_env* z)
{
    ereport(ERROR,
        (errmodule(MOD_TS),
            errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
            errmsg("Text search for Spanish is not supported!")));
    return 1;
}

extern struct SN_env* spanish_ISO_8859_1_create_env(void)
{
    ereport(ERROR,
        (errmodule(MOD_TS),
            errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
            errmsg("Text search for Spanish is not supported!")));
    return NULL;
}

extern void spanish_ISO_8859_1_close_env(struct SN_env* z)
{
    ereport(ERROR,
        (errmodule(MOD_TS),
            errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
            errmsg("Text search for Spanish is not supported!")));
}