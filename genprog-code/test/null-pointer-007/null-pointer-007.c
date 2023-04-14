#include <stdio.h>
#include <stdint.h>
/*
 * Defect types : NULL pointer dereference (access)
 * Complexity: single pointer Linear equation expressions	Write
 */
/*
void null_pointer_007()
{
	int* p;
	int a = 3;
	p = (int*)(intptr_t)((2 * a) - 6);
	*p = 1;/*Tool should detect this line as error*/ /*ERROR:NULL pointer dereference*/
//}

int cause_err(int index, int *ptr[]){
  int a = 3;
  ptr[index] = (int*)(intptr_t)((2 * a) - 6);
  *ptr[index] = 1;
  return 1;
}

int main(int argc, char *argv[]){
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

  for(int i = 0; i < ARR_SIZE; i++){
    nums[i] = i + 1;
    for(int j = 0; j < NUM_NEGTESTS; j++){
      if (arg_index == null_indices[j]){
	negIndex = cause_err(null_indices[j], ptr); 
      }
    }
    if (negIndex == 0){
      ptr[i] = &nums[i];
    }
  }
  
  int result = *ptr[arg_index];
  printf("%d\n",result);
  
  
  return 0;
}
