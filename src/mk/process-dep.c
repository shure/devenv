
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <ctype.h>
#include <stdlib.h>

/* 
   Following algorithm is implemented:
   o given a list of dependency files;
   o for each dependency file: check whether contains a non existing prerequisite;
   o for each bad dependency file: remove its target and the dependency file itself;
   o print paths to valid dependency files
*/

int can_stat(const char* path)
{
  static struct stat buf;
  if (stat(path, &buf) == 0) {
    return 1;
  } else {
    return 0;
  }
}

void remove_file(const char* path) {
  //fprintf(stderr, "removing \"%s\"\n", path);
  if(remove(path) != 0) {
    //perror(path);
  }
}

void process_dep_file(const char* depFilePath)
{
  //  fprintf(stderr, "processing %s\n", depFilePath);

  char line[1024], target[1024];
  char* ptr; 

  FILE* depFile = fopen(depFilePath, "r");
  if (!depFile) return;
    
  target[0] = 0;
  while (!feof(depFile)) {
    /* read first line, extract target */
    if (!fgets(line, sizeof(line), depFile)) {
      break;
    }
    ptr = strchr(line, ':');
    if (ptr) {
      char *start = line;
      *ptr = 0;
      while(isspace(*start)) start++;
      strcpy(target, start);
      break;
    }
  }
  
  while (!feof(depFile)) {
    if (!fgets(line, sizeof(line), depFile)) {
      break;
    }
    ptr = strtok(line, " \n\\");
    while (ptr) {
      if (!can_stat(ptr)) {
        /* problem was found */
        // fprintf(stderr, "problem was found %s\n", ptr);
        remove_file(target);
        return;
      }
      ptr = strtok(0, " \n\\");
    }
  }

  printf("%s\n", depFilePath);
}

int main(int argc, const char** argv)
{
  int u;
  for (u = 1; u < argc; u++) {
    process_dep_file(argv[u]);
  }
  printf("always_print_some_nonexistent_file.h\n");
  return 0;
}
