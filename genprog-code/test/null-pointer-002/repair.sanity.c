int cause_err(int index , int **ptr ) 
{ 
  int ret ;

  {
  ret = *(*(ptr + index));
  return (1);
}
}
extern int ( /* missing proto */  atoi)() ;
extern int ( /* missing proto */  printf)() ;
int main(int argc , char **argv ) 
{ 
  int ARR_SIZE ;
  int arg_index ;
  int tmp ;
  int NUM_NEGTESTS ;
  int null_indices[3] ;
  int *ptr[10] ;
  int nums[10] ;
  int negIndex ;
  int i ;
  int j ;
  int result ;

  {
  ARR_SIZE = 10;
  tmp = atoi(*(argv + 1));
  arg_index = tmp;
  NUM_NEGTESTS = 3;
  null_indices[0] = 3;
  null_indices[1] = 6;
  null_indices[2] = 9;
  negIndex = 0;
  i = 0;
  while (i < ARR_SIZE) {
    nums[i] = i + 1;
    ptr[i] = (int *)((void *)0);
    j = 0;
    while (j < NUM_NEGTESTS) {
      if (arg_index == null_indices[j]) {
        negIndex = cause_err(null_indices[j], ptr);
      } else {

      }
      j ++;
    }
    if (negIndex == 0) {
      ptr[i] = & nums[i];
    } else {

    }
    i ++;
  }
  result = *(ptr[arg_index]);
  printf("%d\n", result);
  return (0);
}
}
