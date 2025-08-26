
int sum(int a, int b)
{
    return a+b;
}

const int x= 5;

int main(){
    int res = sum(2,3);

    int *mem = (int*)0x001000000;


    if(res == 5) *mem=1;
    else *mem=2;




    return 0;
}