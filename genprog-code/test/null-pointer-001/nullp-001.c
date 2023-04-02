
#include <stdio.h>

int cause_err(int index, int *ptr[]);

int main(int argc, char *argv[]) {

  // The size of the pointer array
  int ARR_SIZE = 10;
  // The index of the array from cmd line arguments
  int arg_index = atoi(argv[1]);
  int NUM_NEGTESTS = 3;
  // The indices with a null pointer
  int null_indices[] = {3, 6, 9};
  // A pointer array
  int *ptr[10];
  // An integer array
  int nums[10];

  int negIndex = 0;
 
  
  // Set the pointer and integer array
  // integer array[i] = i + 1
  // pointer array[i] = address of i th of the integer array
  for (int i = 0; i < ARR_SIZE; i++){
    nums[i] = i + 1;
    ptr[i] = ((void *) 0);
    for(int j = 0; j < NUM_NEGTESTS; j++){
      if (arg_index == null_indices[j]){
	negIndex = cause_err(arg_index, ptr); 
      }
    }
    if (negIndex == 0){
      ptr[i] = &nums[i];
    }
  }

// Result
  printf("%d\n", *ptr[arg_index]);

  return 0;
}

int cause_err(int index, int *ptr[]){
  *ptr[index] = 1;
  return 1;
}
