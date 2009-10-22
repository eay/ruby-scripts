#include <stdio.h>

main()
	{
	unsigned long long a,b,c,aabb,cc;
	unsigned int num,max_num,max_p,p;

	for (p=12; p<1000; p++)
		{
		num = 0;
		a = p/2;
		b = 1;
		while (a > b)
			{
			aabb = a*a + b*b;
			cc = (p-a-b);
			cc = cc*cc;
			if (cc <= aabb)
				{
				if (cc == aabb)
					num++;
				a--;
				}
			else
				b++;
			}
		if (num > max_num)
			{
			max_num = num;
			max_p = p;
			printf("max_p = %u %u\n",max_p,num);
			}
		}
	printf("max_p = %u\n",max_p);
	}

