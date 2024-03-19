#include <chrono>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <thread>

#define KiB ((size_t)1024)
#define MiB ((size_t)1024 * KiB)
#define GiB ((size_t)1024 * MiB)

#define RANDOM_WRITE_COUNT (512)
#define SEQUENTIAL_WRITE_COUNT (1 * MiB)

using namespace std::chrono_literals;

volatile bool signal_received = false;
void signal_handler(int) { signal_received = true; }

enum ProgramMode { UNSET, RANDOM, SEQUENTIAL, CALIB };

char *test_data;
size_t test_data_len;
void init_test_data(size_t len) {
  if (test_data) {
    delete[] test_data;
    test_data = NULL;
  }

  test_data = new char[len];
  test_data_len = len;
}

void create_test_file(std::string filename, size_t filesize) {
  std::cout << "Preparing workfile..." << std::flush;

  std::ofstream outfile(filename, std::ios::out | std::ios::binary);

  // write random file in 1MiB chunks
  for (unsigned i = 0; i < filesize / test_data_len; i++) {
    if (signal_received)
      break;

    outfile.write(test_data, test_data_len);
  }

  // write rest of file and clean up
  outfile.write(test_data + (test_data_len - filesize % test_data_len),
                filesize % test_data_len);

  std::cout << " done." << std::endl;
}

size_t period_io_limit = -1;

size_t bytes_written;
void write_sequential(FILE *outfile, size_t len) {
  fwrite(test_data, 1, len, outfile);
  fflush(outfile);
  bytes_written += len;
}

void write_sequential_throttle(FILE *outfile, size_t len) {
  static auto last_wake = std::chrono::system_clock::now();

  write_sequential(outfile, len);

  if (bytes_written >= period_io_limit) {
    auto next_wake = last_wake + (10ms * (bytes_written / period_io_limit));
    std::this_thread::sleep_until(next_wake);
    bytes_written = 0;
    last_wake = next_wake;
  }
}

size_t iops_completed;
void write_random(FILE *outfile, size_t filesize, size_t len) {
  int offset = rand() % filesize;
  if (filesize - offset < len) {
    offset = filesize - len;
  }

  fseek(outfile, offset, SEEK_SET);
  fwrite(test_data, 1, len, outfile);
  fflush(outfile);
  iops_completed++;
}

void write_random_throttle(FILE *outfile, size_t filesize, size_t len) {
  static auto last_wake = std::chrono::system_clock::now();

  write_random(outfile, filesize, len);

  if (iops_completed >= period_io_limit) {
    auto next_wake = last_wake + 10ms;
    std::this_thread::sleep_until(next_wake);
    iops_completed = 0;
    last_wake = next_wake;
  }
}

