#!/usr/bin/perl
use strict;
use List::Util 'shuffle'; 
use POSIX;
 
print STDERR "HiGLUG Pappas Pizza pizzaorderscript,\n";
print STDERR "the Fishy Perl-implementation print version 0.1\n";
print STDERR "\n";
print STDERR "Copyright (c) 2008, Jon Langseth and HiGLUG\n";
print STDERR "See source for licence (BSD-3-clause)\n";

#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#  
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#  
#      * Redistributions in binary form must reproduce the above
#        copyright notice, this list of conditions and the following
#        disclaimer in the documentation and/or other materials provided
#        with the distribution.
#  
#      * Neither the name of Jon Langseth nor the names of
#        its contributors may be used to endorse or promote products
#        derived from this software without specific prior written
#        permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 

# Get number of pizza eaters, with error-control
my $number = shift;
if ((not defined($number)) || ($number < 1))
{
	print STDERR "No number of pizza-eaters given! Bailing out\n";
	exit(1);
}
# Recalculate, assuming each pizza-eater chugs 0.4 pizzas.
$number = int( ($number * 0.4) + 0.5 );

print "\nNumber of pizzas to order: " . $number . "\n";
# Check for an additional argument on the command line. 
# If it is there, we have a wednesday, with different prices.. 
my $wednesday = shift;

# Set maxprice to whatever amount is alloted through IMT ant IT-tjenesten.
my $maxprice = 1200;

# This variable sets the price of a cup of pizza dressing..
my $sauce = "20";

# The following three arrays represent the menu of Pappas Pizza, along with
# prices and HiGLUG's preferences on the menu.
my @pizzas = (
	"Pappas spesial",	#1
	"Texas",		#2
	"Blue Hawai",		#3
	"Floriad",		#4
	"Buffalo",		#5
	"Chicken",		#6
	"New York",		#7
	"Las Vegas",		#8
	"Vegetarianer",		#9
	"FILADELFIA",		#10
	"Hot Chicago",		#11
	"Hot Express",		#12
	"Kebab pizza spesial",	#13
	"Egenkomponert, Pepperoni, Biff, Bacon, Skinke, løk",		#14
	"Egenkomponert, Biff, Pepperoni, Bacon, Skinke, Tacokjøtt");	#14

# The block of wednesday and non-wednesday prices need to be updated
# on a regular basis
my @prices;
if ( $wednesday ) 
{ 
	# Yep, it's a wednesday, so the pizzas are cheap.
	@prices = (
	119, 			#1
	119, 			#2
	119, 			#3
	119, 			#4
	119, 			#5
	119, 			#6
	119, 			#7
	119, 			#8
	119, 			#9
	119, 			#10
	119, 			#11
	119, 			#12
	119, 			#13
	119, 			#14
	119); 			#15
} else 
{
	# No, it's not, so they are expensive
	@prices = (
	159, 			#1
	149, 			#2
	149, 			#3
	149, 			#4
	149, 			#5
	149, 			#6
	149, 			#7
	149, 			#8
	149, 			#9
	149, 			#10
	149, 			#11
	149, 			#12
	169, 			#13
	159, 			#14
	159); 			#15

}

# The weight will not be updated, unless it is submitted as a patch.
# Accepted format is unified diff.
my @weight = (
	4, 			#1
	3, 			#2
	7, 			#3
	4, 			#4
	4, 			#5
	4, 			#6
	0, 			#7
	6, 			#8
	0, 			#9
	4, 			#10
	7, 			#11
	5, 			#12
	3, 			#13
	9, 			#14
	9); 			#15

my @available = ();
my $total = 0;
my %result;

# Put all pizzas into an array of available choices, with the number
# of occurences withing the array representing the weight (preference) the pizza has.
for (my $pos = 0; $pos<$#pizzas; $pos++)
{
	for(my $i = 1; $i <= $weight[$pos]; $i++)
	{ push (@available, $pos); }
}

# This little bit of magic code from List::Util randomizes the array
# of available pizzas, to make the order even more random!
@available = shuffle(@available);

# A random number is generated within the range of the array of available pizzas,
# and used for selection of pizza. This loop is run the equivalent number of times
# as the input to the script dictated (calculated number of pizzas)
for ( my $i = 0; $i < $number; $i++)
{
	my $prand = $available[int(rand($#available))];
	$total = $total + ( $prices[$prand] + $sauce );

	# The loop will keep on running, as long as maxprice is not crossed.
	if ( $total < $maxprice )
	{
		# The pizza description text is used as a HASH-key with a value representing
		# the number of times this pizza has been selected.
		my $text = "Pizza no " . $prand . " -> " . $pizzas[$prand] . " (kr " . $prices[$prand] . ")";
		%result->{$text} = %result->{$text} + 1;

	} else {
		# When the maxprice has been crossed, we need to step the price back to
		# what it was when the last pizza was selected.
		$total = $total - ( $prices[$prand] + $sauce );
		print STDERR "\n";
		print STDERR "Went over the limit trying to allocate one more pizza.\n";
		print STDERR "Pizza overflow, giving up with the following available:\n";
		last;
	}
}
print ("\n");
# Run through the HASH and present the result.
foreach my $key ( keys %result )
{
	print %result->{$key} . " times " . $key . "\n";
}
print "Total cost should be kr. " . $total . " or sumthing like that\n\n";
# Ring in the order for those pizzas manually.
