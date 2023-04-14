#include <stdio.h>
/*
 * Defect types : NULL pointer dereference (access)
 * Complexity: Assign a Constant value to NULL union pointer
 */
typedef struct {
	int a;
	int b;
} nullp_005_struct_001;

typedef struct {
	int a;
	int b;
} nullp_005_struct_002;

typedef struct {
	int a;
	int b;
} nullp_005_struct_003;

typedef union {
  nullp_005_struct_001 s1;
  nullp_005_struct_002 s2;
  nullp_005_struct_003 s3;
} nullp_005_struct_uni;

/*
void null_pointer_005()
{
	null_pointer_005_uni_001* p = NULL;
	p->s1.a = 1;/*Tool should detect this line as error*/ /*ERROR:NULL pointer dereference*/
//}


int cause_err(int index, nullp_005_struct_uni *ptr[]){
  ptr[index]->s1.a = 1;
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
  nullp_005_struct_uni *ptr[10];
  // Struct array
  nullp_005_struct_uni strc[10];
  
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
      ptr[i]->s1.a = nums[i];
    }
  }
  
  int result = ptr[arg_index]->s1.a;
  printf("%d\n",result);
  
  
  return 0;
}
