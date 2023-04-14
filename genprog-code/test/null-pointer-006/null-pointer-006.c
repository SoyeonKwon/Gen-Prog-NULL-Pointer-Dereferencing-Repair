#include <stdio.h>
#include <stdint.h>
/*
 * Defect types : NULL pointer dereference (access)
 * Complexity: Assign a Value of random variable to NULL single pointer
 */
int rand(void);
/*
void null_pointer_006()
{
	int* p;
	p = (int*)(intptr_t)rand();
	*p = 1;/*Tool should detect this line as error*/ /*ERROR:NULL pointer dereference*/
//}

int cause_err(int index, int *ptr[]){
  ptr[index] = (int*)(intptr_t)rand();
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
