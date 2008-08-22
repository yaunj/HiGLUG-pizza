#!/usr/bin/python
# -*- coding: utf-8 -*-

import random, pprint, calendar, time, sys, math

meal = 0.4
persons = int(sys.argv[1])
prize_max = 1200
prize_cheap = 119


# menyen med vekttall
menu = [("Pappas spesial", 4, 159),
         ("Texas",          3, 149),
         ("Blue Hawai",     7, 149),
         ("Floriad",        4, 149),
         ("Buffalo",        4, 149),
         ("Chicken",        4, 149),
         ("New York",       0, 149),
         ("Las Vegas",      6, 149),
         ("Vegetarianer",   0, 149),
         ("FILADELFIA",     4, 149),
         ("Hot Chicago",    7, 149),
         ("Hot Express",    5, 149),
         ("Kebab pizza spesial", 3, 169),
         ("Egenkomponert, Pepperoni, Biff, Bacon, Skinke, løk",   9, 159),
         ("Egenkomponert, Biff, Pepperoni, Bacon, Skinke, Tacokjøtt", 
9, 159),
         ]

# et buffer vi kan velge fra
buf = []

# på onsdager er det billig
if calendar.weekday(*time.localtime()[:3]) == 2:
     for pizza in menu: buf += ([(pizza[0], prize_cheap)] * pizza[1])
else:
     for pizza in menu: buf += ([(pizza[0], pizza[2])] * pizza[1])


prize_sum = 0
pizzas = {}
sum = 0

for i in range(int(math.ceil(persons * meal))):

     # trekk neste pizza
     next = buf.pop(random.randrange(len(buf)))

     if prize_sum + next[1] >= prize_max:
         break
     else:
         if pizzas.has_key(next):
             pizzas[next] += 1
         else:
             pizzas[next] = 1

         sum += 1
         prize_sum += next[1]


pprint.pprint(pizzas)
print "sum:", prize_sum
