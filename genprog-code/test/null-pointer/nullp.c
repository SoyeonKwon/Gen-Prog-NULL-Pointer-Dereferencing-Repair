#include <stdio.h>

int main(int argc, char *argv[]){
  // The size of the pointer array
  int ARR_SIZE = 10;
  // The index of the array from cmd line arguments
  int arg_index = atoi(argv[1]);
  int NUM_NEGTESTS = 3;
  // The indices with a null pointer
  int null_indices[] = {3, 6, 9};
  // A pointer array
  int *ptr[ARR_SIZE];
  // An integer array
  int nums[ARR_SIZE];

  // Set the pointer and integer array
  // integer array[i] = i + 1
  // pointer array[i] = address of i th of the integer array
  for (int i = 0; i < ARR_SIZE; i++){
    nums[i] = i + 1;
    ptr[i] = &nums[i];
  }

  for (int i = 0; i < NUM_NEGTESTS; i++){
    ptr[null_indices[i]] = 0;
  }

  // Result
  printf("%d\n", *ptr[arg_index]);

  return 0;
}
