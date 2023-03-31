
#include <stdio.h>

int main(int argc, char *argv[]) {

  // The size of the pointer array
  const int ARR_SIZE = 10;
  // The index of the array from cmd line arguments
  int arg_index = atoi(argv[1]);
  int NUM_NEGTESTS = 3;
  // The indices with a null pointer
  int null_indices[] = {3, 6, 9};
  // A pointer array
  int *ptr[ARR_SIZE];
  // An integer array
  int nums[ARR_SIZE];
  // if the index is for a negative test
  int negIndex = 0;
 
  
  // Set the pointer and integer array
  // integer array[i] = i + 1
  // pointer array[i] = address of i th of the integer array
  for (int i = 0; i < ARR_SIZE; i++){
    nums[i] = i + 1;

    // For each integer array index, check if it is an index for negative tests
    for (int j = 0; j < NUM_NEGTESTS; j++) {
	// If the index should be a bug/error,
	if (i == null_indices[j]) {
		// Set flag to true
		negIndex = 1;
	}
    }

    if (negIndex == 1) {
	// 1st benchmark problem
      ptr[i] = ((void *) 0);
      ptr[i] = 1;
    }
    else {
	ptr[i] = &nums[i];
    }

    negIndex = 0;
    
  }

  // Result
  printf("%d\n", *ptr[arg_index]);
  return 0;
}
