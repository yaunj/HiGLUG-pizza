package main

import (
	"bufio"
	"errors"
	"fmt"
	"math"
	"math/rand"
	"os"
	"sort"
	"strconv"
	"strings"
	"time"
)

type Pizza struct {
	Name   string
	Weight int
	Price  int
}

type Menu []Pizza

func (menu Menu) Len() int {
	return len(menu)
}

func (menu Menu) Swap(i, j int) {
	menu[i], menu[j] = menu[j], menu[i]
}

func (menu Menu) Less(i, j int) bool {
	return menu[i].Name < menu[j].Name
}

func choose(menu Menu, amount int, max_price int) (Menu, error) {
	total_amount := 0
	lookup_table := make([]int, 0)
	returned_menu := make(Menu, 0)
	out_of_money := false
	wednesday := time.Now().Weekday() == 3

	seed := rand.NewSource(time.Now().UnixNano())
	rng := rand.New(seed)

	for iter, pizza := range menu {
		for i := 0; i < pizza.Weight; i++ {
			lookup_table = append(lookup_table, iter)
		}
	}

	for i := 0; i < amount; i++ {
		selected := menu[lookup_table[rng.Intn(len(lookup_table))]]

		if wednesday && !strings.HasPrefix(selected.Name, "Egenkomponert") {
			selected.Price = 119
		}

		total_amount += selected.Price

		if total_amount > max_price {
			out_of_money = true
			break
		}

		returned_menu = append(returned_menu, selected)
	}

	sort.Sort(Menu(returned_menu))

	if out_of_money {
		return returned_menu, errors.New("Money ran out")
	}

	return returned_menu, nil
}

func main() {
	people_per_pizza := 0.4
	max_price := 1200
	sauce := 20

	menu := Menu{
		Pizza{"Pappas spesial", 4, 159},
		Pizza{"Texas", 3, 149},
		Pizza{"Blue Hawai", 7, 149},
		Pizza{"Floriad", 4, 149},
		Pizza{"Buffalo", 4, 149},
		Pizza{"Chicken", 4, 149},
		Pizza{"New York", 0, 149},
		Pizza{"Las Vegas", 6, 149},
		Pizza{"Vegetarianer", 0, 149},
		Pizza{"FILADELFIA", 4, 149},
		Pizza{"Hot Chicago", 7, 149},
		Pizza{"Hot Express", 5, 149},
		Pizza{"Kebab pizza spesial", 3, 169},
		Pizza{"Egenkomponert, Pepperoni, Biff, Bacon, Skinke, løk", 9, 159},
		Pizza{"Egenkomponert, Biff, Pepperoni, Bacon, Skinke, Tacokjøtt", 9, 159},
	}

	var people_string string
	var err error

	if len(os.Args) > 1 {
		people_string = os.Args[1]
	} else {
		reader := bufio.NewReader(os.Stdin)
		fmt.Print("Antall oppmøtte: ")
		people_string, err = reader.ReadString('\n')

		if err != nil {
			panic(err)
		}

		people_string = strings.TrimSpace(people_string)
	}

	people, err := strconv.Atoi(people_string)
	if err != nil {
		panic(fmt.Sprintf("%#v is not a number", people_string))
	}

	amount := int(math.Ceil(float64(people) * people_per_pizza))
	order, err := choose(menu, amount, max_price)

	fmt.Println("Ordre for", people, "folk:")
	sum := 0

	for _, pizza := range order {
		fmt.Printf("%5d NOK - %s\n", pizza.Price, pizza.Name)
		sum += pizza.Price
	}

	remaining := max_price - sum

	fmt.Printf("Total: %d NOK", sum)
	if err != nil {
		fmt.Print(" (pristak nådd)")
	}
	fmt.Printf(" (%d NOK igjen)\n", max_price-sum)

	if remaining > sauce {
		no_sauce := remaining / sauce
		sauce_price := no_sauce * sauce
		remainder_after_sauce := remaining - sauce_price

		fmt.Printf("%d rømmedressing (%d NOK) kan kjøpes, med en rest på %d NOK\n",
			no_sauce, sauce_price, remainder_after_sauce)
	}
}