void print_usage(const char *program_name) {
  printf("Usage:\t%s [--limit <calib IOPS | B/s> <fraction thereof>] "
         "<--random|--sequential|--calib>\n",
         program_name);
  printf("E.g.:\t%s --limit 80000 0.1 --random\n", program_name);
  printf("\tLoad system with 8000 IOPS (~10%% of calibrated maximum)\n");
  printf("\nEnvironment variables:\n");
  printf("  TMP\t\t directory to store workfile\t(default: /tmp)\n");
  printf("  WORKFILE_SIZE\t size of workfile\t\t(default: 8G)\n");

  exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
  std::string exec_name = std::string(argv[0]);
  exec_name = exec_name.substr(exec_name.rfind('/') + 1);

  // set workfile location from environment
  std::string tmpdir = "/tmp/";
  if (const char *tmpdir_env = getenv("TMP")) {
    tmpdir = tmpdir_env;
  }
  std::string filename = tmpdir + "/" + exec_name + "_workfile";

  // set workfile size from environment
  size_t filesize = 8 * GiB;
  if (const char *filesize_env = getenv("WORKFILE_SIZE")) {
    size_t len = std::string(filesize_env).length();
    filesize = atol(filesize_env);
    switch (filesize_env[len - 1]) {
    case 'G':
      filesize *= GiB;
      break;
    case 'M':
      filesize *= MiB;
      break;
    case 'K':
      filesize *= KiB;
      break;
    default:
      std ::cout
          << "Invalid value for WORKFILE_SIZE (supported suffixes: G, M, K)"
          << std::endl;
      return EXIT_FAILURE;
      break;
    }
  }

  // set program mode and I/O limit from command line
  ProgramMode mode = UNSET;
  size_t io_limit = 0;
  for (int i = 1; i < argc; i++) {
    std::string arg = std::string(argv[i]);

    if (arg == "-r" || arg == "--random") {
      mode = RANDOM;
    } else if (arg == "-s" || arg == "--sequential") {
      mode = SEQUENTIAL;
    } else if (arg == "-c" || arg == "--calib") {
      mode = CALIB;
    } else if (arg == "-l" || arg == "--limit") {
      if (argc - (i + 2) <= 0) {
        print_usage(argv[0]);
      }

      io_limit = atoll(argv[i + 1]);
      io_limit *= strtod(argv[i + 2], NULL);

      period_io_limit = io_limit / 100;
    }
  }

  if (mode == UNSET) {
    print_usage(argv[0]);
  }

  // set up signal handler to ensure clean-up always runs
  std::signal(SIGINT, signal_handler);
  std::signal(SIGTERM, signal_handler);

  // perform test
  switch (mode) {

  case SEQUENTIAL: {
    init_test_data(SEQUENTIAL_WRITE_COUNT);
    create_test_file(filename, filesize);

    std::cout << "Creating sequential I/O load until killed by signal."
              << std::endl;

    while (!signal_received) {
      FILE *outfile = fopen(filename.c_str(), "r+");
      for (size_t pos = 0; pos < filesize; pos += test_data_len) {
        write_sequential_throttle(outfile, test_data_len);

        if (signal_received)
          break;
      }
      fseek(outfile, 0, SEEK_SET);
    }
  } break;

  case RANDOM: {
    init_test_data(SEQUENTIAL_WRITE_COUNT);
    create_test_file(filename, filesize);

    std::cout << "Creating random I/O load until killed by signal."
              << std::endl;

    FILE *outfile = fopen(filename.c_str(), "r+");
    while (!signal_received) {
      write_random_throttle(outfile, filesize, RANDOM_WRITE_COUNT);

      if (signal_received)
        break;
    }
    fclose(outfile);
  } break;

  case CALIB: {
    init_test_data(SEQUENTIAL_WRITE_COUNT);
    create_test_file(filename, filesize);

    FILE *outfile = fopen(filename.c_str(), "r+");

    std::cout << "Testing sequential write performance..." << std::endl;

    auto calib_sequential_start = std::chrono::system_clock::now();
    while (calib_sequential_start + 10s > std::chrono::system_clock::now()) {
      for (size_t pos = 0; pos < filesize; pos += test_data_len) {
        write_sequential(outfile, test_data_len);

        if (signal_received)
          break;
      }
      fseek(outfile, 0, SEEK_SET);

      if (signal_received)
        break;
    }
    auto calib_sequential_end = std::chrono::system_clock::now();
    auto calib_sequential_duration =
        std::chrono::duration_cast<std::chrono::milliseconds>(
            calib_sequential_end - calib_sequential_start);

    size_t bytes_per_second =
        bytes_written / ((double)calib_sequential_duration.count() / 1000);

    std::cout << "Testing random write performance..." << std::endl;

    auto calib_random_start = std::chrono::system_clock::now();
    while (calib_random_start + 10s > std::chrono::system_clock::now()) {
      write_random(outfile, filesize, RANDOM_WRITE_COUNT);

      if (signal_received)
        break;
    }
    auto calib_random_end = std::chrono::system_clock::now();
    auto calib_random_duration =
        std::chrono::duration_cast<std::chrono::milliseconds>(
            calib_random_end - calib_random_start);

    size_t iops =
        iops_completed / ((double)calib_random_duration.count() / 1000);

    std::cout << "sequential:\t" << bytes_per_second << " B/s" << std::endl;
    std::cout << "random:\t\t" << iops << " IOPS" << std::endl;

  } break;

  default:
    break;
  }

  std::cout << "Exiting..." << std::endl;

  // clean up
  delete[] test_data;
  std::filesystem::remove(filename);
}
