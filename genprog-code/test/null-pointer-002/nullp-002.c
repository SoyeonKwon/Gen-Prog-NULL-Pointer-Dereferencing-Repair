#include <stdio.h>

static int sink;
void null_pointer_002 ()
{
	int *p = NULL;
	int ret;
	ret = *p;/*Tool should detect this line as error*/ /*ERROR:NULL pointer dereference*/
        sink = ret;
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
  int *ptr[ARR_SIZE];

  int nums[ARR_SIZE];

  for(int i = 0; i < ARR_SIZE; i++){
    nums[i] = i + 1;
    ptr[i] = &nums[i];
  }
  
  for(int j = 0; j < NUM_NEGTESTS; j++){
    ptr[null_indices[j]] = NULL;
  }

  int result = *ptr[arg_index];
  printf("%d\n",result);
  
  
  return 0;
}
