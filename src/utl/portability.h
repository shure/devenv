
#pragma once

#ifdef __GNUC__
#define FORMAT_PRINTF(string_index, first_to_check) \
  __attribute__((format(printf, string_index, first_to_check)))
#else
#define FORMAT_PRINTF(string_index, first_to_check)
#endif /* __GNUC__ */
