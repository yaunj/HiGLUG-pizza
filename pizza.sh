#!/bin/bash
# HiGLUG Pappas Pizza pizzaorderscript.
# Copyright (c) 2008, Rune Hammersland and HiGLUG
#
# TODO: Randomize choices array for better randomness in pizza selection.
# TODO: Add ordering of sauce..

if [ $# -lt 1 ]; then
        echo -n "Number of peeps: "
        read peeps
else
        peeps=$1
fi

maxprice=1200
el_cheapo=119
total=0
choices=()
menu=("Pappas_spesial 4 159"
      "Texas          3 149"
      "Blue_Hawai     7 149"
      "Floriad        4 149"
      "Buffalo        4 149"
      "Chicken        4 149"
      "New_York       0 149"
      "Las_Vegas      6 149"
      "Vegetarianer   0 149"
      "FILADELFIA     4 149"
      "Hot_Chicago    7 149"
      "Hot_Express    5 149"
      "Kebab_pizza_spesial 3 169"
      "Egenkomponert,_Pepperoni,_Biff,_Bacon,_Skinke,_l0k   9 159"
      "Egenkomponert,_Biff,_Pepperoni,_Bacon,_Skinke,_Tacokj0tt 9 159")

number=`echo "$peeps * 0.4" | bc | xargs printf "%.f"`
printf "Number of pizzas to order: %d\n\n" $number
let "wednesday = 3 == `date +%w`"

for pizza in $(seq 0 $((${#menu[@]} - 1))); do
        pizza=${menu[$pizza]}
        name=`  echo $pizza | awk '{print $1}'`
        weight=`echo $pizza | awk '{print $2}'`
        price=` echo $pizza | awk '{print $3}'`
        if [ $wednesday = 1 ]; then
                price=$el_cheapo
        fi

        # Insert pizza in array n times
        for i in $(seq 0 $weight); do
                choices=( "${choices[@]}" "$name $price" )
        done
done

# TODO: Randomize the choices array for better randomness.
for i in $(seq 1 $number); do
        let "pizza=$RANDOM % ${#choices[@]}"
        pizza=${choices[$pizza]}
        name=` echo $pizza | awk '{print $1}' | sed -e 's/_/ /g'`
        price=`echo $pizza | awk '{print $2}'`

        # Check if total is bigger than maxprice.
        let "newtotal=$total + $price"
        if [ $newtotal -gt $maxprice ]; then
                echo "NO MOAR PIZZ0R 4 U!!!!!"
                let "number=$i - 1"
                break
        fi
        total=$newtotal
        printf "ORDER %-64s PLX (%3s)\n" "$name" $price
done

printf "========================================"
printf "========================================\n\n"
printf "TOTAL SHOULD EQUALZ: %58s\n" $total
printf "PIZZ0R IN ORDER: %62s\n" $number
