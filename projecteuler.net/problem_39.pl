#!/usr/bin/env perl
%hash = (); 
%hash2 = (); 
for ($i = 1; $i <= 999; $i ++) { 
	$hash{$i} = $i ** 2; 
	$hash2{$i ** 2} = $i; 
} 

%hash3 = (); 
for ($a = 1; $a <= 999; $a ++) { 
	for ($b = 1; $b <= $a; $b ++) { 
		$c = $hash{$a} + $hash{$b}; 
		if(defined($hash2{$c})) { 
			if ($a + $b + $hash2{$c} <= 1000) { 
				$hash3{$a + $b + $hash2{$c}} += 1; 
			} 
		} 
	} 
} 

$max = 0; 
foreach $d (keys %hash3) { 
	$count = $hash3{$d}; 
	if ($count > $max) { 
		$max = $count; 
		$value = $d; 
	} 
} 
print "$value\n";
