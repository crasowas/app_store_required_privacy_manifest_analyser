//
//  cpp_file_scan_test.cpp
//  App
//
//  Created by crasowas on 2024/4/23.
//

#include "cpp_file_scan_test.hpp"

void test(const char *path) {
    struct stat fileStat;
    if (stat(path, &fileStat) == 0) {
        printf("File Size: %lld bytes\n", fileStat.st_size);
    } else {
        printf("Failed to get file stat.\n");
    }
}
