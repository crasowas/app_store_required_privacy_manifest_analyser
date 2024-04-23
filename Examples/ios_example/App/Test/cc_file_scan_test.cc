//
//  cc_file_scan_test.cc
//  App
//
//  Created by crasowas on 2024/4/23.
//

#include <stdio.h>
#include <sys/stat.h>

void test(const char *path) {
    struct stat fileStat;
    if (stat(path, &fileStat) == 0) {
        printf("File Size: %lld bytes\n", fileStat.st_size);
    } else {
        printf("Failed to get file stat.\n");
    }
}
