#include <stdio.h>

main()
	{
	long long a,b,c,aabb,cc;
	long num,max_num,max_p,p;

	max_num = 0;
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
			printf("max_p = %lu %lu\n",max_p,num);
			}
		}
	printf("max_p = %lu\n",max_p);
	}

