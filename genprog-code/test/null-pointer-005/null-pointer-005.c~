#include <stdio.h>
/*
 * Defect types : NULL pointer dereference (access)
 * Complexity: Assign a Constant value to NULL struct pointer
 */
typedef struct {
	int a;
	int b;
	int c;
} nullp_004_struct;

/*
void null_pointer_004()
{
	null_pointer_004_s_001* p = NULL;
	p->a = 1;/*Tool should detect this line as error*/ /*ERROR:NULL pointer dereference*/
//}

int cause_err(int index, nullp_004_struct *ptr[]){
  ptr[index]->a = 1;
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
  nullp_004_struct *ptr[10];
  // Struct array
  nullp_004_struct strc[10];
  
  // An integer array
  int nums[10];
  int negIndex = 0;

  for(int i = 0; i < ARR_SIZE; i++){
    nums[i] = i + 1;
    ptr[i] = ((void *) 0);
    for(int j = 0; j < NUM_NEGTESTS; j++){
      if (arg_index == null_indices[j]){
	negIndex = cause_err(null_indices[j], ptr); 
      }
    }
    if (negIndex == 0){
      ptr[i] = &strc[i];
      ptr[i]->a = nums[i];
    }
  }
  
  int result = ptr[arg_index]->a;
  printf("%d\n",result);
  
  
  return 0;
}
